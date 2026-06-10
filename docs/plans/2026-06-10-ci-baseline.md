---
title: Crashlytics For Android Wear CI Baseline
type: chore
status: completed
date: 2026-06-10
---

# Crashlytics For Android Wear CI Baseline

## Summary

Run the existing mobile/wear source baseline in GitHub Actions so Crashlytics
credential, report-type, broadcast, and wearable send-result guards run before
review.

Keep the hosted runner from invoking Gradle 1.12 or discontinued Fabric and
JCenter dependencies through ambient Android SDK configuration.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Cleared `ANDROID_HOME` and `ANDROID_SDK_ROOT` so hosted runners take the
  intentional SDK-free path.
- Pinned `actions/checkout` to a reviewed commit, limited repository access to
  read-only, and bounded runs with a timeout and concurrency cancellation.
- Reused the existing guarded Makefile targets so hosted runners still execute
  SDK-free checks when the legacy Android SDK is unavailable.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed maintenance plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add Android SDK-backed CI after the legacy SDK, Google APIs target, and
  discontinued Fabric artifact setup are documented for hosted runners.
