# Changes

## 2026-06-09

- Removed local debug logging of Wear throwable stack traces before forwarding
  Crashlytics reports to the paired phone.
- Allowed Wear crash reports through the sender only when their report type is
  one of the declared `CRASH` or `EXCEPTION` values.
- Guarded mobile Crashlytics report forwarding against decoded Wear payloads
  that are missing `REPORT_TYPE`.

## 2026-06-08

- Added `make check` as the root wrapper for source, lint, Gradle check,
  task-listing, and debug build verification.
- Released Wear `DataEventBuffer` callbacks after validation to avoid retaining
  Google Play Services resources.
- Guarded Wear listener broadcaster and dummy receiver callbacks against
  missing peer, path, status, and payload data.
- Added a repository changelog for maintenance history.
- Made the legacy Gradle lint task a clean gate for both mobile and wear
  modules while preserving documented suppressions for the SDK 21 baseline.
- Replaced a boxed `Long` constructor in crash metadata collection with
  `Long.valueOf`.
