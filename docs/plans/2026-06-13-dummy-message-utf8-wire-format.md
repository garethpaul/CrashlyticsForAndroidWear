---
title: Dummy Message UTF-8 Wire Format
date: 2026-06-13
status: completed
execution: code
---

# Dummy Message UTF-8 Wire Format

## Summary

Make the sample dummy-message channel use an explicit UTF-8 wire format so
text survives a Wear-to-mobile round trip independently of each device's
platform-default charset.

## Priorities

1. Replace platform-default encoding and decoding on the `/dummy` message
   path with one explicit UTF-8 contract.
2. Add a deterministic non-ASCII round-trip fixture and source-level baseline
   checks that reject either endpoint falling back to a default charset.
3. Keep the Crashlytics `DataMap` protocol, legacy dependencies, manifests,
   wrapper, and bounded Data Layer behavior unchanged.

## Requirements

- Use an API-compatible UTF-8 `Charset` on the Wear sender and mobile receiver.
- Prove representative accented, CJK, and emoji text round-trips exactly.
- Reject no-argument `String.getBytes()` and `new String(byte[])` calls in the
  maintained Java sources.
- Document the wire-format guarantee in the README, changelog, and vision.
- Pass the repository gate from the worktree and an external working
  directory, plus focused hostile mutations of both endpoints and evidence.

## Verification

Completed on 2026-06-13:

- The Java 8 UTF-8 fixture passed with exact accented, CJK, and emoji bytes and
  decoded back to the original text.
- `make check` passed with the configured legacy Android SDK, including mobile
  and Wear lint with zero issues, Gradle checks, task discovery, and both debug
  APK assemblies.
- `make -f /absolute/path/Makefile check` passed from `/tmp`, proving the gate
  remains independent of the caller's working directory.
- Eleven hostile mutations were rejected across sender and receiver defaults,
  wrong charsets, fixture weakening, missing fixtures, and documentation drift.
- Shell syntax, whitespace, focused diff review, and a secret-pattern scan
  passed.
- Paired-device behavior was not exercised, and hosted CI was not yet visible
  when this local implementation record was completed.

## Out Of Scope

- Migrating Fabric, Crashlytics, Google Play Services, Gradle, or Android SDK
  versions
- Changing the crash-report `DataMap` payload
- Claiming paired-device behavior without physical or emulator verification
