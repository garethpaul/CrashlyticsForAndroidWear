# Changes

## 2026-06-09

- Replaced internal wearable event Java object serialization with typed Intent
  extras for peer and message broadcasts.
- Guarded Wear crash and dummy Data Layer send loops against missing send
  results or status objects before reading status details.
- Disabled mobile and wear app-data backup in the checked-in manifests and
  added baseline coverage for the opt-out.
- Guarded Wear crash and dummy message senders against missing connected-node
  results and node ids before Data Layer sends.
- Removed mobile-side debug logging of reconstructed Wear throwable stack traces
  before forwarding reports to Crashlytics.
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
