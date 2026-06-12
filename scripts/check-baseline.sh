#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
WRAPPER="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
README="$ROOT_DIR/README.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-crashlytics-wear-build-baseline.md"
LINT_PLAN="$ROOT_DIR/docs/plans/2026-06-08-gradle-lint-baseline.md"
REPORT_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-crashlytics-report-type-guard.md"
WEAR_REPORT_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-report-type-allowlist.md"
WEAR_THROWABLE_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-throwable-log-redaction.md"
MOBILE_THROWABLE_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-09-mobile-throwable-log-redaction.md"
WEAR_CONNECTED_NODE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-connected-node-send-guard.md"
WEAR_EVENT_INTENT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-event-intent-extras.md"
WEAR_SEND_RESULT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-send-result-status-guard.md"
ANDROID_BACKUP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-android-backup-opt-out.md"
MOBILE_REPORT_TYPE_ALLOWLIST_PLAN="$ROOT_DIR/docs/plans/2026-06-09-mobile-report-type-allowlist.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
METADATA_PRIVACY_PLAN="$ROOT_DIR/docs/plans/2026-06-10-crash-metadata-privacy-boundary.md"
WEAR_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-data-layer-send-timeouts.md"
MAKEFILE="$ROOT_DIR/Makefile"
MOBILE_MANIFEST="$ROOT_DIR/mobile/src/main/AndroidManifest.xml"
WEAR_MANIFEST="$ROOT_DIR/wear/src/main/AndroidManifest.xml"
MOBILE_LINT="$ROOT_DIR/mobile/lint.xml"
WEAR_LINT="$ROOT_DIR/wear/lint.xml"
MOBILE_RECEIVER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearableListenerReceiver.java"
WEARABLE_BROADCASTER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/WearableListenerBroadcaster.java"
WEARABLE_RECEIVER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/WearableListenerReceiver.java"
WEAR_API="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWear.java"
WEAR_UNCAUGHT_HANDLER="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrachlyticsWearUncaughtExceptionHandler.java"
WEAR_SERVICE="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java"
DUMMY_SERVICE="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/services/SendDummyMessageIntentService.java"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  ".github/workflows/check.yml" \
  "CHANGES.md" \
  "README.md" \
  "docs/plans/2026-06-08-crashlytics-wear-build-baseline.md" \
  "docs/plans/2026-06-08-gradle-lint-baseline.md" \
  "docs/plans/2026-06-09-crashlytics-report-type-guard.md" \
  "docs/plans/2026-06-09-mobile-throwable-log-redaction.md" \
  "docs/plans/2026-06-09-android-backup-opt-out.md" \
  "docs/plans/2026-06-09-wear-connected-node-send-guard.md" \
  "docs/plans/2026-06-09-wear-event-intent-extras.md" \
  "docs/plans/2026-06-09-wear-send-result-status-guard.md" \
  "docs/plans/2026-06-09-mobile-report-type-allowlist.md" \
  "docs/plans/2026-06-09-wear-report-type-allowlist.md" \
  "docs/plans/2026-06-09-wear-throwable-log-redaction.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-crash-metadata-privacy-boundary.md" \
  "docs/plans/2026-06-12-wear-data-layer-send-timeouts.md" \
  "gradlew" \
  "gradle/wrapper/gradle-wrapper.properties" \
  "settings.gradle" \
  "build.gradle" \
  "mobile/build.gradle" \
  "mobile/lint.xml" \
  "wear/build.gradle" \
  "wear/lint.xml" \
  "mobile/src/main/AndroidManifest.xml" \
  "wear/src/main/AndroidManifest.xml"; do
  require_file "$path"
done

for ignored in ".gradle/" ".idea/" "*.iml" "local.properties" "*/build/" "crashlytics.properties" "crashlytics-build.properties"; do
  if ! grep -Fq "$ignored" "$ROOT_DIR/.gitignore"; then
    printf '%s\n' ".gitignore must ignore $ignored" >&2
    exit 1
  fi
done

for tracked in ".idea" "CrashlyticsForAndroidWear.iml" "mobile/mobile.iml" "wear/wear.iml" "local.properties"; do
  if git -C "$ROOT_DIR" ls-files "$tracked" | grep -q .; then
    printf '%s\n' "IDE or machine-local file must not be tracked: $tracked" >&2
    exit 1
  fi
done

if ! grep -Fq "https\\://services.gradle.org/distributions/gradle-1.12-all.zip" "$WRAPPER"; then
  printf '%s\n' "Gradle wrapper must use HTTPS for the legacy 1.12 distribution." >&2
  exit 1
