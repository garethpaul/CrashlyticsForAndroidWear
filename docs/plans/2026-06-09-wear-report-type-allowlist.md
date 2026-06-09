# Wear Report Type Allowlist

Status: Completed
Date: 2026-06-09

## Goal

Keep Wear-originated Crashlytics reports constrained to the declared report
types before they are serialized and sent to the mobile app.

## Changes

- Rejected missing or empty report type extras in the Wear intent service.
- Added an allowlist helper for the declared `CRASH` and `EXCEPTION` report
  types.
- Rejected unsupported report types before building the outgoing `DataMap`.
- Extended the SDK-free baseline, README, changelog, and vision with the Wear
  report type contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint --no-daemon`
- `./gradlew check --no-daemon`
- `./gradlew tasks --no-daemon`
- `./gradlew assembleDebug --no-daemon`
- `git diff --check`
