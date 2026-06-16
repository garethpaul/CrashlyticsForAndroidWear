# Peer Display Name Log Redaction

## Status: In Progress

## Context

`WearableListenerBroadcaster` writes `peer.getDisplayName()` to phone Logcat
when a paired Wear node connects or disconnects. The display name is controlled
by the paired device and can contain user-identifying or attacker-selected text.
The value is still required in the package-scoped event broadcast.

## Objectives

- Replace connect and disconnect diagnostics with constant categories.
- Preserve peer display-name and node-ID broadcast extras and event types.
- Keep null-peer guards and superclass callback ordering unchanged.
- Make the redaction and routing boundary mutation-sensitive in the portable
  baseline.

## Scope

- Update `WearableListenerBroadcaster.java` and `scripts/check-baseline.sh`.
- Document the peer-display-name privacy boundary in `AGENTS.md`, `README.md`,
  `SECURITY.md`, `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused portable baseline validation
- Repository-root and external-directory `make check`
- Isolated mutations restoring display-name logging, removing routing extras,
  removing guidance, or reopening the plan
- `git diff --check`
- Exact-path, generated-artifact, sensitive-value, conflict-marker, and
  file-mode audits

## Risks

- The broadcast must continue carrying `EXTRA_NODE_DISPLAY_NAME` for existing
  package-local consumers.
- Source validation cannot reproduce paired-device callbacks or phone Logcat.
- This PR is stacked on PR #13 and must retain base-first merge ordering.

## Out Of Scope

- Peer identifier storage, broadcast schema changes, Wear transport behavior,
  dependency/toolchain upgrades, and workflow changes.