fi

if grep -R "http\\://services.gradle.org" "$ROOT_DIR" --exclude-dir=.git >/dev/null; then
  printf '%s\n' "Gradle service URLs must not use plain HTTP." >&2
  exit 1
fi

if ! grep -Fq "classpath 'com.android.tools.build:gradle:0.12.2'" "$ROOT_BUILD"; then
  printf '%s\n' "Android Gradle plugin 0.12.2 pin must remain explicit." >&2
  exit 1
fi

if ! grep -Fq "https://dl.google.com/dl/android/maven2" "$ROOT_BUILD"; then
  printf '%s\n' "Root build must include Google Maven for legacy Play Services artifacts." >&2
  exit 1
fi

if ! grep -Fq "classpath 'io.fabric.tools:gradle:1.14.4'" "$MOBILE_BUILD"; then
  printf '%s\n' "Fabric Gradle plugin must be pinned." >&2
  exit 1
fi

if ! grep -Fq "usesPlaceholderCrashlyticsKey" "$MOBILE_BUILD" || ! grep -Fq "task.name.startsWith('fabric') && task.name.endsWith('Debug')" "$MOBILE_BUILD"; then
  printf '%s\n' "Debug Fabric resource tasks must be disabled when the placeholder Crashlytics key is present." >&2
  exit 1
fi

if grep -Fq ":+" "$MOBILE_BUILD" || grep -Fq ":+" "$WEAR_BUILD" || grep -Fq "1.+" "$MOBILE_BUILD"; then
  printf '%s\n' "Gradle dependencies must not use dynamic + versions." >&2
  exit 1
fi

for build_file in "$MOBILE_BUILD" "$WEAR_BUILD"; do
  if ! grep -Fq 'buildToolsVersion "24.0.3"' "$build_file"; then
    printf '%s\n' "Build tools must be pinned to host-compatible 24.0.3 in $build_file" >&2
    exit 1
  fi
  if ! grep -Fq "compileSdkVersion 21" "$build_file"; then
    printf '%s\n' "compileSdkVersion 21 must remain explicit in $build_file" >&2
    exit 1
  fi
done

if ! grep -Fq "play-services-wearable:6.1.71" "$MOBILE_BUILD"; then
  printf '%s\n' "Mobile wearable Play Services dependency must be pinned." >&2
  exit 1
fi

if grep -Fq "com.google.android.support:wearable" "$WEAR_BUILD"; then
  printf '%s\n' "Unused legacy Wear support dependency must stay removed." >&2
  exit 1
fi

if ! grep -Fq 'android:value="0000000000000000000000000000000000000000"' "$MOBILE_MANIFEST"; then
  printf '%s\n' "Crashlytics API key must remain an all-zero placeholder, not a committed secret." >&2
  exit 1
fi

if ! grep -Fq "ext.enableCrashlytics = false" "$MOBILE_BUILD"; then
  printf '%s\n' "Debug builds must disable Crashlytics tasks while the API key is a placeholder." >&2
  exit 1
fi

if ! grep -Fq 'android:exported="false"' "$MOBILE_MANIFEST"; then
  printf '%s\n' "Crashlytics broadcast receivers must be non-exported." >&2
  exit 1
fi

for manifest in "$MOBILE_MANIFEST" "$WEAR_MANIFEST"; do
  if grep -Fq 'android:allowBackup="true"' "$manifest" ||
    ! grep -Fq 'android:allowBackup="false"' "$manifest"; then
    printf '%s\n' "Mobile and wear manifests must explicitly disable app-data backup." >&2
    exit 1
  fi
done

if ! grep -Fq 'tools:ignore="ExportedService"' "$MOBILE_MANIFEST"; then
  printf '%s\n' "WearableListenerService exported-service lint warning must be explicitly documented." >&2
  exit 1
fi

for lint_config in "$MOBILE_LINT" "$WEAR_LINT"; do
  if ! grep -Fq '<issue id="LintError" severity="ignore" />' "$lint_config"; then
    printf '%s\n' "Legacy lint must suppress the missing API database runner error in $lint_config" >&2
    exit 1
  fi
  if ! grep -Fq '<issue id="OldTargetApi" severity="ignore" />' "$lint_config"; then
    printf '%s\n' "Legacy lint must document the intentional SDK 21 target warning in $lint_config" >&2
    exit 1
  fi
  if [ "$(grep -c "<issue " "$lint_config")" -ne 2 ]; then
    printf '%s\n' "Legacy lint suppressions must stay limited to LintError and OldTargetApi in $lint_config" >&2
    exit 1
  fi
