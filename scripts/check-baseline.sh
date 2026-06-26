#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
WRAPPER="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
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
COMPONENT_EXPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-android-component-export-contract.md"
WEAR_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-data-layer-send-timeouts.md"
UTF8_PLAN="$ROOT_DIR/docs/plans/2026-06-13-dummy-message-utf8-wire-format.md"
SNAPSHOT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-event-immutable-snapshots.md"
UNCAUGHT_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-uncaught-throwable-log-redaction.md"
MAKE_ROOT_PROTECTION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-make-root-override-protection.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-crashlytics-wear-device-verification.md"
DUMMY_PAYLOAD_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-dummy-message-payload-log-redaction.md"
SEND_OUTCOME_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-wear-send-outcome-log-redaction.md"
DUMMY_PATH_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-dummy-message-path-log-redaction.md"
CRASHLYTICS_PATH_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-crashlytics-message-path-log-redaction.md"
MALFORMED_PAYLOAD_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-16-crashlytics-malformed-payload-log-redaction.md"
BROADCASTER_PATH_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-16-broadcaster-message-path-log-redaction.md"
PEER_DISPLAY_NAME_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-16-peer-display-name-log-redaction.md"
DATA_EVENT_STATUS_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-16-data-event-status-log-redaction.md"
HOSTED_ANDROID_PLAN="$ROOT_DIR/docs/plans/2026-06-17-hosted-android-sdk-verification.md"
NODE_DISCOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-25-wear-node-discovery-status.md"
SNAPSHOT_TEST="$ROOT_DIR/scripts/test-wear-event-snapshots.sh"
SNAPSHOT_CHECK="$ROOT_DIR/scripts/WearEventSnapshotCheck.java"
COLD_START_TEST="$ROOT_DIR/scripts/test-crashlytics-cold-start.sh"
COLD_START_MUTATION_TEST="$ROOT_DIR/scripts/test-crashlytics-cold-start-mutations.sh"
NODE_DISCOVERY_TEST="$ROOT_DIR/scripts/test-wear-node-discovery-status.sh"
NODE_DISCOVERY_MUTATION_TEST="$ROOT_DIR/scripts/test-wear-node-discovery-status-mutations.sh"
MAKEFILE="$ROOT_DIR/Makefile"
CHANGES="$ROOT_DIR/CHANGES.md"
VISION="$ROOT_DIR/VISION.md"
MOBILE_MANIFEST="$ROOT_DIR/mobile/src/main/AndroidManifest.xml"
WEAR_MANIFEST="$ROOT_DIR/wear/src/main/AndroidManifest.xml"
MOBILE_LINT="$ROOT_DIR/mobile/lint.xml"
WEAR_LINT="$ROOT_DIR/wear/lint.xml"
MOBILE_RECEIVER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearableListenerReceiver.java"
WEARABLE_BROADCASTER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/WearableListenerBroadcaster.java"
WEARABLE_RECEIVER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/WearableListenerReceiver.java"
MESSAGE_SNAPSHOT="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/SerializableMessageEvent.java"
NODE_SNAPSHOT="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/SerializableNode.java"
WEAR_API="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWear.java"
WEAR_UNCAUGHT_HANDLER="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrachlyticsWearUncaughtExceptionHandler.java"
WEAR_SERVICE="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java"
DUMMY_SERVICE="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/services/SendDummyMessageIntentService.java"
DUMMY_RECEIVER="$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/dummy/DummyWearableListenerReceiver.java"
UTF8_CHECK="$ROOT_DIR/scripts/Utf8RoundTripCheck.java"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"

require_sha256() {
  file=$1
  expected=$2
  message=$3
  if [ "$(sha256sum "$file" | awk '{print $1}')" != "$expected" ]; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=cf111fcb34804940404e79eaf307876acb8434005bc4cc782d260730a0a2a4f2
distributionUrl=https\://services.gradle.org/distributions/gradle-1.12-all.zip
networkTimeout=60000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
}

expected_check_workflow() {
  cat <<'EOF'
name: Check

on:
  push:
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false

      - name: Validate Gradle wrapper provenance
        uses: gradle/actions/wrapper-validation@3f131e8634966bd73d06cc69884922b02e6faf92 # v6.2.0

      - name: Install Android SDK packages
        run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-21" "build-tools;24.0.3"'

      - name: Set up Java 8
        uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
        with:
          distribution: corretto
          java-version: "8"

      - name: Verify reviewed Gradle wrapper behavior
        run: scripts/verify-gradle-wrapper.sh

      - name: Run full Android verification
        run: make check
EOF
}

expected_makefile() {
  cat <<'EOF'
.PHONY: baseline-test build check lint tasks test verify

override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ANDROID_HOME ?= /home/gjones/android-sdk
GRADLE ?= $(ROOT)gradlew

lint:
	$(ROOT)scripts/check-baseline.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" lint --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle lint skipped."; \
	fi

test:
	$(ROOT)scripts/test-crashlytics-cold-start.sh
	$(ROOT)scripts/test-crashlytics-cold-start-mutations.sh
	$(ROOT)scripts/test-wear-node-discovery-status.sh
	$(ROOT)scripts/test-wear-node-discovery-status-mutations.sh
	$(ROOT)scripts/test-wear-event-snapshots.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" check --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle check skipped."; \
	fi

tasks:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" tasks --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle tasks skipped."; \
	fi

build:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" assembleDebug --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle build skipped."; \
	fi

verify: lint test tasks build

baseline-test:
	$(ROOT)scripts/test-check-baseline.sh

check: verify baseline-test
EOF
}

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
  "docs/plans/2026-06-12-android-component-export-contract.md" \
  "docs/plans/2026-06-12-wear-data-layer-send-timeouts.md" \
  "docs/plans/2026-06-12-gradle-wrapper-verification.md" \
  "docs/plans/2026-06-13-dummy-message-utf8-wire-format.md" \
  "docs/plans/2026-06-13-wear-event-immutable-snapshots.md" \
  "docs/plans/2026-06-13-wear-uncaught-throwable-log-redaction.md" \
  "docs/plans/2026-06-14-make-root-override-protection.md" \
  "docs/plans/2026-06-15-dummy-message-payload-log-redaction.md" \
  "docs/plans/2026-06-15-dummy-message-path-log-redaction.md" \
  "docs/plans/2026-06-16-crashlytics-malformed-payload-log-redaction.md" \
  "docs/plans/2026-06-16-peer-display-name-log-redaction.md" \
  "docs/plans/2026-06-17-hosted-android-sdk-verification.md" \
  "docs/plans/2026-06-25-wear-node-discovery-status-design.md" \
  "docs/plans/2026-06-25-wear-node-discovery-status.md" \
  "gradlew" \
  "gradlew.bat" \
  "gradle/wrapper/gradle-wrapper.properties" \
  "gradle/wrapper/gradle-wrapper.jar" \
  "scripts/test-check-baseline.sh" \
  "scripts/test-crashlytics-cold-start.sh" \
  "scripts/test-crashlytics-cold-start-mutations.sh" \
  "scripts/test-wear-node-discovery-status.sh" \
  "scripts/test-wear-node-discovery-status-mutations.sh" \
  "scripts/verify-gradle-wrapper.sh" \
  "settings.gradle" \
  "build.gradle" \
  "scripts/Utf8RoundTripCheck.java" \
  "scripts/WearEventSnapshotCheck.java" \
  "scripts/test-wear-event-snapshots.sh" \
  "mobile/build.gradle" \
  "mobile/lint.xml" \
  "wear/build.gradle" \
  "wear/lint.xml" \
  "mobile/src/main/AndroidManifest.xml" \
  "wear/src/main/AndroidManifest.xml"; do
  require_file "$path"
