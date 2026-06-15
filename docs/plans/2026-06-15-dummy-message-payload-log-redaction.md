---
title: Dummy Message Payload Log Redaction
type: security
status: planned
date: 2026-06-15
---

# Dummy Message Payload Log Redaction

## Status: Planned

## Problem Frame

`DummyWearableListenerReceiver` decodes every `/dummy` message and writes the
complete payload to Android Logcat. Wear messages may contain arbitrary sample
or user-provided content, so successful receipt diagnostics must not duplicate
that content into device logs.

## Scope Boundaries

- Remove only decoded payload content from the successful `/dummy` receipt log.
- Preserve path validation, empty-payload rejection, UTF-8 decoding, unknown
  path delegation, and listener behavior.
- Extend the SDK-free source contract and privacy documentation.
- Do not change the wearable protocol, manifests, dependencies, credentials,
  workflows, or Crashlytics forwarding behavior.

## Requirements

- R1. Successful `/dummy` receipt logging must not include decoded message
  content or raw message bytes.
- R2. A constant receipt diagnostic must remain so message delivery is still
  observable without exposing payload content.
- R3. UTF-8 decoding and existing empty-payload validation must remain intact.
- R4. Static contracts must reject payload-log restoration, receipt-message
  deletion, UTF-8 drift, documentation drift, and stale plan evidence.

## Implementation

- Replace the payload-bearing success log with a constant receipt message.
- Add exact source and completed-plan contracts to `scripts/check-baseline.sh`.
- Synchronize README, SECURITY, CHANGES, VISION, AGENTS, and this plan.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make check`
- Absolute-path `make check` from an external directory
- `git diff --check`
- Isolated hostile mutations for payload-log restoration, receipt deletion,
  UTF-8 drift, documentation drift, and stale plan evidence

## Risks

- Full paired-device message delivery remains outside local validation.
- The decoded local variable remains necessary to prove the existing UTF-8
  wire-format contract unless implementation shows it can be removed without
  weakening that contract.
