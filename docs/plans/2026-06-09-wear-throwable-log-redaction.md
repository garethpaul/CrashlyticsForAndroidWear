# Wear Throwable Log Redaction

Status: Completed
Date: 2026-06-09

## Goal

Avoid logging wearable throwable stack traces locally before forwarding crash
reports to the paired mobile app.

## Changes

- Replaced the debug log that included the full `Throwable` with a non-sensitive
  receipt log.
- Kept crash report serialization through `throwableToString` so the paired
  phone still receives the report payload.
- Extended the SDK-free baseline, README, changelog, and vision with the
  throwable logging contract.

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