done

for unique_workflow_contract in \
  "Validate Gradle wrapper provenance" \
  "uses: gradle/actions/wrapper-validation@3f131e8634966bd73d06cc69884922b02e6faf92 # v6.2.0" \
  "Install Android SDK packages" \
  'run: '\''"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-21" "build-tools;24.0.3"'\''' \
  "Set up Java 8" \
  "uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0" \
  "distribution: corretto" \
  'java-version: "8"' \
  "Verify reviewed Gradle wrapper behavior" \
  "run: scripts/verify-gradle-wrapper.sh" \
  "Run full Android verification" \
  "run: make check"; do
  if [ "$(grep -Fc "$unique_workflow_contract" "$CI_WORKFLOW")" -ne 1 ]; then
    printf '%s\n' "GitHub Actions workflow must keep exactly one contract: $unique_workflow_contract" >&2
    exit 1
  fi
done

if [ "$(cat "$CI_WORKFLOW")" != "$(expected_check_workflow)" ]; then
  printf '%s\n' "GitHub Actions check workflow must match the exact reviewed contract." >&2
  exit 1
fi

if [ "$(cat "$MAKEFILE")" != "$(expected_makefile)" ]; then
  printf '%s\n' "Makefile must match the exact reviewed verification graph." >&2
  exit 1
fi

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

