# Wear Data Layer Send Timeouts

## Status: Completed

The original per-operation timeout was superseded on 2026-06-26 by
[`2026-06-26-shared-data-layer-deadline.md`](2026-06-26-shared-data-layer-deadline.md),
which applies one deadline across the full send lifecycle.

## Goal

Bound Google Play Services connection, connected-node discovery, and per-node
message sends so Wear crash forwarding and dummy message services cannot wait
indefinitely.

## Problem

Both Wear `IntentService` senders use unbounded `blockingConnect()` and
`PendingResult.await()` calls. A stalled Play Services connection or paired node
can therefore occupy the service worker forever, preventing later reports or
messages from being processed and delaying service shutdown.

## Scope

- Add an explicit five-second Data Layer timeout to both sender services.
- Apply it to GoogleApiClient connection, connected-node lookup, and every
  message send result.
- Preserve existing null/status guards, per-node iteration, and `finally`
  disconnect behavior.
- Extend the SDK-free baseline and maintenance documentation for the deadline
  contract.

## Out Of Scope

- Adding retries, queues, persistence, or changing report payloads.
- Modernizing Google Play Services, Gradle, Fabric, or Android SDK versions.
- Changing mobile receiver or Crashlytics metadata behavior.

## Verification

- `make check`
- `sh -n scripts/check-baseline.sh`
- Targeted baseline mutation checks
- `git diff --check`

Paired Wear/mobile runtime verification still requires compatible devices or
emulators and the repository's legacy Android dependency stack.
