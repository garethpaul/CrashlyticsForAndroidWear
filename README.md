# CrashlyticsForAndroidWear

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/CrashlyticsForAndroidWear` is an Android application or sample. An example of Crashlytics implementation in an Android Wear Project.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (13).

## Repository Contents

- `README.md` - project overview and local usage notes
- `build.gradle` - Android or Gradle build configuration
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `mobile` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails
- `wear` - source or example code

Additional scan context:

- Source directories: gradle, mobile, wear
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test-looking files: mobile/src/androidTest/java/loreto/di/arno/crashlyticsforandroidwear/ApplicationTest.java

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Gradle or the checked-in Gradle wrapper when present

### Setup

```bash
git clone https://github.com/garethpaul/CrashlyticsForAndroidWear.git
cd CrashlyticsForAndroidWear
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

Run the source-level baseline guard before committing:

```bash
scripts/check-baseline.sh
```

When the legacy Android toolchain can resolve all discontinued artifacts, use:

```bash
ANDROID_HOME=/path/to/android-sdk ./gradlew tasks --no-daemon
ANDROID_HOME=/path/to/android-sdk ./gradlew assembleDebug --no-daemon
```

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- The committed Crashlytics API key is an all-zero placeholder that lets the
  legacy Gradle plugin run without storing a real Fabric credential.
- Replace the placeholder only in local, private configuration when testing
  against a real Crashlytics/Fabric project.

## Security and Privacy Notes

- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include mobile/src/main/AndroidManifest.xml.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include gradle.properties, mobile/build.gradle, mobile/src/androidTest/java/loreto/di/arno/crashlyticsforandroidwear/ApplicationTest.java, mobile/src/main/AndroidManifest.xml, and 3 more.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include gradlew, mobile/src/main/AndroidManifest.xml.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/activities/MainActivity.java, mobile/src/main/res/layout/main_activity.xml, mobile/src/main/res/values-v21/styles.xml, wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/activities/MainWearActivity.java, and 3 more.
- Review changes touching database, model, or persistence code; examples from the scan include wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java.

## Maintenance Notes

- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- The Gradle wrapper is intentionally kept on the legacy 1.12 distribution, but
  it must use HTTPS. Fabric and Play Services Wear dependencies are pinned to
  avoid dynamic resolution drift, and the unused legacy wearable support
  dependency is intentionally removed.
- Debug builds disable Fabric resource tasks while the all-zero Crashlytics API
  key placeholder is present. Use local untracked configuration for real
  Crashlytics credentials when testing against Fabric.
- Wear crash forwarding sends stack traces as text, package-scopes internal
  broadcasts, and disconnects GoogleApiClient clients after message sends.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.

## Existing Project Notes

Prior README summary:

> CrashlyticsForAndroidWear <!-- README-OVERVIEW-IMAGE --> CrashlyticsForAndroidWear ========================= An example of Crashlytics implementation in an Android Wear Project. The purpose of the demo app is to show how you can implement Crahslytics on the wear device. This implementations try to avoid mixing Crashlytics report handling and other message. Context