if [ ! -x "$GRADLEW" ] || [ "$(cat "$WRAPPER")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Generated wrapper must retain the reviewed Gradle 1.12 URL and checksum." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" "Unix wrapper must match the reviewed generated script."
require_sha256 "$GRADLEW_BAT" "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" "Windows wrapper must match the reviewed generated script."
require_sha256 "$WRAPPER_JAR" "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" "Wrapper JAR must match Gradle's published 8.14.5 checksum."
require_sha256 "$WRAPPER" "7bbfd5380175e2a5d096f5d78897f8a1f23448902c795a315ef0b2bb91515f28" "Wrapper properties must match the reviewed checksum contract."
require_sha256 "$ROOT_DIR/scripts/verify-gradle-wrapper.sh" "7faa35602944d3c6d13268f18ab12e2c7b343adfe304cf5374a077cb1623d94d" "Wrapper verification script must match the reviewed runtime contract."
require_sha256 "$ROOT_DIR/scripts/test-check-baseline.sh" "8d40b061cc8dda5059688e8c50539d89b7dece14ace893398ad7cbf3a1f8a872" "Hostile mutation test script must match the reviewed gate contract."
require_sha256 "$COLD_START_TEST" "fd0879197cc6f339c73e9c0d1ff2a044cdbb4ffbd90718ac4fc1ad3715c8e777" "Crashlytics cold-start contract must match the reviewed test."
require_sha256 "$COLD_START_MUTATION_TEST" "7fddf113646b36057ac645fe2a9a0c271c0993c5ceada3d6388ca2621bf3020b" "Crashlytics cold-start mutation suite must match the reviewed test."

if [ "$(grep -Fc "maven { url 'https://jcenter.bintray.com' }" "$ROOT_BUILD")" -ne 2 ] || \
   grep -Fq "jcenter()" "$ROOT_BUILD" || \
   grep -Eq "maven[[:space:]]*\{[[:space:]]*url[[:space:]]+'http://" \
     "$ROOT_BUILD" "$MOBILE_BUILD" "$WEAR_BUILD"; then
  printf '%s\n' "Legacy JCenter coordinates must resolve through the reviewed HTTPS endpoint." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$WRAPPER_PLAN" || \
   ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || \
   ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "external working directory" "$WRAPPER_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "distributionSha256Sum" "$README" || \
   ! grep -Fq "generated Gradle 8.14.5 bootstrap" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "checksum-verified direct wrapper" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "authenticated Gradle wrapper" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Repository guidance must document the authenticated wrapper boundary." >&2
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

for manifest in "$MOBILE_MANIFEST" "$WEAR_MANIFEST"; do
  if grep -Fq 'android:allowBackup="true"' "$manifest" ||
    ! grep -Fq 'android:allowBackup="false"' "$manifest"; then
    printf '%s\n' "Mobile and wear manifests must explicitly disable app-data backup." >&2
    exit 1
  fi
done

if [ "$(grep -c '<activity' "$MOBILE_MANIFEST")" -ne 1 ] ||
  [ "$(grep -c '<service' "$MOBILE_MANIFEST")" -ne 1 ] ||
  [ "$(grep -c '<receiver' "$MOBILE_MANIFEST")" -ne 2 ] ||
  [ "$(grep -c '<activity' "$WEAR_MANIFEST")" -ne 1 ] ||
  [ "$(grep -c '<service' "$WEAR_MANIFEST")" -ne 2 ] ||
  [ "$(grep -c '<receiver' "$WEAR_MANIFEST")" -ne 0 ]; then
  printf '%s\n' "Android component inventory must stay within the reviewed manifest boundary." >&2
  exit 1
fi
if [ "$(grep -c 'android:exported=' "$MOBILE_MANIFEST")" -ne 4 ] ||
  [ "$(grep -c 'android:exported=' "$WEAR_MANIFEST")" -ne 3 ]; then
  printf '%s\n' "Every reviewed Android component must declare an explicit export policy." >&2
  exit 1
fi

if [ "$(grep -Fc 'tools:ignore="ExportedService"' "$MOBILE_MANIFEST")" -ne 1 ] ||
  [ "$(grep -Fc 'xmlns:tools="http://schemas.android.com/tools"' "$MOBILE_MANIFEST")" -ne 1 ]; then
  printf '%s\n' "The required exported listener warning must stay locally documented once." >&2
  exit 1
fi

mobile_launcher_manifest=$(awk '/android:name="arno.di.loreto.crashlyticsforandroidwear.activities.MainActivity"/ { capture = 1 } capture { print } capture && /<\/activity>/ { exit }' "$MOBILE_MANIFEST")
wear_launcher_manifest=$(awk '/android:name="arno.di.loreto.crashlyticsforandroidwear.activities.MainWearActivity"/ { capture = 1 } capture { print } capture && /<\/activity>/ { exit }' "$WEAR_MANIFEST")
for launcher_manifest in "$mobile_launcher_manifest" "$wear_launcher_manifest"; do
  if [ "$(printf '%s\n' "$launcher_manifest" | grep -Fc 'android:exported="true"')" -ne 1 ] ||
    [ "$(printf '%s\n' "$launcher_manifest" | grep -c '<intent-filter>' || true)" -ne 1 ] ||
    [ "$(printf '%s\n' "$launcher_manifest" | grep -c '<action ' || true)" -ne 1 ] ||
    [ "$(printf '%s\n' "$launcher_manifest" | grep -c '<category ' || true)" -ne 1 ] ||
    ! printf '%s\n' "$launcher_manifest" | grep -Fq '<action android:name="android.intent.action.MAIN" />' ||
    ! printf '%s\n' "$launcher_manifest" | grep -Fq '<category android:name="android.intent.category.LAUNCHER" />'; then
    printf '%s\n' "Both Android launcher activities must be explicitly exported with exactly MAIN/LAUNCHER." >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'android:name="arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerBroadcaster"' "$MOBILE_MANIFEST")" -ne 1 ]; then
  printf '%s\n' "Mobile manifest must declare exactly one Wear listener service." >&2
  exit 1
fi
wear_listener_manifest=$(awk '/android:name="arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerBroadcaster"/ { capture = 1 } capture { print } capture && /<\/service>/ { exit }' "$MOBILE_MANIFEST")
if [ "$(printf '%s\n' "$wear_listener_manifest" | grep -Fc 'android:exported="true"')" -ne 1 ] ||
  [ "$(printf '%s\n' "$wear_listener_manifest" | grep -Fc 'tools:ignore="ExportedService"')" -ne 1 ] ||
  [ "$(printf '%s\n' "$wear_listener_manifest" | grep -c '<action ' || true)" -ne 1 ] ||
  ! printf '%s\n' "$wear_listener_manifest" | grep -Fq '<action android:name="com.google.android.gms.wearable.BIND_LISTENER" />'; then
  printf '%s\n' "Mobile Wear listener must be explicitly exported for exactly BIND_LISTENER." >&2
  exit 1
fi

for receiver_name in \
  "arno.di.loreto.crashlyticsforandroidwear.crashlytics.CrashlyticsWearableListenerReceiver" \
  "arno.di.loreto.crashlyticsforandroidwear.dummy.DummyWearableListenerReceiver"; do
  receiver_manifest=$(awk -v name="$receiver_name" 'index($0, "android:name=\"" name "\"") { capture = 1 } capture { print } capture && /<\/receiver>/ { exit }' "$MOBILE_MANIFEST")
  if [ "$(printf '%s\n' "$receiver_manifest" | grep -Fc 'android:exported="false"')" -ne 1 ]; then
    printf '%s\n' "Mobile Crashlytics receivers must be explicitly non-exported: $receiver_name" >&2
    exit 1
  fi
done

for service_name in \
  "arno.di.loreto.crashlyticsforandroidwear.crashlytics.CrashlyticsWearIntentService" \
  "arno.di.loreto.crashlyticsforandroidwear.services.SendDummyMessageIntentService"; do
  service_manifest=$(awk -v name="$service_name" 'index($0, "android:name=\"" name "\"") { capture = 1 } capture { print } capture && /\/>/ { exit }' "$WEAR_MANIFEST")
  if [ "$(printf '%s\n' "$service_manifest" | grep -Fc 'android:exported="false"')" -ne 1 ] ||
    [ "$(printf '%s\n' "$service_manifest" | grep -Fc 'android:process=":error"')" -ne 1 ]; then
    printf '%s\n' "Internal Wear intent services must be non-exported and keep their isolated process: $service_name" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "CodeQL alert 1" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "fresh clone" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "Twenty-nine focused mutations" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "42f2da730712fea266ad41ee0b8ff26df06d32e9" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "push run \`27404727879\`" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "pull-request run \`27404729914\`" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "CodeQL run \`27404728054\`" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "zero open code-scanning alerts" "$COMPONENT_EXPORT_PLAN" ||
  ! grep -Fq "do not broaden it into lint.xml" "$COMPONENT_EXPORT_PLAN"; then
  printf '%s\n' "Android component export plan must record completed local and hosted verification." >&2
  exit 1
fi

if ! grep -Fq "Both launcher activities and the Google Play services Wear listener" "$README" ||
  ! grep -Fq "Both launcher activities are explicitly exported" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "every Android component export policy explicit" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Documentation must record the explicit Android component trust boundaries." >&2
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
  ! grep -Fq "intent.putExtra(EXTRA_MESSAGE_DATA, messageSnapshot.getData())" "$WEARABLE_BROADCASTER" ||
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

if ! grep -Fq "SerializableMessageEvent messageSnapshot = new SerializableMessageEvent(messageEvent);" "$WEARABLE_BROADCASTER" || \
  ! grep -Fq "intent.putExtra(EXTRA_MESSAGE_DATA, messageSnapshot.getData());" "$WEARABLE_BROADCASTER" || \
  grep -Fq "intent.putExtra(EXTRA_MESSAGE_DATA, messageEvent.getData());" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear event broadcaster must snapshot mutable message payloads before the asynchronous broadcast boundary." >&2
  exit 1
fi

if ! grep -Fq "private final byte[] data;" "$MESSAGE_SNAPSHOT" || \
  ! grep -Fq "private final String path;" "$MESSAGE_SNAPSHOT" || \
  ! grep -Fq "this.data = copyData(data);" "$MESSAGE_SNAPSHOT" || \
  ! grep -Fq "return copyData(data);" "$MESSAGE_SNAPSHOT" || \
  ! grep -Fq "return data == null ? null : data.clone();" "$MESSAGE_SNAPSHOT" || \
  grep -Fq "public void set" "$MESSAGE_SNAPSHOT"; then
  printf '%s\n' "Wear message events must remain immutable defensive snapshots." >&2
  exit 1
fi

if ! grep -Fq "private final String displayName;" "$NODE_SNAPSHOT" || \
  ! grep -Fq "private final String id;" "$NODE_SNAPSHOT" || \
  grep -Fq "public void set" "$NODE_SNAPSHOT"; then
  printf '%s\n' "Wear nodes must remain immutable snapshots." >&2
  exit 1
fi

if ! grep -Fq '$(ROOT)scripts/test-wear-event-snapshots.sh' "$MAKEFILE" || \
  ! grep -Fq "Constructor must copy message data." "$SNAPSHOT_CHECK" || \
  ! grep -Fq "Getter must copy message data." "$SNAPSHOT_CHECK" || \
  ! grep -Fq "Null message data must remain null." "$SNAPSHOT_CHECK" || \
  ! grep -Fq "Modifier.isFinal" "$SNAPSHOT_CHECK" || \
  ! grep -Fq 'javac -d "$CLASS_DIR"' "$SNAPSHOT_TEST" || \
  ! grep -Fq 'java -cp "$CLASS_DIR" WearEventSnapshotCheck' "$SNAPSHOT_TEST"; then
  printf '%s\n' "Wear event snapshot fixture and test wiring must remain enforced." >&2
  exit 1
fi

if ! grep -Fq "immutable snapshots" "$README" || \
  ! grep -Fq "immutable snapshots" "$CHANGES" || \
  ! grep -Fq "event wrappers immutable" "$VISION" || \
  ! grep -Fq "R6. A standalone Java fixture" "$SNAPSHOT_PLAN" || \
  ! grep -Fq "status: completed" "$SNAPSHOT_PLAN" || \
  ! grep -Fq "Eight isolated hostile mutations" "$SNAPSHOT_PLAN"; then
  printf '%s\n' "Wear event snapshot documentation and plan contracts must remain checked in." >&2
  exit 1
fi

if [ "$(grep -Fc 'Log.e(MYLOGGER, "Ignoring malformed crashlytics payload");' "$MOBILE_RECEIVER")" -ne 1 ] || \
  grep -Fq 'Log.e(MYLOGGER, "Ignoring malformed crashlytics payload",' "$MOBILE_RECEIVER"; then
  printf '%s\n' "Malformed Crashlytics payload logs must keep a constant category without exception details." >&2
  exit 1
fi

if [ ! -f "$MALFORMED_PAYLOAD_LOG_PLAN" ] || \
  ! grep -Fq "Status: Completed" "$MALFORMED_PAYLOAD_LOG_PLAN" || \
  ! grep -Fq "make check" "$MALFORMED_PAYLOAD_LOG_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$MALFORMED_PAYLOAD_LOG_PLAN" || \
  ! grep -Fq "No emulator, physical wearable, paired transport, or live malformed message" "$MALFORMED_PAYLOAD_LOG_PLAN"; then
  printf '%s\n' "Malformed Crashlytics payload log plan must record completed verification." >&2
  exit 1
fi

if [ "$(grep -Fc 'Log.d(MYLOGGER, "Wear message received");' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  grep -Eq 'Log\.[^;]*messageEvent\.getPath\(' "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear message broadcaster diagnostics must not disclose paired-peer paths." >&2
  exit 1
fi

if [ "$(grep -Fc 'intent.putExtra(EXTRA_DATA_PATH, messageSnapshot.getPath());' "$WEARABLE_BROADCASTER")" -ne 1 ]; then
  printf '%s\n' "Wear message broadcaster routing must retain the copied path extra." >&2
  exit 1
fi

if [ "$(grep -Fc 'Log.d(MYLOGGER, "Wear peer disconnected");' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  [ "$(grep -Fc 'Log.d(MYLOGGER, "Wear peer connected");' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  grep -Eq 'Log\.[^;]*peer\.getDisplayName\(' "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear peer diagnostics must not disclose paired-device display names." >&2
  exit 1
fi

if [ "$(grep -Fc 'intent.putExtra(EXTRA_NODE_DISPLAY_NAME, peer.getDisplayName());' "$WEARABLE_BROADCASTER")" -ne 2 ] || \
  [ "$(grep -Fc 'intent.putExtra(EXTRA_NODE_ID, peer.getId());' "$WEARABLE_BROADCASTER")" -ne 2 ]; then
  printf '%s\n' "Wear peer broadcasts must retain display-name and node-ID routing extras." >&2
  exit 1
fi

peer_display_name_guidance="Wear peer connection diagnostics omit paired-device display names while preserving package-scoped node extras."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$peer_display_name_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Wear peer display-name redaction guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

if [ ! -f "$PEER_DISPLAY_NAME_LOG_PLAN" ] || \
  ! grep -Fq "Status: Completed" "$PEER_DISPLAY_NAME_LOG_PLAN" || \
  ! grep -Fq "make check" "$PEER_DISPLAY_NAME_LOG_PLAN" || \
  ! grep -Fq "isolated peer-log mutations were rejected" "$PEER_DISPLAY_NAME_LOG_PLAN" || \
  ! grep -Fq "No emulator, physical wearable, paired transport, or live peer callback" "$PEER_DISPLAY_NAME_LOG_PLAN"; then
  printf '%s\n' "Wear peer display-name redaction plan must record completed verification." >&2
  exit 1
fi

if [ "$(grep -Fc 'dataEvents == null || dataEvents.getStatus() == null' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  [ "$(grep -Fc 'Log.d(MYLOGGER, "Wear data change received");' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  [ "$(grep -Fc 'super.onDataChanged(dataEvents);' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  [ "$(grep -Fc 'releaseDataEvents(dataEvents);' "$WEARABLE_BROADCASTER")" -ne 1 ] || \
  grep -Fq "getStatusMessage()" "$WEARABLE_BROADCASTER"; then
  printf '%s\n' "Wear data-event diagnostics must not disclose raw provider status messages." >&2
  exit 1
fi

data_status_guard_line=$(grep -nF 'dataEvents == null || dataEvents.getStatus() == null' "$WEARABLE_BROADCASTER" | cut -d: -f1)
data_status_log_line=$(grep -nF 'Log.d(MYLOGGER, "Wear data change received");' "$WEARABLE_BROADCASTER" | cut -d: -f1)
data_status_super_line=$(grep -nF 'super.onDataChanged(dataEvents);' "$WEARABLE_BROADCASTER" | cut -d: -f1)
data_status_release_line=$(grep -nF 'releaseDataEvents(dataEvents);' "$WEARABLE_BROADCASTER" | cut -d: -f1)
if [ "$data_status_guard_line" -ge "$data_status_log_line" ] || \
  [ "$data_status_log_line" -ge "$data_status_super_line" ] || \
  [ "$data_status_super_line" -ge "$data_status_release_line" ]; then
  printf '%s\n' "Wear data-event validation, logging, callback, and release ordering must remain fail-safe." >&2
  exit 1
fi

data_event_status_guidance="Wear data-event diagnostics omit raw provider status messages while preserving status guards and buffer release."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$data_event_status_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Wear data-event status redaction guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

if [ ! -f "$DATA_EVENT_STATUS_LOG_PLAN" ] || \
  ! grep -Fq "Status: Completed" "$DATA_EVENT_STATUS_LOG_PLAN" || \
  ! grep -Fq "make check" "$DATA_EVENT_STATUS_LOG_PLAN" || \
  ! grep -Fq "isolated data-status mutations were rejected" "$DATA_EVENT_STATUS_LOG_PLAN" || \
  ! grep -Fq "No emulator, physical wearable, paired transport, or live data-event callback" "$DATA_EVENT_STATUS_LOG_PLAN"; then
  printf '%s\n' "Wear data-event status redaction plan must record completed verification." >&2
  exit 1
fi

broadcaster_path_guidance="The mobile Wear event broadcaster keeps paired-peer message paths out of Logcat while preserving package-scoped routing."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$broadcaster_path_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Broadcaster message path redaction guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

if [ ! -f "$BROADCASTER_PATH_LOG_PLAN" ] || \
  ! grep -Fq "Status: Completed" "$BROADCASTER_PATH_LOG_PLAN" || \
  ! grep -Fq "make check" "$BROADCASTER_PATH_LOG_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$BROADCASTER_PATH_LOG_PLAN" || \
  ! grep -Fq "No emulator, physical wearable, paired transport, or live broadcaster message" "$BROADCASTER_PATH_LOG_PLAN"; then
  printf '%s\n' "Broadcaster message path redaction plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Malformed Crashlytics payload diagnostics must never include parser exception details" "$ROOT_DIR/AGENTS.md" || \
  ! grep -Fq "Malformed Crashlytics payload logs retain a constant rejection category without parser exception details." "$README" || \
  ! grep -Fq "Malformed Crashlytics payload diagnostics must not include peer-triggered parser exception details." "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Keep malformed Crashlytics payload diagnostics free of parser exception details" "$VISION" || \
  ! grep -Fq "Redacted parser exception details from malformed Crashlytics payload diagnostics." "$CHANGES"; then
  printf '%s\n' "Malformed Crashlytics payload log redaction must remain documented." >&2
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
  ! grep -Fq "nodes == null || nodes.getStatus() == null || !nodes.getStatus().isSuccess()" "$WEAR_SERVICE" ||
  ! grep -Fq "Connected node discovery failed for crashlytics report" "$WEAR_SERVICE" ||
  ! grep -Fq "No connected nodes available for crashlytics report" "$WEAR_SERVICE" ||
  ! grep -Fq "Skipping connected node without id" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear crash sender must guard send targets, discovery status, and connected-node ids." >&2
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
  ! grep -Fq "nodes == null || nodes.getStatus() == null || !nodes.getStatus().isSuccess()" "$DUMMY_SERVICE" ||
  ! grep -Fq "Connected node discovery failed for dummy message" "$DUMMY_SERVICE" ||
  ! grep -Fq "No connected nodes available for dummy message" "$DUMMY_SERVICE" ||
  ! grep -Fq "Skipping dummy message node without id" "$DUMMY_SERVICE"; then
  printf '%s\n' "Dummy message sender must guard send targets, discovery status, and connected-node ids." >&2
  exit 1
fi

if ! grep -Fq "Ignoring dummy message without path" "$DUMMY_RECEIVER" ||
  ! grep -Fq "byte[] messageData = messageEvent.getData()" "$DUMMY_RECEIVER"; then
  printf '%s\n' "Dummy message receiver must guard missing path and payload data." >&2
  exit 1
fi

for endpoint in "$DUMMY_SERVICE" "$DUMMY_RECEIVER"; do
  if ! grep -Fq 'import java.nio.charset.Charset;' "$endpoint" ||
    ! grep -Fq 'private static final Charset UTF_8 = Charset.forName("UTF-8");' "$endpoint"; then
    printf '%s\n' "Dummy message endpoints must declare the explicit UTF-8 wire format." >&2
    exit 1
  fi
done

if ! grep -Fq 'message.getBytes(UTF_8)' "$DUMMY_SERVICE" ||
  ! grep -Fq 'new String(messageData, UTF_8)' "$DUMMY_RECEIVER" ||
  grep -Fq 'message.getBytes()' "$DUMMY_SERVICE" ||
  grep -Fq 'new String(messageData)' "$DUMMY_RECEIVER"; then
  printf '%s\n' "Dummy messages must encode and decode with the explicit UTF-8 wire format." >&2
  exit 1
fi

if ! grep -Fq 'Log.d(MYLOGGER, "Dummy message received");' "$DUMMY_RECEIVER" ||
  grep -Eq 'Log\.[^;]*(messageData|decodedMessage)' "$DUMMY_RECEIVER" ||
  grep -Eq 'Log\.[^;]*\+[[:space:]]*message([[:space:]]*[),;]|[[:space:]]*\+)' "$DUMMY_RECEIVER"; then
  printf '%s\n' "Dummy message receipt logs must not expose decoded or raw payload content." >&2
  exit 1
fi

if ! grep -Fq 'Dummy message receipt logs omit decoded payload content' "$README" ||
  ! grep -Fq 'Dummy Wear message receipt logs must not include decoded or raw payload content' "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq 'Keep dummy Wear receipt logs free of message payload content' "$VISION" ||
  ! grep -Fq 'Removed decoded dummy Wear message payloads from mobile Logcat receipt diagnostics' "$CHANGES" ||
  ! grep -Fq 'Dummy Wear receipt logs must never include decoded or raw message payloads' "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Dummy message payload log redaction must remain documented." >&2
  exit 1
fi

if ! grep -Fq 'Log.d(MYLOGGER, "Unknown dummy message path");' "$DUMMY_RECEIVER" ||
  grep -Eq 'Log\.[^;]*getPath\(' "$DUMMY_RECEIVER"; then
  printf '%s\n' "Dummy message path logs must not expose peer-controlled path values." >&2
  exit 1
fi

if ! grep -Fq 'Log.d(MYLOGGER, "Unknown crashlytics message path");' "$MOBILE_RECEIVER" ||
  grep -Eq 'Log\.[^;]*getPath\(' "$MOBILE_RECEIVER" ||
  ! grep -Fq 'super.onMessageReceived(context, messageEvent);' "$MOBILE_RECEIVER"; then
  printf '%s\n' "Crashlytics message path logs must not expose peer-controlled path values." >&2
  exit 1
fi

if [ ! -f "$CRASHLYTICS_PATH_LOG_PLAN" ] || \
  ! grep -Fq "status: completed" "$CRASHLYTICS_PATH_LOG_PLAN" || \
  ! grep -Fq "## Status: Completed" "$CRASHLYTICS_PATH_LOG_PLAN" || \
  ! grep -Fq "make check" "$CRASHLYTICS_PATH_LOG_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$CRASHLYTICS_PATH_LOG_PLAN" || \
  ! grep -Fq "Paired-device delivery and live Logcat observation were not exercised" "$CRASHLYTICS_PATH_LOG_PLAN"; then
  printf '%s\n' "Crashlytics message path log redaction plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Crashlytics message path diagnostics omit peer-controlled path values" "$README" || \
  ! grep -Fq "Crashlytics Wear message path diagnostics must not include peer-controlled path values" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Keep Crashlytics Wear path diagnostics free of peer-controlled path values" "$VISION" || \
  ! grep -Fq "Redacted peer-controlled paths from Crashlytics Wear message diagnostics" "$CHANGES" || \
  ! grep -Fq "Crashlytics Wear path diagnostics must never include peer-controlled path values" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Crashlytics message path log redaction must remain documented." >&2
  exit 1
fi

if [ ! -f "$DUMMY_PATH_LOG_PLAN" ] || \
  ! grep -Fq "status: completed" "$DUMMY_PATH_LOG_PLAN" || \
  ! grep -Fq "## Status: Completed" "$DUMMY_PATH_LOG_PLAN" || \
  ! grep -Fq "make check" "$DUMMY_PATH_LOG_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$DUMMY_PATH_LOG_PLAN" || \
  ! grep -Fq "Paired-device delivery and live Logcat observation were not exercised" "$DUMMY_PATH_LOG_PLAN"; then
  printf '%s\n' "Dummy message path log redaction plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Dummy message path diagnostics omit peer-controlled path values" "$README" || \
  ! grep -Fq "Dummy Wear message path diagnostics must not include peer-controlled path values" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Keep dummy Wear path diagnostics free of peer-controlled path values" "$VISION" || \
  ! grep -Fq "Redacted peer-controlled paths from dummy Wear message diagnostics" "$CHANGES" || \
  ! grep -Fq "Dummy Wear path diagnostics must never include peer-controlled path values" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Dummy message path log redaction must remain documented." >&2
  exit 1
fi

for command_name in java javac; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf '%s\n' "Executable UTF-8 verification requires $command_name on PATH." >&2
    exit 1
  fi
done

utf8_test_dir=$(mktemp -d "${TMPDIR:-/tmp}/crashlytics-wear-utf8.XXXXXX")
trap 'rm -rf "$utf8_test_dir"' EXIT HUP INT TERM
javac -d "$utf8_test_dir" "$UTF8_CHECK"
java -cp "$utf8_test_dir" Utf8RoundTripCheck
rm -rf "$utf8_test_dir"
trap - EXIT HUP INT TERM

if ! grep -Fq 'private static final String MESSAGE = "caf\u00e9 \u6771\u4eac \ud83d\ude80";' "$UTF8_CHECK" ||
  ! grep -Fq 'byte[] encoded = MESSAGE.getBytes(UTF_8);' "$UTF8_CHECK" ||
  ! grep -Fq 'String decoded = new String(encoded, UTF_8);' "$UTF8_CHECK"; then
  printf '%s\n' "UTF-8 verification must retain its accented, CJK, and emoji round-trip fixture." >&2
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

for sender in "$WEAR_SERVICE" "$DUMMY_SERVICE"; do
  if grep -Eq 'Log\.[^;]*(getDisplayName|getStatusMessage)\(' "$sender"; then
    printf '%s\n' "Wear send outcome logs must not expose device names or raw status messages: ${sender#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for send_outcome_contract in \
  "$WEAR_SERVICE|Crashlytics send finished without status" \
  "$WEAR_SERVICE|Crashlytics report sent" \
  "$WEAR_SERVICE|Crashlytics report send failed" \
  "$DUMMY_SERVICE|Dummy message send finished without status" \
  "$DUMMY_SERVICE|Dummy message sent" \
  "$DUMMY_SERVICE|Dummy message send failed"; do
  sender=${send_outcome_contract%%|*}
  message=${send_outcome_contract#*|}
  if ! grep -Fq "\"$message\"" "$sender"; then
    printf '%s\n' "Wear sender must retain category diagnostic: $message" >&2
    exit 1
  fi
done

if [ ! -f "$SEND_OUTCOME_LOG_PLAN" ] || \
  ! grep -Fq "status: completed" "$SEND_OUTCOME_LOG_PLAN" || \
  ! grep -Fq "## Status: Completed" "$SEND_OUTCOME_LOG_PLAN" || \
  ! grep -Fq "make check" "$SEND_OUTCOME_LOG_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$SEND_OUTCOME_LOG_PLAN" || \
  ! grep -Fq "Paired-device delivery and live Logcat observation were not exercised" "$SEND_OUTCOME_LOG_PLAN"; then
  printf '%s\n' "Wear send outcome log redaction plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Wear send outcome logs omit paired-device names and raw provider status messages" "$README" || \
  ! grep -Fq "Wear send diagnostics must not expose paired-device display names or raw provider status messages" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Keep Wear send outcome logs limited to constant categories" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Redacted paired-device names and raw provider status messages from Wear send outcome logs" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq "Keep Wear send outcome logs free of paired-device names and raw provider status messages" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Repository guidance must document Wear send outcome log redaction." >&2
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

if grep -Eq 'Log\.[A-Za-z]+\([^;]*,[[:space:]]*ex[[:space:]]*\)' "$WEAR_UNCAUGHT_HANDLER" ||
  ! grep -Fq 'Log.e(MYLOGGER, "Uncaught exception received")' "$WEAR_UNCAUGHT_HANDLER"; then
  printf '%s\n' "Uncaught handler must log receipt without writing the throwable to Logcat." >&2
  exit 1
fi

if ! grep -Fq 'errorIntent.putExtra(CrashlyticsWearIntentService.EXTRA_DATA_ERROR, ex)' "$WEAR_UNCAUGHT_HANDLER" ||
  ! grep -Fq 'mDefaultUncaughtExceptionHandler.uncaughtException(thread, ex)' "$WEAR_UNCAUGHT_HANDLER"; then
  printf '%s\n' "Uncaught handler must preserve crash forwarding and previous-handler delegation." >&2
  exit 1
fi

if ! grep -Fq 'The Wear uncaught-exception handler records receipt without writing the throwable' "$README" ||
  ! grep -Fq 'Wear uncaught-exception handling must not write throwable stack traces to Logcat' "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq 'Keep uncaught Wear crash receipt logs free of throwable stack traces' "$VISION" ||
  ! grep -Fq 'Redacted the Wear uncaught-exception receipt log' "$CHANGES" ||
  ! grep -Fq 'Wear uncaught-exception receipt logs must never include the Throwable' "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Wear uncaught throwable redaction documentation must stay synchronized." >&2
  exit 1
fi

for plan_contract in \
  'status: completed' \
  '## Status: Completed' \
  '## Work Completed' \
  '## Verification Completed' \
  'both mobile and Wear variants reported zero lint issues' \
  'Eight isolated hostile mutations were rejected'; do
  if ! grep -Fq "$plan_contract" "$UNCAUGHT_LOG_PLAN"; then
    printf '%s\n' "Wear uncaught throwable redaction plan must keep completed evidence: $plan_contract" >&2
    exit 1
  fi
done

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

if ! grep -Fq "does not persist checkout credentials" "$README"; then
  printf '%s\n' "README must document the credential-free checkout boundary." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]+uses: actions/checkout@' "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "GitHub Actions must contain exactly one checkout step." >&2
  exit 1
fi

if ! awk '
  function finish_step() {
    if (checkout) {
      checkout_count++
      if (persist_credentials) {
        secure_checkout_count++
      }
    }
    checkout = 0
    with_block = 0
    persist_credentials = 0
  }

  /^      - / {
    finish_step()
  }

  /^        uses: actions\/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10([[:space:]]+#.*)?$/ {
    checkout = 1
  }

  checkout && /^        with:$/ {
    with_block = 1
  }

  checkout && with_block && /^          persist-credentials: false$/ {
    persist_credentials = 1
  }

  END {
    finish_step()
    exit !(checkout_count == 1 && secure_checkout_count == 1)
  }
' "$CI_WORKFLOW"; then
  printf '%s\n' "The pinned checkout step must disable persisted credentials." >&2
  exit 1
fi

if ! awk '
  /^permissions:$/ {
    permissions_count++
    in_permissions = 1
    next
  }

  in_permissions && /^[^[:space:]]/ {
    in_permissions = 0
  }

  in_permissions && /^  contents: read$/ {
    contents_read++
    next
  }

  in_permissions && /^  [[:alnum:]_-]+:/ {
    unexpected_permission++
  }

  END {
    exit !(permissions_count == 1 && contents_read == 1 && unexpected_permission == 0)
  }
' "$CI_WORKFLOW" ||
  grep -Eq '^[[:space:]]*permissions:[[:space:]]*write-all([[:space:]]*(#.*)?)?$' "$CI_WORKFLOW" ||
  grep -Eq '^[[:space:]]+[[:alnum:]_-]+:[[:space:]]*write([[:space:]]*(#.*)?)?$' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must grant only top-level read access to repository contents." >&2
  exit 1
fi

for workflow_contract in \
  "workflow_dispatch:" \
  "cancel-in-progress: true" \
  "runs-on: ubuntu-24.04" \
  "timeout-minutes: 15" \
  "run: scripts/verify-gradle-wrapper.sh" \
  "run: make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

if grep -Eq '^[[:space:]]*(ANDROID_HOME|ANDROID_SDK_ROOT):[[:space:]]*""' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must keep the hosted Android SDK visible to make check." >&2
  exit 1
fi

wrapper_validation_line=$(grep -nF "Validate Gradle wrapper provenance" "$CI_WORKFLOW" | cut -d: -f1)
sdk_install_line=$(grep -nF "Install Android SDK packages" "$CI_WORKFLOW" | cut -d: -f1)
java_setup_line=$(grep -nF "Set up Java 8" "$CI_WORKFLOW" | cut -d: -f1)
wrapper_behavior_line=$(grep -nF "Verify reviewed Gradle wrapper behavior" "$CI_WORKFLOW" | cut -d: -f1)
full_check_line=$(grep -nF "Run full Android verification" "$CI_WORKFLOW" | cut -d: -f1)
if [ -z "$wrapper_validation_line" ] || [ -z "$sdk_install_line" ] || \
   [ -z "$java_setup_line" ] || [ -z "$wrapper_behavior_line" ] || [ -z "$full_check_line" ] || \
   [ "$wrapper_validation_line" -ge "$sdk_install_line" ] || \
   [ "$sdk_install_line" -ge "$java_setup_line" ] || \
   [ "$java_setup_line" -ge "$wrapper_behavior_line" ] || \
   [ "$wrapper_behavior_line" -ge "$full_check_line" ]; then
  printf '%s\n' "GitHub Actions must validate wrapper provenance before executing it and running the full gate." >&2
  exit 1
fi

if ! grep -Eq '^status: (pending_hosted_verification|completed)$' "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "empty temporary Gradle user home" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "no repository artifact was requested over HTTP" "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Hosted Android verification plan must record implementation status and local evidence." >&2
  exit 1
fi

if grep -Fq "status: pending_hosted_verification" "$HOSTED_ANDROID_PLAN"; then
  if ! grep -Fq "Exact-head hosted checks remain pending." "$HOSTED_ANDROID_PLAN"; then
    printf '%s\n' "Pending hosted Android verification must state its exact-head boundary." >&2
    exit 1
  fi
elif ! grep -Fq "isolated hostile mutations were rejected" "$HOSTED_ANDROID_PLAN" || \
     ! grep -Fq "Exact-head push run" "$HOSTED_ANDROID_PLAN" || \
     ! grep -Fq "27662776027" "$HOSTED_ANDROID_PLAN" || \
     ! grep -Fq "pull-request run" "$HOSTED_ANDROID_PLAN" || \
     ! grep -Fq "27662790231" "$HOSTED_ANDROID_PLAN" || \
     ! grep -Fq "adda63a1efa0a47493df580b96221335ffad145f" "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Completed hosted Android verification must record mutations and both canonical runs." >&2
  exit 1
fi

if ! grep -Fq 'SDK-backed `make check` gate' "$ROOT_DIR/AGENTS.md" || \
   ! grep -Fq "then executes mobile and Wear" "$README" || \
   ! grep -Fq 'guarded SDK-backed `make check` baseline' "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "Keep SDK-backed mobile and Wear lint" "$VISION" || \
   ! grep -Fq "Forced the legacy JCenter artifact graph through HTTPS" "$CHANGES"; then
  printf '%s\n' "Maintained guidance must document secure hosted Android verification." >&2
  exit 1
fi

if ! grep -Fq 'group: check-${{ github.workflow }}-${{ github.ref }}' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must group superseded runs consistently." >&2
  exit 1
fi

if ! grep -Fq 'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE" ||
  [ "$(grep -c -- '--project-dir "$(ROOT)"' "$MAKEFILE")" -ne 4 ]; then
  printf '%s\n' "Make targets must protect and resolve Gradle and its project directory from the repository root." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "## Status: Completed" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq 'make ROOT=/tmp check' "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "five Make gates" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "external working directory" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "Four isolated hostile mutations were rejected" "$MAKE_ROOT_PROTECTION_PLAN"; then
  printf '%s\n' "Make root protection plan must record completed hostile-override and external verification." >&2
  exit 1
fi

if [ "$(grep -Ec '^verify:' "$MAKEFILE")" -ne 1 ] ||
  [ "$(grep -Fxc 'verify: lint test tasks build' "$MAKEFILE")" -ne 1 ] ||
  [ "$(grep -Ec '^check:' "$MAKEFILE")" -ne 1 ] ||
  [ "$(grep -Fxc 'check: verify baseline-test' "$MAKEFILE")" -ne 1 ] ||
  ! awk '
    /^baseline-test:$/ {
      rule_count++
      if (getline > 0 && $0 == "\t$(ROOT)scripts/test-check-baseline.sh") {
        recipe_count++
      }
    }
    END {
      exit !(rule_count == 1 && recipe_count == 1)
    }
  ' "$MAKEFILE"; then
  printf '%s\n' "Make check must retain the hostile mutation test dependency." >&2
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

if ! grep -Fq "Wear message senders reject missing or unsuccessful connected-node discovery results" "$README"; then
  printf '%s\n' "README must document connected-node discovery status guards." >&2
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

if ! grep -Fq "Connected-node discovery failures stop before either sender reads the node list" "$ROOT_DIR/AGENTS.md" ||
  ! grep -Fq "Validate connected-node discovery status before reading paired nodes" "$VISION" ||
  ! grep -Fq "Guarded both Wear senders against failed connected-node discovery results" "$CHANGES"; then
  printf '%s\n' "Connected-node discovery status guidance must remain synchronized." >&2
  exit 1
fi

if ! grep -Eq '^\*\*Status:\*\* (Pending hosted verification|Completed)$' "$NODE_DISCOVERY_PLAN" ||
  ! grep -Fq "six hostile node-discovery mutations" "$NODE_DISCOVERY_PLAN"; then
  printf '%s\n' "Node discovery status plan must record implementation and mutation evidence." >&2
  exit 1
fi

if grep -Fq "**Status:** Completed" "$NODE_DISCOVERY_PLAN" &&
  ! grep -Fq "Exact-head hosted Check and CodeQL passed." "$NODE_DISCOVERY_PLAN"; then
  printf '%s\n' "Completed node discovery status plan must record hosted evidence." >&2
  exit 1
fi

if ! grep -Fq "Wear message senders bound connection, node lookup, and per-node send waits" "$README"; then
  printf '%s\n' "README must document bounded Wear Data Layer waits." >&2
  exit 1
fi

if ! grep -Fq "Dummy text messages use UTF-8 on both Wear and mobile endpoints" "$README"; then
  printf '%s\n' "README must document the dummy-message UTF-8 wire format." >&2
  exit 1
fi

if ! grep -Fq 'Java 8 with `java` and `javac` on `PATH`' "$README"; then
  printf '%s\n' "README must document the JDK required by the executable baseline fixture." >&2
  exit 1
fi

if ! grep -Fq "dummy Wear-to-mobile text channel encode and decode explicitly" "$CHANGES" ||
  ! grep -Fq "Keep dummy Wear-to-mobile text messages on an explicit UTF-8 wire format" "$VISION"; then
  printf '%s\n' "Changelog and vision must document the dummy-message UTF-8 wire format." >&2
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

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Wear device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic exceptions and dummy messages' \
  'Paired node discovery' \
  'UTF-8 dummy message' \
  'Connection timeout' \
  'Node lookup timeout' \
  'Send timeout or failure' \
  'Declared CRASH report' \
  'Declared EXCEPTION report' \
  'Unsupported report type' \
  'Uncaught Wear exception' \
  'Metadata privacy' \
  'Live Crashlytics delivery' \
  'Do not convert `not run` into passing evidence.' \
  'API keys, project identifiers, device identifiers, full stack' \
  'every phone, Wear, pairing, transport, crash, and Crashlytics row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Wear device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'Crashlytics Wear device verification matrix' "$VISION" || \
   ! grep -Fq 'every external runtime row explicitly unexecuted' "$CHANGES"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Wear device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No paired Android/Wear devices, Data Layer transport, physical crash, private Crashlytics project, or live report delivery was exercised'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Wear device plan must keep completion evidence: $device_plan_contract" >&2
    exit 1
  fi
done

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

if ! grep -Fq "status: completed" "$UTF8_PLAN" ||
  ! grep -Fq "Eleven hostile mutations were rejected" "$UTF8_PLAN" ||
  ! grep -Fq 'make -f /absolute/path/Makefile check' "$UTF8_PLAN" ||
  ! grep -Fq "Paired-device behavior was not exercised" "$UTF8_PLAN"; then
  printf '%s\n' "Dummy-message UTF-8 plan must record completed local verification and its paired-device limit." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "## Status: Completed" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "## Work Completed" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "## Verification Completed" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "make check" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$DUMMY_PAYLOAD_LOG_PLAN" ||
  ! grep -Fq "Paired-device message delivery was not exercised" "$DUMMY_PAYLOAD_LOG_PLAN"; then
  printf '%s\n' "Dummy message payload log redaction plan must record completed status and verification." >&2
  exit 1
fi

printf '%s\n' "Crashlytics Wear build baseline checks passed."
