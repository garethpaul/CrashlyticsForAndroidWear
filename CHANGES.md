# Changes

## 2026-06-08

- Released Wear `DataEventBuffer` callbacks after validation to avoid retaining
  Google Play Services resources.
- Guarded Wear listener broadcaster and dummy receiver callbacks against
  missing peer, path, status, and payload data.
- Added a repository changelog for maintenance history.
- Made the legacy Gradle lint task a clean gate for both mobile and wear
  modules while preserving documented suppressions for the SDK 21 baseline.
- Replaced a boxed `Long` constructor in crash metadata collection with
  `Long.valueOf`.
