---
title: Crashlytics Report Type Guard
type: fix
status: completed
date: 2026-06-09
---

# Crashlytics Report Type Guard

## Summary

Reject decoded Wear Crashlytics payloads that are missing `REPORT_TYPE` before
logging metadata or forwarding the exception into Crashlytics on the mobile
module.

## Problem Frame

The wear sender validates that each crash forwarding intent has both a
`Throwable` and a report type before building its `DataMap`. The mobile
receiver already rejects missing payload bytes, malformed `DataMap` bytes, and
payloads without `ERROR`, but a forged or corrupted-yet-decodable `DataMap`
could still reach Crashlytics without a report type.

## Requirements

- R1. Mobile Crashlytics reports must require non-empty `REPORT_TYPE`.
- R2. Missing report types must return before `Crashlytics.setBool`,
  `Crashlytics.setString`, or `Crashlytics.logException`.
- R3. README, changelog, and the source baseline must document and preserve the
  receiver-side report type guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
