# Mobile Report Type Allowlist

Status: Completed
Date: 2026-06-09

## Goal

Keep decoded Wear Crashlytics reports from reaching mobile Crashlytics metadata
or exception forwarding unless their report type is one of the declared values.

## Changes

- Added a mobile-side allowlist for the declared `CRASH` and `EXCEPTION`
  report types.
- Rejected unsupported decoded report types before writing Crashlytics metadata
  or forwarding the reconstructed throwable.
- Extended the source baseline to require the mobile allowlist, README note,
  and completed plan.
- Documented the allowlist in the README, changelog, and vision.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint --no-daemon`
- `./gradlew check --no-daemon`
- `./gradlew tasks --no-daemon`
- `./gradlew assembleDebug --no-daemon`
- `git diff --check`