done

if grep -Fq "start_name" "$ROOT_DIR/mobile/src/main/res/values/strings.xml"; then
  printf '%s\n' "Unused starter string start_name must not be tracked." >&2
  exit 1
fi

if grep -Fq "ObjectInputStream" "$MOBILE_RECEIVER" || grep -Fq "ObjectOutputStream" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear crash payloads must not use Java object serialization." >&2
  exit 1
fi

if grep -Fq "ObjectInputStream" "$WEARABLE_RECEIVER" ||
  grep -Fq "ObjectOutputStream" "$WEARABLE_BROADCASTER" ||
  grep -Fq "objectToByArray" "$WEARABLE_BROADCASTER" ||
  grep -Fq "getObjectFromByteArray" "$WEARABLE_RECEIVER"; then
  printf '%s\n' "Wear event broadcasts must not use Java object serialization." >&2
  exit 1
fi

if ! grep -Fq "Long.valueOf(Build.TIME).toString()" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must avoid direct Long constructors in crash metadata." >&2
  exit 1
fi

if ! grep -Fq "throwableToString" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must serialize crash reports as strings." >&2
  exit 1
fi

if grep -Fq 'Log.d(MYLOGGER, "Received error", ex)' "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must not log throwable stack traces before forwarding reports." >&2
  exit 1
fi

if ! grep -Fq 'Log.d(MYLOGGER, "Received crashlytics report")' "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must keep non-sensitive receipt logging for crash reports." >&2
  exit 1
fi

if ! grep -Fq "intent.setPackage(getPackageName())" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcasts must be package-scoped." >&2
  exit 1
fi

if ! grep -Fq "EXTRA_MESSAGE_DATA" "$WEARABLE_BROADCASTER" ||
  ! grep -Fq "EXTRA_NODE_ID" "$WEARABLE_BROADCASTER" ||
  ! grep -Fq "intent.putExtra(EXTRA_MESSAGE_DATA, messageEvent.getData())" "$WEARABLE_BROADCASTER" ||
  ! grep -Fq "intent.putExtra(EXTRA_NODE_ID, peer.getId())" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcasts must use typed Intent extras for messages and nodes." >&2
  exit 1
fi

if ! grep -Fq "Ignoring disconnected peer without node data" "$WEARABLE_BROADCASTER" ||
  ! grep -Fq "Ignoring connected peer without node data" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcaster must guard missing peer callbacks." >&2
  exit 1
fi

if ! grep -Fq "messageEvent == null || messageEvent.getPath() == null" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcaster must guard missing message paths." >&2
  exit 1
fi

if ! grep -Fq "dataEvents == null || dataEvents.getStatus() == null" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcaster must guard missing data change status." >&2
  exit 1
fi

if ! grep -Fq "releaseDataEvents(dataEvents)" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcaster must release DataEventBuffer callbacks." >&2
  exit 1
fi

if ! grep -Fq "Ignoring unexpected wear event action" "$WEARABLE_RECEIVER"; then
  printf '%s\n' "Wear event receiver must reject unexpected broadcast actions." >&2
  exit 1
fi

if ! grep -Fq "Ignoring wear event without payload" "$WEARABLE_RECEIVER"; then
  printf '%s\n' "Wear event receiver must guard missing payloads." >&2
  exit 1
fi

if ! grep -Fq "new SerializableMessageEvent(" "$WEARABLE_RECEIVER" ||
  ! grep -Fq "new SerializableNode(" "$WEARABLE_RECEIVER" ||
  ! grep -Fq "intent.getByteArrayExtra(WearableListenerBroadcaster.EXTRA_MESSAGE_DATA)" "$WEARABLE_RECEIVER" ||
  ! grep -Fq "intent.getStringExtra(WearableListenerBroadcaster.EXTRA_NODE_ID)" "$WEARABLE_RECEIVER"; then
  printf '%s\n' "Wear event receiver must rebuild typed events from Intent extras." >&2
  exit 1
fi

if ! grep -Fq "Ignoring malformed crashlytics payload" "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile crash receiver must guard malformed DataMap payloads." >&2
  exit 1
fi

