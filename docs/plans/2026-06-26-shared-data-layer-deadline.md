# Shared Wear Data Layer Deadline

## Status: Completed

## Goal

Give each Wear sender one monotonic five-second budget covering Google API
connection, connected-node discovery, and every per-node message send.

## Problem

The existing timeout guarded each blocking call independently. A connection,
node lookup, and multiple paired-node sends could therefore each consume five
seconds, making total `IntentService` blocking time grow with node count.

## Implementation

- Add a Java 7-compatible `DataLayerDeadline` helper that calculates remaining
  nanoseconds from a monotonic start time.
- Capture one start time per send operation and pass only the remaining budget
  to connection, discovery, and send waits.
- Stop with constant diagnostics when the shared deadline is exhausted.
- Keep existing result guards, node validation, payload handling, and client
  disconnection behavior unchanged.

## Verification

- `scripts/test-data-layer-deadline.sh` covers the full budget, elapsed budget,
  expiry, and invalid-budget cases without requiring an Android SDK.
- `scripts/check-baseline.sh` rejects fresh per-operation timeout budgets and
  requires both senders to consume one monotonic five-second budget.
- `make check`
- External-working-directory `make check`
- Hostile source and helper mutations
- `git diff --check`

Paired-device runtime behavior remains subject to the legacy Android and Google
Play Services environment used by the hosted SDK-backed check.
