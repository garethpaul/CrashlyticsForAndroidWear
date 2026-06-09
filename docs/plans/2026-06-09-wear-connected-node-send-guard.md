# Wear Connected Node Send Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep Wear-side crash and dummy message forwarding from failing when Google Play
Services returns missing connected-node metadata.

## Changes

- Rejected missing send paths or payloads before opening a GoogleApiClient.
- Guarded missing connected-node results before reading the node list size.
- Skipped connected nodes without ids before calling the Wear message API.
- Extended the source baseline, README, changelog, and vision with the
  connected-node send contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint --no-daemon`
- `./gradlew check --no-daemon`
- `./gradlew tasks --no-daemon`
- `./gradlew assembleDebug --no-daemon`
- `git diff --check`