if ! grep -Fq "reportType == null || reportType.length() == 0" "$MOBILE_RECEIVER" ||
  ! grep -Fq "Crashlytics report missing DATA_MAP_REPORT_TYPE" "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile crash receiver must reject reports without a report type." >&2
  exit 1
fi

if ! grep -Fq "private static boolean isSupportedReportType" "$MOBILE_RECEIVER" ||
  ! grep -Fq "REPORT_TYPE_CRASH.equals(reportType) || REPORT_TYPE_EXCEPTION.equals(reportType)" "$MOBILE_RECEIVER" ||
  ! grep -Fq "Crashlytics report has unsupported DATA_MAP_REPORT_TYPE" "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile crash receiver must allow only declared Crashlytics report types." >&2
  exit 1
fi

if grep -Fq 'Log.d(MYLOGGER, "Crash report received from wear device: type=" + reportType, wearReport)' "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile crash receiver must not log reconstructed wear stack traces before Crashlytics forwarding." >&2
  exit 1
fi

if ! grep -Fq 'Log.d(MYLOGGER, "Crash report received from wear device: type=" + reportType)' "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile crash receiver must keep non-sensitive report type receipt logging." >&2
  exit 1
fi

if ! grep -Fq "CrashlyticsWear.init(Application) must be called" "$WEAR_API"; then
  printf '%s\n' "Wear API must guard logException before initialization." >&2
  exit 1
fi

if ! grep -Fq "errorExtra instanceof Throwable" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must validate throwable extras before casting." >&2
  exit 1
fi

if ! grep -Fq "report_type == null || report_type.length() == 0" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must reject missing or empty report types." >&2
  exit 1
fi

if ! grep -Fq "private static boolean isSupportedReportType" "$WEAR_SERVICE" ||
  ! grep -Fq "REPORT_TYPE_CRASH.equals(reportType) || REPORT_TYPE_EXCEPTION.equals(reportType)" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must allow only declared Crashlytics report types." >&2
  exit 1
fi

if ! grep -Fq "Ignoring crashlytics report with unsupported report type" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must log unsupported report type rejections without forwarding them." >&2
  exit 1
fi

if ! grep -Fq "mApiClient.disconnect()" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear service must disconnect GoogleApiClient after sends." >&2
  exit 1
fi

for sender in "$WEAR_SERVICE" "$DUMMY_SERVICE"; do
  if ! grep -Fq "private static final long DATA_LAYER_TIMEOUT_SECONDS = 5;" "$sender" || \
     ! grep -Fq "import java.util.concurrent.TimeUnit;" "$sender" || \
     ! grep -Fq "DATA_LAYER_TIMEOUT_SECONDS, TimeUnit.SECONDS" "$sender"; then
    printf '%s\n' "Wear message senders must declare and use the five-second Data Layer timeout." >&2
    exit 1
  fi

  if grep -Fq "blockingConnect().isSuccess()" "$sender" || grep -Fq ").await();" "$sender"; then
    printf '%s\n' "Wear message senders must not use unbounded Data Layer waits." >&2
    exit 1
  fi

  timeout_use_count=$(grep -Fc "DATA_LAYER_TIMEOUT_SECONDS, TimeUnit.SECONDS" "$sender")
  if [ "$timeout_use_count" -ne 3 ]; then
    printf '%s\n' "Each Wear sender must bound connection, node lookup, and message send waits." >&2
    exit 1
  fi
done

if ! grep -Fq "path == null || path.length() == 0 || dataMap == null" "$WEAR_SERVICE" ||
  ! grep -Fq "No connected nodes available for crashlytics report" "$WEAR_SERVICE" ||
  ! grep -Fq "Skipping connected node without id" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear crash sender must guard missing send targets and connected-node ids." >&2
  exit 1
fi

if ! grep -Fq "node == null || node.getId() == null || node.getId().length() == 0" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear crash sender must skip connected nodes without ids." >&2
  exit 1
fi

if ! grep -Fq "result == null || result.getStatus() == null" "$WEAR_SERVICE" ||
  ! grep -Fq "Crashlytics send finished without status" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear crash sender must guard missing send results and statuses." >&2
  exit 1
fi

if ! grep -Fq "Ignoring dummy message without intent" "$DUMMY_SERVICE" ||
  ! grep -Fq "message == null || message.length() == 0" "$DUMMY_SERVICE" ||
  ! grep -Fq "Ignoring dummy message without payload" "$DUMMY_SERVICE"; then
  printf '%s\n' "Dummy message sender must ignore missing intent and payload." >&2
  exit 1
fi

