---
title: Dummy Message Path Log Redaction
status: completed
date: 2026-06-15
---

# Dummy Message Path Log Redaction

## Problem

`DummyWearableListenerReceiver` writes an unrecognized Wear message path directly to
Logcat. The path is supplied by the paired peer and may contain user-controlled or
application-sensitive data. The receiver already forwards unknown paths to its
parent, so diagnostics do not need the path value to preserve behavior.

## Requirements

1. Keep the `/dummy` routing and parent fallback behavior unchanged.
2. Replace the value-bearing unknown-path log with a constant diagnostic category.
3. Add a source contract that rejects restoration of `messageEvent.getPath()` in
   the unknown-path log expression.
4. Synchronize the repository privacy guidance and changelog.
5. Verify the repository-root and external-directory gates, then prove the source
   contract rejects hostile mutations.

## Implementation

- Update `DummyWearableListenerReceiver` to log only `Unknown dummy message path`.
- Extend `scripts/check-baseline.sh` with a logging-expression-specific redaction
  contract while preserving path access for routing.
- Record the boundary in `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, and
  `CHANGES.md`.

## Verification Plan

- `sh -n scripts/check-baseline.sh`
- `make check`
- `make -C /tmp -f <worktree>/Makefile check`
- Isolated mutations restoring the path value, removing the constant category,
  weakening guidance, or falsifying plan completion evidence
- Exact diff, generated-artifact, conflict-marker, whitespace, and credential scans

## Status: Completed

## Work Completed

- Replaced the value-bearing unknown-path Logcat expression with the constant
  `Unknown dummy message path` category.
- Preserved `/dummy` routing and parent fallback handling for unknown paths.
- Added source, completed-plan, and synchronized privacy-guidance contracts to
  `scripts/check-baseline.sh`.

## Verification Completed

- `sh -n scripts/check-baseline.sh` passed.
- The focused source contract passed and preserved parent fallback handling.
- SDK-backed immutable snapshot tests, Gradle `check`, task discovery, mobile/wear
  lint with zero issues, and both debug APK assemblies passed.
- The clean static-check fixture passed and seven isolated hostile mutations were rejected.
- Repository-root and external-directory `make check` both passed.
- Paired-device delivery and live Logcat observation were not exercised.
