#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

root = Path(sys.argv[1])
android_name = "{http://schemas.android.com/apk/res/android}name"
application_name = "arno.di.loreto.crashlyticsforandroidwear.CrashlyticsForAndroidWearApplication"

manifest_path = root / "mobile/src/main/AndroidManifest.xml"
application_path = root / "mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java"
initializer_path = root / "mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsInitializer.java"
activity_path = root / "mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/activities/MainActivity.java"
receiver_path = root / "mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearableListenerReceiver.java"


def fail(message):
    raise SystemExit(message)


manifest = ET.parse(str(manifest_path)).getroot()
application = manifest.find("application")
if application is None or application.get(android_name) != application_name:
    fail("Mobile manifest must assign process initialization to CrashlyticsForAndroidWearApplication.")

component_names = {
    element.get(android_name)
    for component in ("activity", "service", "receiver")
    for element in application.findall(component)
}
required_components = {
    "arno.di.loreto.crashlyticsforandroidwear.activities.MainActivity",
    "arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerBroadcaster",
    "arno.di.loreto.crashlyticsforandroidwear.crashlytics.CrashlyticsWearableListenerReceiver",
}
if not required_components.issubset(component_names):
    fail("Activity, Wear listener service, and Crashlytics receiver must remain in the initialized application process.")

if not application_path.is_file():
    fail("Process-owned Crashlytics Application class is missing.")
application_source = application_path.read_text()
if "extends Application" not in application_source:
    fail("CrashlyticsForAndroidWearApplication must extend android.app.Application.")
if "public void onCreate()" not in application_source:
    fail("CrashlyticsForAndroidWearApplication must initialize from the process startup callback.")
if application_source.count("CrashlyticsInitializer.initialize(this);") != 1:
    fail("Application startup must invoke the shared Crashlytics initializer exactly once.")
if application_source.index("super.onCreate();") > application_source.index("CrashlyticsInitializer.initialize(this);"):
    fail("Application must call super.onCreate before initializing Crashlytics.")

if not initializer_path.is_file():
    fail("Shared Crashlytics initializer is missing.")
initializer_source = initializer_path.read_text()
required_initializer_contracts = (
    "public final class CrashlyticsInitializer",
    "private static boolean initialized;",
    "public static synchronized void initialize(Context context)",
    "if (initialized)",
    "context.getApplicationContext()",
    "Fabric.with(applicationContext, new Crashlytics());",
    "initialized = true;",
)
for contract in required_initializer_contracts:
    if contract not in initializer_source:
        fail("Shared initializer contract is incomplete: %s" % contract)
if initializer_source.index("if (initialized)") > initializer_source.index("Fabric.with(applicationContext, new Crashlytics());"):
    fail("Idempotence guard must run before Fabric initialization.")
if initializer_source.index("Fabric.with(applicationContext, new Crashlytics());") > initializer_source.index("initialized = true;"):
    fail("Initialized state must only be recorded after Fabric accepts initialization.")

java_sources = list((root / "mobile/src/main/java").rglob("*.java"))
fabric_calls = sum(path.read_text().count("Fabric.with(") for path in java_sources)
if fabric_calls != 1:
    fail("Exactly one production Fabric.with call must remain, owned by the shared initializer.")

activity_source = activity_path.read_text()
if activity_source.count("CrashlyticsInitializer.initialize(this);") != 1:
    fail("MainActivity must use the shared idempotent initializer for compatibility.")
if "Fabric.with(" in activity_source:
    fail("MainActivity must not own direct Fabric initialization.")
if activity_source.index("super.onCreate(savedInstanceState);") > activity_source.index("CrashlyticsInitializer.initialize(this);"):
    fail("MainActivity must call super.onCreate before the compatibility initializer.")

receiver_source = receiver_path.read_text()
message_method = receiver_source[receiver_source.index("public void onMessageReceived"):receiver_source.index("private void sendCrashlyticsReport")]
if message_method.index("PATH_CRASHLYTICS.equalsIgnoreCase") > message_method.index("DataMap.fromByteArray"):
    fail("Unsupported Wear message paths must be rejected before payload parsing or reporting.")
if message_method.index("messageData == null || messageData.length == 0") > message_method.index("DataMap.fromByteArray"):
    fail("Empty Wear payloads must be rejected before parsing or reporting.")
if "catch (IllegalArgumentException e)" not in message_method:
    fail("Malformed Wear payloads must remain locally rejected without reporting.")

report_method = receiver_source[receiver_source.index("private void sendCrashlyticsReport"):]
first_reporting_call = min(match.start() for match in re.finditer(r"Crashlytics\.(?:setBool|setString|logException)", report_method))
for validation in (
    "reportType == null || reportType.length() == 0",
    "!isSupportedReportType(reportType)",
    "errorReport == null || errorReport.length() == 0",
):
    if report_method.index(validation) > first_reporting_call:
        fail("Invalid Crashlytics reports must be rejected before SDK reporting: %s" % validation)

print("Crashlytics cold-start initialization contract passed.")
PY
