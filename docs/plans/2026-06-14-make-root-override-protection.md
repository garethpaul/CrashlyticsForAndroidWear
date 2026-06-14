---
title: Make Root Override Protection
type: reliability
status: completed
date: 2026-06-14
---

# Make Root Override Protection

## Status: Completed

## Problem Frame

The Makefile derives its root from `MAKEFILE_LIST`, and the baseline checker
requires that assignment, but command-line variables can still override it.
That redirects both repository scripts and SDK-backed Gradle commands.

## Scope Boundaries

- Protect only the repository-derived `ROOT`; preserve the intentional
  `ANDROID_HOME` and `GRADLE` overrides.
- Preserve the reviewed Gradle wrapper, Android manifests, dependencies,
  privacy contracts, Wear protocol, and application behavior.
- Do not add credentials or run paired-device Crashlytics delivery.

## Requirements

- R1. A hostile `ROOT` variable must not redirect scripts or Gradle.
- R2. Repository and external-working-directory verification must pass.
- R3. The existing Make-root checker contract must require the protected form.
- R4. Completed plan evidence and isolated mutations must be enforced.

## Verification

- `sh -n scripts/check-baseline.sh`, `dash -n
  scripts/check-baseline.sh`, and `sh -n scripts/test-wear-event-snapshots.sh`
  passed.
- All five Make gates passed through `make lint`, `make test`, `make tasks`,
  `make build`, and `make check`.
- Android lint reported zero issues for mobile and Wear, Gradle checks and task
  discovery passed, and both debug APKs assembled with the configured SDK.
- `make ROOT=/tmp check` passed and still used repository scripts and Gradle
  project paths.
- The full gate passed from `/tmp` through the absolute Makefile path, covering
  the external working directory.
- Four isolated hostile mutations were rejected: overrideable root, missing
  plan, reopened plan, and missing verification evidence.
- `git diff --check`, intended-path review, artifact inspection, and the
  changed-line secret scan passed.
- No paired-device crash delivery or live Crashlytics/Fabric credential flow
  was exercised.
