# Broadcaster Message Path Log Redaction

## Status: Completed

## Context

The mobile `WearableListenerBroadcaster` logs `messageEvent.getPath()` before
dispatching a paired wearable message. Both downstream receivers already use
constant unknown-path diagnostics, but this upstream interpolation still
exposes paired-peer-controlled message paths in phone Logcat.

## Objectives

- Replace the path-bearing broadcaster diagnostic with a constant category.
- Preserve path validation, copied intent extras, package-scoped dispatch, and
  receiver routing behavior.
- Add a mutation-sensitive source contract for the exact logging expression.

## Scope

- Update `WearableListenerBroadcaster.java`, `scripts/check-baseline.sh`, and
  maintained privacy guidance.
- Do not change event payloads, receiver behavior, manifests, dependencies, or
  workflows.

## Verification

- `sh -n scripts/check-baseline.sh`
- Repository-root and external-directory `make check`
- Hostile mutations restoring path interpolation, removing guidance, and
  reopening plan status
- Exact-path, artifact, secret, binary, workflow, and whitespace audits

## Risks

- The path must remain available in the package-scoped broadcast; only Logcat
  disclosure is removed.
- No paired-device transport is available locally.
- This PR is stacked on PR #12 and must retain base-first merge ordering.

## Verification Results

- `sh -n scripts/check-baseline.sh` and the focused source baseline passed.
- Four hostile mutations were rejected: restoring path interpolation, removing
  the routing extra, removing maintained guidance, and reopening plan status.
- Repository-root and external-directory `make check` passed the source,
  fixture, wrapper, and Android package gates.
- No emulator, physical wearable, paired transport, or live broadcaster message
  was exercised; runtime transport verification remains in the device matrix.