if ! grep -Fq "path == null || path.length() == 0 || message == null || message.length() == 0" "$DUMMY_SERVICE" ||
  ! grep -Fq "No connected nodes available for dummy message" "$DUMMY_SERVICE" ||
  ! grep -Fq "Skipping dummy message node without id" "$DUMMY_SERVICE"; then
  printf '%s\n' "Dummy message sender must guard missing send targets and connected-node ids." >&2
  exit 1
fi

if ! grep -Fq "Ignoring dummy message without path" "$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/dummy/DummyWearableListenerReceiver.java" ||
  ! grep -Fq "byte[] messageData = messageEvent.getData()" "$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/dummy/DummyWearableListenerReceiver.java"; then
  printf '%s\n' "Dummy message receiver must guard missing path and payload data." >&2
  exit 1
fi

if ! grep -Fq "blockingConnect(" "$DUMMY_SERVICE" || ! grep -Fq "mApiClient.disconnect()" "$DUMMY_SERVICE"; then
  printf '%s\n' "Dummy message sender must check GoogleApiClient connection success and disconnect." >&2
  exit 1
fi

if ! grep -Fq "result == null || result.getStatus() == null" "$DUMMY_SERVICE" ||
  ! grep -Fq "Dummy message send finished without status" "$DUMMY_SERVICE"; then
  printf '%s\n' "Dummy message sender must guard missing send results and statuses." >&2
  exit 1
fi

if ! grep -Fq "ALLOWED_METADATA_KEYS" "$MOBILE_RECEIVER" ||
  grep -Fq "dataMap.keySet()" "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile Crashlytics metadata must use a declared allowlist instead of payload-provided keys." >&2
  exit 1
fi

if grep -Fq 'Log.d(MYLOGGER,"data_map."' "$MOBILE_RECEIVER" ||
  grep -Fq 'Build.SERIAL' "$WEAR_SERVICE" ||
  grep -Fq 'DATA_MAP_SERIAL' "$WEAR_SERVICE"; then
  printf '%s\n' "Crash forwarding must not log metadata values or collect the hardware serial identifier." >&2
  exit 1
fi

if ! grep -Fq "Crashlytics.setString(DATA_MAP_REPORT_TYPE, reportType)" "$MOBILE_RECEIVER" ||
  ! grep -Fq "for (String key : ALLOWED_METADATA_KEYS)" "$MOBILE_RECEIVER" ||
  ! grep -Fq "catch (ClassCastException e)" "$MOBILE_RECEIVER"; then
  printf '%s\n' "Mobile Crashlytics forwarding must preserve report type and allowlisted metadata." >&2
  exit 1
fi

if ! grep -Fq "mApplication != null && ex != null" "$WEAR_UNCAUGHT_HANDLER"; then
  printf '%s\n' "Uncaught handler must guard missing application and throwable before starting the service." >&2
  exit 1
fi

if ! grep -Fq "mDefaultUncaughtExceptionHandler != null" "$WEAR_UNCAUGHT_HANDLER"; then
  printf '%s\n' "Uncaught handler must guard a missing previous default handler." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$README"; then
  printf '%s\n' "README must document the baseline guard." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$README"; then
  printf '%s\n' "README must document the GitHub Actions check." >&2
  exit 1
fi

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "make check" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must check out the repository and run make check." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "contents: read" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must keep repository access read-only." >&2
  exit 1
fi

if ! grep -Fq 'ANDROID_HOME: ""' "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq 'ANDROID_SDK_ROOT: ""' "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions must clear hosted Android SDK variables for the legacy SDK-free baseline." >&2
  exit 1
fi

if ! grep -Fq "runs-on: ubuntu-24.04" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions must use the stable Ubuntu 24.04 runner." >&2
  exit 1
fi

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE" ||
  [ "$(grep -c -- '--project-dir "$(ROOT)"' "$MAKEFILE")" -ne 4 ]; then
  printf '%s\n' "Make targets must resolve Gradle and its project directory from the repository root." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "timeout-minutes: 5" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must support bounded manual verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint" "$README"; then
  printf '%s\n' "README must document the Gradle lint gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew check" "$README"; then
  printf '%s\n' "README must document the Gradle check gate." >&2
  exit 1
fi

if ! grep -Fq "Wear data-change callbacks release their \`DataEventBuffer\`" "$README"; then
  printf '%s\n' "README must document DataEventBuffer release behavior." >&2
  exit 1
fi

