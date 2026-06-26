# Changes

## 2026-06-26

- Wear uncaught-exception forwarding failures cannot bypass previous default-handler delegation.
- Wear connection, node discovery, and per-node sends consume one shared five-second deadline
  in both Wear IntentServices, preventing blocking lifetime from scaling with paired nodes.
- Added a Java 7 host fixture and source contracts for monotonic deadline accounting.
- Validated the implementation head with local and external-working-directory
  checks, three hostile deadline mutations, duplicate hosted Android checks,
  CodeQL Actions and Java/Kotlin analysis, and a clean immutable manual review;
  the required Codex reviewer failed with HTTP 401 before analysis.

## 2026-06-25

- Guarded both Wear senders against failed connected-node discovery results
  before reading or iterating paired nodes.
- Initialized mobile Crashlytics from the application process before cold Wear
  report delivery, while retaining an idempotent activity compatibility path.
- Added portable source and mutation contracts for process-owned initialization.

## 2026-06-19

- Validated the committed Gradle wrapper against Gradle's published checksum
  before any hosted wrapper execution.
- Snapshotted Wear message events before placing their mutable payload bytes on
  the asynchronous broadcast boundary.

## 2026-06-17

- Forced the legacy JCenter artifact graph through HTTPS and made GitHub
  Actions install Android API 21 and build-tools 24.0.3 before running the full
  mobile and Wear gate under Corretto 8.

## 2026-06-16

- Wear data-event diagnostics omit raw provider status messages while preserving status guards and buffer release.
- The mobile Wear event broadcaster keeps paired-peer message paths out of Logcat while preserving package-scoped routing.
- Wear peer connection diagnostics omit paired-device display names while preserving package-scoped node extras.
- Redacted parser exception details from malformed Crashlytics payload diagnostics.

## 2026-06-15

- Redacted peer-controlled paths from dummy Wear message diagnostics while
  preserving unknown-path parent fallback handling.
- Redacted peer-controlled paths from Crashlytics Wear message diagnostics while
  preserving unknown-path parent fallback handling.
- Redacted paired-device names and raw provider status messages from Wear send outcome logs.
- Removed decoded dummy Wear message payloads from mobile Logcat receipt diagnostics
  while preserving explicit UTF-8 decoding and path-level error handling.

## 2026-06-14

- Added an exact-head paired-device and Crashlytics verification matrix with
  privacy-safe evidence fields and every external runtime row explicitly unexecuted.

## 2026-06-13

- Redacted the Wear uncaught-exception receipt log while preserving crash report
  forwarding and previous default-handler delegation.
- Made broadcast message and node wrappers immutable snapshots with final
  fields and no public mutators.
- Defensively copied Wear message payload bytes on construction and access, and
  added an SDK-independent executable Java contract for aliasing and shape.
- Made the dummy Wear-to-mobile text channel encode and decode explicitly as
  UTF-8, with an executable accented, CJK, and emoji round-trip fixture.

## 2026-06-12

- Added an authenticated Gradle wrapper with generated bootstrap artifacts,
  exact artifact contracts, and the official Gradle 1.12 distribution checksum.
- Made every Android component export policy explicit across the mobile and
  Wear manifests, constrained the Play Services listener action, and retained
  only the service-local legacy exported-service lint annotation.
- Added five-second deadlines to Wear GoogleApiClient connection, connected-node
  discovery, and each crash or dummy message send.
- Extended the SDK-free baseline and maintenance notes to reject unbounded Data
  Layer waits in both sender services.

## 2026-06-10

- Restricted mobile Crashlytics metadata forwarding to a declared key
  allowlist, removed metadata value logging, and stopped collecting the Wear
  hardware serial identifier.
- Rooted Make targets to the repository and pinned the hosted check runner to
  Ubuntu 24.04.
- Added a lightweight GitHub Actions workflow that runs `make check` for the
  Crashlytics mobile/wear baseline.
- Pinned the checkout action, disabled persisted checkout credentials, limited
  repository access to read-only, and cleared hosted Android SDK variables for
  deterministic SDK-free checks.
- Extended the SDK-free baseline to require the CI workflow and completed CI
  plan.

## 2026-06-09

- Allowed mobile Crashlytics report forwarding only for declared `CRASH` or
  `EXCEPTION` report types.
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
