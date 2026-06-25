#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/crashlytics-cold-start.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

mkdir "$TMP_DIR/candidate"
(cd "$ROOT_DIR" && tar --exclude=.git -cf - .) | (cd "$TMP_DIR/candidate" && tar -xf -)

if ! "$TMP_DIR/candidate/scripts/test-crashlytics-cold-start.sh" >"$TMP_DIR/control.out" 2>&1; then
  printf '%s\n' "Unmodified candidate failed the cold-start contract." >&2
  cat "$TMP_DIR/control.out" >&2
  exit 1
fi

expect_rejected() {
  name=$1
  mutation=$2

  rm -rf "$TMP_DIR/repo"
  cp -R "$TMP_DIR/candidate" "$TMP_DIR/repo"
  sh -c "$mutation" sh "$TMP_DIR/repo"

  if "$TMP_DIR/repo/scripts/test-crashlytics-cold-start.sh" >"$TMP_DIR/$name.out" 2>&1; then
    printf '%s\n' "Hostile cold-start mutation was accepted: $name" >&2
    cat "$TMP_DIR/$name.out" >&2
    exit 1
  fi

  printf '%s\n' "Rejected hostile cold-start mutation: $name"
}

expect_rejected "removed-application-registration" '
  repo=$1
  python3 - "$repo/mobile/src/main/AndroidManifest.xml" <<"PY"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("        android:name=\"arno.di.loreto.crashlyticsforandroidwear.CrashlyticsForAndroidWearApplication\"\n", "", 1)
path.write_text(text)
PY
'

expect_rejected "removed-application-initialization" '
  repo=$1
  sed -i.bak "/CrashlyticsInitializer.initialize(this);/d" "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java"
  rm "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java.bak"
'

expect_rejected "restored-activity-only-ownership" '
  repo=$1
  sed -i.bak "/CrashlyticsInitializer.initialize(this);/d" "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java"
  rm "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java.bak"
  sed -i.bak "s/CrashlyticsInitializer.initialize(this);/Fabric.with(this, new Crashlytics());/" "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/activities/MainActivity.java"
  rm "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/activities/MainActivity.java.bak"
'

expect_rejected "double-fabric-initialization" '
  repo=$1
  sed -i.bak "/Fabric.with(applicationContext, new Crashlytics());/a\\
        Fabric.with(applicationContext, new Crashlytics());" "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsInitializer.java"
  rm "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsInitializer.java.bak"
'

expect_rejected "bypassed-application-startup-callback" '
  repo=$1
  sed -i.bak "s/public void onCreate()/public void initializeAfterActivity()/" "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java"
  rm "$repo/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/CrashlyticsForAndroidWearApplication.java.bak"
'

printf '%s\n' "Crashlytics cold-start hostile mutation tests passed."
