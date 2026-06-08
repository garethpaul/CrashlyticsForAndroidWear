---
title: Crashlytics Wear Build Baseline
type: fix
status: completed
date: 2026-06-08
---

# Crashlytics Wear Build Baseline

## Summary

Raise the baseline for the legacy Android Wear Crashlytics sample by removing
tracked IDE metadata, switching the Gradle wrapper to HTTPS, pinning dynamic
Fabric/Wear dependencies, removing the unused Wear support dependency,
allowing debug builds with a non-secret placeholder Crashlytics key,
aligning build-tools with the installed SDK, avoiding
Java object deserialization for wearable crash payloads, and adding a repeatable
source guard.

---

## Problem Frame

The repository tracked `.idea` and module `.iml` files, used an HTTP Gradle
wrapper URL, requested missing build-tools `21.1.1`, and used dynamic Gradle
dependencies such as `io.fabric.tools:gradle:1.+`,
`play-services-wearable:+`, and `com.google.android.support:wearable:+`.
Current Google Maven metadata no longer exposes the old Wear support `1.x`
artifact line, and the wear module does not import that UI library.
The crash forwarding path also serialized a `Throwable` object across the Wear
message boundary and deserialized it in the mobile app.

---

## Requirements

- R1. IDE and machine-local files must not be tracked.
- R2. The Gradle wrapper must fetch the legacy distribution over HTTPS.
- R3. Fabric and Play Services wearable dependencies must be pinned, and the
  unused legacy wearable support dependency must be removed.
- R4. Both modules must use an installed build-tools baseline.
- R5. Crashlytics API key metadata must remain an all-zero placeholder, not a
  committed secret.
- R6. Debug builds must not require a real Crashlytics API key.
- R7. Wear crash payloads must avoid Java object serialization/deserialization.
- R8. Manifest receivers for internal wear messages must not be exported.
- R9. Mobile lint must pass with only the legacy missing API database runner
  error suppressed.
- R10. README and a guard script must document and verify the baseline.

---

## Key Technical Decisions

- **Keep the old Gradle plugin:** This pass avoids a full Firebase/Fabric or
  Android Gradle Plugin migration.
- **Use build-tools 24.0.3:** Build-tools 19.1.0 is installed but its `aapt`
  binary cannot run on this host because the required 32-bit `libz.so.1` is not
  available. The installed 24.0.3 tools are host-compatible while keeping
  compile and target SDK 21 unchanged.
- **Pin legacy dependencies:** Dynamic `+` versions make old Android builds
  non-reproducible and can resolve to incompatible artifacts. The wear module
  does not use wearable support classes, so its unavailable support dependency
  is removed instead of pinned.
- **Gate Fabric debug resources:** Debug builds skip Fabric resource tasks only
  when the all-zero placeholder key is present, allowing compile checks without
  committing credentials.
- **Keep placeholder credentials:** Debug builds disable Crashlytics Gradle
  tasks so local verification does not require committing a real API key.
- **Send crash text, not objects:** String payloads avoid deserializing
  Java objects received from another device process.
- **Use a fake key format:** The old Fabric plugin validates API key shape
  during debug builds, so the committed value is all zeros rather than a real
  credential or a free-form placeholder string.

---

## Implementation Units

### U1. Repository Hygiene

- **Goal:** Remove IDE state and ignore local/generated files.
- **Files:** `.gitignore`, removed `.idea/`, root/module `.iml` files
- **Verification:** `scripts/check-baseline.sh`

### U2. Build Provenance

- **Goal:** Make the legacy dependency and wrapper inputs deterministic.
- **Files:** `build.gradle`, `gradle/wrapper/gradle-wrapper.properties`, `mobile/build.gradle`, `wear/build.gradle`, `mobile/src/main/AndroidManifest.xml`
- **Verification:** `scripts/check-baseline.sh`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew :mobile:lintDebug --no-daemon`

### U3. Crash Payload Safety

- **Goal:** Avoid object deserialization and reduce receiver exposure.
- **Files:** `wear/src/main/java/.../CrashlyticsWearIntentService.java`, `mobile/src/main/java/.../CrashlyticsWearableListenerReceiver.java`, `mobile/src/main/AndroidManifest.xml`
- **Verification:** `scripts/check-baseline.sh`

### U4. Documentation and Guard

- **Goal:** Leave a repeatable source-level gate and clear modernization notes.
- **Files:** `README.md`, `mobile/lint.xml`, `scripts/check-baseline.sh`, this plan
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

---

## Risks & Dependencies

- The project still depends on deprecated Fabric Crashlytics and old Android
  Gradle Plugin behavior.
- Full build verification may still be limited by old repositories and
  discontinued Fabric artifacts.
- Runtime crash forwarding needs device or emulator verification.

---

## Sources / Research

- `mobile/build.gradle` defines Fabric and mobile wearable dependencies.
- `wear/build.gradle` defines the Wear Play Services dependency.
- `mobile/src/main/AndroidManifest.xml` contains the Crashlytics API key placeholder.
- `gradle/wrapper/gradle-wrapper.properties` owns the Gradle distribution URL.
