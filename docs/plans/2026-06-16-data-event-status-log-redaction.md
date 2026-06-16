# Data Event Status Log Redaction

## Status: Completed

## Context

`WearableListenerBroadcaster.onDataChanged` writes
`DataEventBuffer.getStatus().getStatusMessage()` to phone Logcat. The status
message is supplied by Google Play services and can contain provider-controlled
diagnostic detail that is not required for event validation or routing.

## Objectives

- Replace the raw status-message interpolation with a constant data-change
  category.
- Preserve null-buffer and missing-status guards.
- Preserve `super.onDataChanged(dataEvents)` ordering and unconditional
  `DataEventBuffer.release()` ownership.
- Make the privacy and lifecycle boundary mutation-sensitive in the portable
  baseline.

## Scope

- Update `WearableListenerBroadcaster.java` and `scripts/check-baseline.sh`.
- Document the data-event status privacy boundary in `AGENTS.md`, `README.md`,
  `SECURITY.md`, `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused portable baseline validation
- Repository-root and external-directory `make check`
- Isolated mutations restoring status-message logging, removing lifecycle
  ownership, removing guidance, or reopening the plan
- `git diff --check`
- Exact-path, generated-artifact, sensitive-value, conflict-marker, and
  file-mode audits

## Risks

- The broadcaster must continue rejecting missing status and releasing every
  non-null `DataEventBuffer` callback.
- Source validation cannot reproduce Play services data-event callbacks or
  phone Logcat.
- This PR is stacked on PR #14 and must retain base-first merge ordering.

## Out Of Scope

- Data-event routing implementation, Wear transport behavior, dependency or
  toolchain upgrades, provider status handling outside Logcat, and workflow
  changes.

## Verification Results

- `sh -n scripts/check-baseline.sh` and the focused portable baseline passed.
- Six isolated data-status mutations were rejected: restored status-message
  interpolation, removed missing-status guard, removed superclass callback,
  removed buffer release, removed maintained guidance, and reopened plan
  status.
- Repository-root and external-directory `make check` both passed with the
  baseline contracts, immutable Wear event snapshots, Android lint/check, task
  discovery, and debug assemblies successful for the mobile and Wear modules.
- No emulator, physical wearable, paired transport, or live data-event callback
  was exercised; runtime and Logcat verification remain in the device matrix.
