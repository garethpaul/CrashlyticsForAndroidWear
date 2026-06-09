---
title: Crashlytics Wear Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# Crashlytics Wear Check Wrapper

## Summary

Expose the Android Wear Crashlytics sample's source guard and documented
legacy Gradle gates through the shared root `make check` command.

## Requirements

- R1. Preserve `scripts/check-baseline.sh` as the first verification step.
- R2. Run Gradle lint, `check`, task listing, and debug assembly when
  `ANDROID_HOME` points to an installed Android SDK.
- R3. Keep SDK-missing behavior explicit rather than failing before source
  checks can run.
- R4. Document the wrapper in README and CHANGES.

## Verification

- `make check`
- `git diff --check`
