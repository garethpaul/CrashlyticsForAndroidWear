---
title: Wear Listener Callback Guards
type: fix
status: completed
date: 2026-06-08
---

# Wear Listener Callback Guards

## Summary

Harden the internal Wear listener broadcast bridge so nullable Play Services
callback objects are ignored before they are serialized or logged.

## Requirements

- R1. Peer connect and disconnect callbacks must ignore missing `Node` data.
- R2. Message callbacks must ignore missing message events and paths before
  building serializable event wrappers.
- R3. Data-change callbacks must ignore missing event buffers or status values.
- R4. The dummy message receiver must ignore missing paths and empty payloads.
- R5. The source baseline must guard these receiver and broadcaster checks.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew check --no-daemon`
- `git diff --check`
