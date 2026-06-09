---
title: Wear DataEventBuffer Release
type: fix
status: completed
date: 2026-06-08
---

# Wear DataEventBuffer Release

## Summary

Release Wear `DataEventBuffer` callback resources after validation and callback
handling so data-change events do not retain Google Play Services buffers.

## Requirements

- R1. `onDataChanged` continues to guard null buffers and missing status.
- R2. Valid data-change callbacks still delegate to the superclass.
- R3. Non-null buffers are released in a `finally` path.
- R4. README, changelog, and source baseline document the lifecycle guard.
- R5. Legacy source, lint, check, task listing, and debug assemble gates remain green when the Android toolchain resolves.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew check --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