if ! grep -Fq "Mobile Crashlytics receivers reject decoded reports without" "$README"; then
  printf '%s\n' "README must document mobile report type validation." >&2
  exit 1
fi

if ! grep -Fq "Mobile Crashlytics receivers reject unsupported report types" "$README"; then
  printf '%s\n' "README must document mobile report type allowlisting." >&2
  exit 1
fi

if ! grep -Fq "Wear reports are sent only with the declared CRASH or EXCEPTION report types" "$README"; then
  printf '%s\n' "README must document the wear report type allowlist." >&2
  exit 1
fi

if ! grep -Fq "Wear throwable stack traces are serialized for the phone" "$README"; then
  printf '%s\n' "README must document throwable log redaction." >&2
  exit 1
fi

if ! grep -Fq "Mobile receivers log only the report type" "$README"; then
  printf '%s\n' "README must document mobile throwable log redaction." >&2
  exit 1
fi

if ! grep -Fq "forward only the declared Wear device metadata keys" "$README" ||
  ! grep -Fq "omit the hardware serial identifier" "$README"; then
  printf '%s\n' "README must document the Crashlytics metadata privacy boundary." >&2
  exit 1
fi

if ! grep -Fq "Wear message senders skip missing connected-node results and node ids" "$README"; then
  printf '%s\n' "README must document connected-node send guards." >&2
  exit 1
fi

if ! grep -Fq "typed Intent extras instead of Java object serialization" "$README"; then
  printf '%s\n' "README must document typed Wear event broadcast payloads." >&2
  exit 1
fi

if ! grep -Fq "Wear message senders skip missing send results and statuses" "$README"; then
  printf '%s\n' "README must document send result status guards." >&2
  exit 1
fi

if ! grep -Fq "Wear message senders bound connection, node lookup, and per-node send waits" "$README"; then
  printf '%s\n' "README must document bounded Wear Data Layer waits." >&2
  exit 1
fi

if ! grep -Fq "Mobile and wear app-data backup is disabled" "$README"; then
  printf '%s\n' "README must document the Android backup opt-out." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LINT_PLAN"; then
  printf '%s\n' "Lint plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$REPORT_TYPE_PLAN"; then
  printf '%s\n' "Report type plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_REPORT_TYPE_PLAN"; then
  printf '%s\n' "Wear report type allowlist plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WEAR_REPORT_TYPE_PLAN"; then
  printf '%s\n' "Wear report type allowlist plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_THROWABLE_LOG_PLAN"; then
  printf '%s\n' "Wear throwable log redaction plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WEAR_THROWABLE_LOG_PLAN"; then
  printf '%s\n' "Wear throwable log redaction plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$MOBILE_THROWABLE_LOG_PLAN"; then
  printf '%s\n' "Mobile throwable log redaction plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$MOBILE_THROWABLE_LOG_PLAN"; then
  printf '%s\n' "Mobile throwable log redaction plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_CONNECTED_NODE_PLAN"; then
  printf '%s\n' "Wear connected node send guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WEAR_CONNECTED_NODE_PLAN"; then
  printf '%s\n' "Wear connected node send guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_EVENT_INTENT_PLAN"; then
  printf '%s\n' "Wear event Intent extras plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WEAR_EVENT_INTENT_PLAN"; then
  printf '%s\n' "Wear event Intent extras plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_SEND_RESULT_PLAN"; then
  printf '%s\n' "Wear send result status guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WEAR_SEND_RESULT_PLAN"; then
  printf '%s\n' "Wear send result status guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$MOBILE_REPORT_TYPE_ALLOWLIST_PLAN"; then
  printf '%s\n' "Mobile report type allowlist plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$MOBILE_REPORT_TYPE_ALLOWLIST_PLAN"; then
  printf '%s\n' "Mobile report type allowlist plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ANDROID_BACKUP_PLAN"; then
  printf '%s\n' "Android backup opt-out plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ANDROID_BACKUP_PLAN"; then
  printf '%s\n' "Android backup opt-out plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$METADATA_PRIVACY_PLAN" ||
  ! grep -Fq "make check" "$METADATA_PRIVACY_PLAN"; then
  printf '%s\n' "Crash metadata privacy plan must be completed and record verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_TIMEOUT_PLAN" || \
   ! grep -Fq "make check" "$WEAR_TIMEOUT_PLAN"; then
  printf '%s\n' "Wear Data Layer timeout plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Crashlytics Wear build baseline checks passed."
