---
title: Wear Event Immutable Snapshots
type: fix
date: 2026-06-13
status: completed
---

# Wear Event Immutable Snapshots

## Summary

Make the Wear message and node wrappers true immutable snapshots, including
defensive copying of message payload bytes at construction and access time.

## Problem Frame

`SerializableMessageEvent` and `SerializableNode` are documented as copies of
Wear events for broadcast receivers, but both expose mutable fields and public
setters. The message wrapper also stores and returns the caller's byte array by
reference. A caller or receiver can therefore mutate an event after it has been
captured, violating the snapshot boundary used during internal event dispatch.

## Requirements

- R1. All stored message and node fields must be private and final.
- R2. Public mutator methods must be removed from both snapshot classes.
- R3. Message payload bytes must be cloned on construction so later mutation of
  the source event or broadcast extra cannot change the snapshot.
- R4. `getData()` must return a clone so a receiver cannot mutate the stored
  snapshot through the returned array.
- R5. Null payload behavior and all scalar getter values must remain compatible.
- R6. A standalone Java fixture and the static baseline must enforce field
  finality, absence of setters, defensive copying, scalar values, null payloads,
  documentation, and completed-plan evidence through `make check`.

## Key Technical Decisions

- **Defensive copy at both boundaries:** Clone non-null byte arrays in the
  constructor and getter; preserve `null` rather than inventing an empty body.
- **Remove rather than deprecate setters:** These internal wrappers have no
  legitimate mutation call sites, and retaining setters would preserve the
  false mutable-event contract.
- **Use a Java-only executable fixture:** Compile the production classes against
  minimal `MessageEvent` and `Node` interfaces in a temporary directory so the
  immutability contract runs even when the Android SDK is unavailable.
- **Keep broadcast behavior unchanged:** Paths, request IDs, source node IDs,
  display names, and receiver dispatch remain the same.

## Implementation Units

### U1. Make Event Wrappers Immutable

- **Files:** `SerializableMessageEvent.java`, `SerializableNode.java`
- **Goal:** Finalize fields, remove mutators, and defensively copy payload data.
- **Covers:** R1, R2, R3, R4, R5

### U2. Add Executable Snapshot Coverage

- **Files:** `scripts/test-wear-event-snapshots.sh`,
  `scripts/WearEventSnapshotCheck.java`, `Makefile`
- **Goal:** Compile the production wrappers with interface stubs and execute
  reflection, value, null, and aliasing assertions without Android tooling.
- **Covers:** R1, R2, R3, R4, R5, R6

### U3. Preserve Static And Documentation Contracts

- **Files:** `scripts/check-baseline.sh`, `README.md`, `CHANGES.md`, `VISION.md`,
  `AGENTS.md`
- **Goal:** Enforce immutable source structure, fixture wiring, plan status, and
  the event snapshot boundary in repository guidance.
- **Covers:** R6

## Verification

- Run `scripts/test-wear-event-snapshots.sh`, `make check`, and the absolute-path
  `make check` wrapper from `/tmp` with the configured Android SDK.
- Run the SDK-free static/Java fixture baseline with an intentionally absent
  `ANDROID_HOME` and record the resulting platform limitation truthfully.
- Run shell syntax, Java compilation, whitespace, secret, and artifact checks.
- Apply isolated hostile mutations for constructor aliasing, getter aliasing,
  non-final fields, restored setters, null-payload drift, scalar-value drift,
  missing test wiring, and incomplete plan status; each mutation must fail.
- Do not claim paired-device event delivery testing without a connected phone
  and Wear device.

## Verification Results

- `scripts/test-wear-event-snapshots.sh` passed defensive-copy, null payload,
  scalar getter, final-field, and no-setter checks against the production
  wrapper classes.
- Configured-SDK repository and external-directory `make check` passed mobile
  and Wear lint with zero issues, Gradle checks, task discovery, and both debug
  APK assemblies.
- An intentionally absent `ANDROID_HOME` passed the SDK-free static baseline
  and executable Java snapshot fixture while truthfully skipping Gradle tasks.
- Shell syntax, Java compilation, whitespace, secret, and generated-artifact
  checks passed.
- Eight isolated hostile mutations covering constructor and getter aliasing,
  field finality, restored setters, null-payload behavior, scalar values,
  missing test wiring, and completed-plan status were rejected.
- Paired-device event delivery was not exercised; broadcast dispatch, message
  paths, dependencies, manifests, wrapper, and workflows are unchanged.

## Prioritized Follow-Ups

1. Validate source-node identifiers before dispatching message events to
   specialized receivers.
2. Replace the legacy broadcast bridge during a broader modern Wear data-layer
   migration while preserving receiver separation.

## Risks

- Removing public setters is a source-level API change, but repository search
  shows no callers and the classes are internal implementation snapshots.
- Defensive copies allocate one extra payload array at capture and access time;
  crash and dummy messages are infrequent and correctness outweighs this small
  bounded cost.
