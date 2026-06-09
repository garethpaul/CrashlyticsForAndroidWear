# Mobile Throwable Log Redaction

Status: Completed
Date: 2026-06-09

## Goal

Avoid logging reconstructed Wear throwable stack traces in the mobile app before
forwarding crash reports to Crashlytics.

## Changes

- Replaced the mobile receipt debug log that included the reconstructed
  `RuntimeException` with a non-sensitive report type log.
- Kept the reconstructed throwable as the Crashlytics payload so reporting
  behavior stays intact.
- Extended the SDK-free baseline, README, changelog, and vision with the mobile
  logging contract.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make tasks`
- `make build`
- `make check`
- `git diff --check`

Full paired-device crash forwarding still requires the legacy Android/Wear
toolchain and paired mobile/wear devices or emulators.
