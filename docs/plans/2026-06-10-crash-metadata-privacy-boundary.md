---
title: Crash Metadata Privacy Boundary
type: security
status: completed
date: 2026-06-10
---

# Crash Metadata Privacy Boundary

## Summary

Constrain the Wear-to-mobile Crashlytics bridge so a decoded wearable payload
cannot create arbitrary Crashlytics metadata keys, expose metadata values in
local logs, or forward the hardware serial identifier.

## Risks Addressed

- The mobile receiver previously iterated payload-provided keys and forwarded
  each value to Crashlytics without an explicit schema.
- Metadata values were written to Logcat before external reporting.
- `Build.SERIAL` added a persistent hardware identifier that is not required to
  diagnose this sample's crash flow.

## Work Completed

- Added a fixed mobile allowlist for the device metadata fields produced by the
  Wear sender.
- Treats non-string values for required or allowlisted fields as absent instead
  of allowing malformed metadata to terminate the receiver.
- Preserved the validated `REPORT_TYPE` as an explicit Crashlytics metadata
  field while ignoring payload-provided unknown keys.
- Removed metadata value logging from the mobile receiver.
- Removed hardware serial collection from the Wear report sender.
- Rooted Make targets to the repository, pinned CI to Ubuntu 24.04, and extended
  the source baseline to enforce these contracts.
- Updated README, SECURITY, VISION, and CHANGES with the privacy boundary.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME= ANDROID_SDK_ROOT= make check`
- `make -f /absolute/path/to/Makefile ANDROID_HOME= ANDROID_SDK_ROOT= check`
- Baseline mutation checks for unknown-key iteration, metadata logging,
  hardware serial collection, runner drift, and unrooted Make targets
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The legacy Gradle/Fabric dependency stack is intentionally not executed by
hosted CI. No Crashlytics report or external deployment was sent during this
maintenance pass.
