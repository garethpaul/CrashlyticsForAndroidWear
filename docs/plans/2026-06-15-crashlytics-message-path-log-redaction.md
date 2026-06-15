---
title: Crashlytics Message Path Log Redaction
status: planned
date: 2026-06-15
---

# Crashlytics Message Path Log Redaction

## Problem

`CrashlyticsWearableListenerReceiver` writes an unrecognized Wear message path
directly to Logcat. The path is supplied by the paired peer and may contain
user-controlled or application-sensitive data. The sibling dummy receiver now
uses a constant diagnostic category, but the Crashlytics receiver retains the
same value-bearing logging defect.

## Priority

1. Remove the remaining peer-controlled path value from Crashlytics receiver
   diagnostics.
2. Preserve `/crashlytics` routing, payload validation, report handling, and
   parent fallback behavior.
3. Keep broader wearable transport and dependency modernization separate from
   this narrow privacy boundary.

## Requirements

1. Keep the `/crashlytics` route and parent fallback behavior unchanged.
2. Replace the value-bearing unknown-path log with the constant category
   `Unknown crashlytics message path`.
3. Add a source contract scoped to the logging expression so legitimate
   `messageEvent.getPath()` routing remains allowed.
4. Synchronize privacy guidance and changelog evidence.
5. Run repository-root and external-directory full gates and prove the checker
   rejects hostile source, guidance, and plan mutations.

## Implementation Units

### Receiver diagnostic

Files:

- `mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearableListenerReceiver.java`

Replace only the unknown-path Logcat expression. Do not change route comparison,
payload parsing, report validation, or parent delegation.

### Portable contracts and guidance

Files:

- `scripts/check-baseline.sh`
- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

Require the constant category, reject `messageEvent.getPath()` in that logging
expression, preserve fallback dispatch, and record completed evidence.

## Verification Plan

- Demonstrate the focused checker fails on the current value-bearing log.
- Run `sh -n scripts/check-baseline.sh`, repository-root `make check`, and the
  complete gate through the absolute Makefile path from `/tmp`.
- Run isolated hostile mutations restoring the path value, removing the
  constant category, weakening guidance, and reverting plan completion.
- Audit the exact diff, explicit generated artifacts, dependency/workflow drift,
  whitespace, conflict markers, and added credential-shaped values.
- Record exact local/upstream, pull-request, hosted-check, and security-alert
  evidence after pushing.

## Scope Boundaries

- Do not alter the Wear message schema, report metadata, Crashlytics calls,
  transport timeouts, dependencies, manifests, or Gradle configuration.
- Do not remove path access used for routing.
- Do not claim paired-device delivery or live Logcat observation.

## Verification To Record

- Pre-fix focused failure and post-fix source contract.
- Root and external full gates.
- Hostile source, guidance, and completed-plan mutation rejection.
- Final diff, artifact, secret-pattern, and exact-head evidence.
