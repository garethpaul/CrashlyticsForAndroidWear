---
title: Gradle Lint Baseline
type: fix
status: completed
date: 2026-06-08
---

# Gradle Lint Baseline

## Summary

Make `./gradlew lint` a clean verification gate for the legacy mobile and wear
modules, add the required repository changelog, and preserve the intentional
legacy SDK baseline through explicit lint configuration.

## Requirements

- R1. `CHANGES.md` must record the maintenance history for this pass.
- R2. Mobile and wear modules must both have checked-in lint configuration.
- R3. The lint configuration must suppress only the old lint runner API
  database error and the intentional `targetSdkVersion 21` modernization
  warning.
- R4. `CrashlyticsWearIntentService` must avoid direct boxed primitive
  constructors flagged by lint.
- R5. README and source baseline checks must document and preserve
  `./gradlew lint` as the lint gate.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew check --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
