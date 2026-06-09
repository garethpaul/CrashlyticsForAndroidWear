# Wear Event Intent Extras

Status: Completed
Date: 2026-06-09

## Goal

Keep internal mobile Wear listener broadcasts from using Java object
serialization for peer and message events.

## Context

The mobile `WearableListenerBroadcaster` previously serialized copied
`MessageEvent` and `Node` objects into byte arrays before broadcasting them to
package-local receivers. Even though the receivers are non-exported and the
broadcast is package-scoped, Java object deserialization is unnecessary for
these small payloads and creates a fragile parsing surface.

## Changes

- Replaced serialized event byte arrays with typed Intent extras for message
  paths, message data, request ids, source node ids, node ids, and display
  names.
- Rebuilt copied `MessageEvent` and `Node` receiver objects from those extras
  instead of using `ObjectInputStream`.
- Removed Java serialization interfaces and streams from the copied event
  helpers.
- Extended the baseline checker and documentation to preserve the Intent extra
  contract.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
