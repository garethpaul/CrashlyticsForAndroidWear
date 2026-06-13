---
title: Wear Uncaught Throwable Log Redaction
type: security
status: completed
date: 2026-06-13
---

# Wear Uncaught Throwable Log Redaction

## Status: Completed

## Problem Frame

The Wear uncaught-exception handler forwards crashes to the paired phone but
first passes the complete `Throwable` to Android Logcat. That bypasses the
repository's existing rule that Wear stack traces travel only in the report
payload and are not duplicated into local logs.

## Scope Boundaries

- Replace only the uncaught-handler throwable log with a non-sensitive receipt
  message.
- Preserve the forwarded throwable extra, report type, service start, null
  guards, and previous default-handler delegation exactly.
- Extend the SDK-free source contract and privacy documentation.
- Do not change Crashlytics credentials, manifests, dependencies, workflows,
  or paired-device protocol behavior.

## Requirements

- R1. `uncaughtException` must not pass its `Throwable` to `Log.e` or another
  Android logging call.
- R2. A non-sensitive receipt log must remain so crash-handler execution is
  diagnosable without exposing the stack trace.
- R3. The same throwable must still be attached to
  `CrashlyticsWearIntentService.EXTRA_DATA_ERROR` and delivered to the prior
  default uncaught-exception handler.
- R4. Static contracts must reject throwable-log restoration, receipt-message
  deletion, forwarding drift, documentation drift, and stale plan evidence.

## Implementation

- Update `CrachlyticsWearUncaughtExceptionHandler` to log receipt without the
  throwable overload.
- Add exact source and documentation contracts to `scripts/check-baseline.sh`.
- Synchronize README, SECURITY, CHANGES, VISION, AGENTS, and this plan.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make tasks`
- `make build`
- `make check`
- Absolute-path `make check` from `/tmp`
- SDK-backed Gradle lint, checks, task discovery, and debug APK assembly when
  the configured Android SDK remains available
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations for throwable-log restoration, receipt deletion,
  forwarding drift, documentation drift, stale plan status, and missing
  verification evidence

## Risks

- The handler runs on a fatal path, so the change must not introduce formatting,
  allocation, or exception-prone work beyond the existing constant log call.
- Full paired-device crash delivery remains outside local validation.

## Work Completed

- Replaced the Wear uncaught-handler throwable overload with a constant receipt
  message that does not expose exception text or stack frames to Logcat.
- Preserved the original throwable in the crash service intent and in previous
  default-handler delegation.
- Added source, documentation, and completed-plan contracts for the privacy
  boundary.

## Verification Completed

- `scripts/check-baseline.sh`, `make lint`, `make test`, `make tasks`,
  `make build`, and `make check` passed.
- The absolute-path `make check` wrapper passed from `/tmp`.
- Android lint: both mobile and Wear variants reported zero lint issues.
- Gradle checks and task discovery passed, and both debug APKs assembled
  successfully with the configured Android SDK.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Eight isolated hostile mutations were rejected across throwable logging,
  receipt presence, report forwarding, previous-handler delegation,
  documentation, plan status, and verification evidence.
- Paired-device crash delivery was not exercised; protocol payloads, manifests,
  dependencies, credentials, and workflows are unchanged.
