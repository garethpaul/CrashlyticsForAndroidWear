# Android Backup Opt Out

Status: Completed
Date: 2026-06-09

## Goal

Keep the mobile and wear modules from backing up crash-forwarding app state by
default.

## Context

The sample forwards crash reports from a wear device to a paired phone.
Forwarded reports may include stack traces and device details, so the checked-in
manifests should fail closed and avoid platform app-data backup unless a
maintainer deliberately changes that boundary.

## Changes

- Set `android:allowBackup="false"` in the mobile manifest.
- Set `android:allowBackup="false"` in the wear manifest.
- Extended the source baseline checker to reject backup opt-ins in either
  manifest.
- Documented the opt-out in README, SECURITY, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
