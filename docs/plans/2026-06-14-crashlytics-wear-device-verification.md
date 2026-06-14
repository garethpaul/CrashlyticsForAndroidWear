# Crashlytics Wear Device Verification Matrix

Status: In Progress

## Problem

Portable checks cover immutable event snapshots, UTF-8 dummy messages,
bounded Data Layer waits, report type allowlists, metadata privacy, throwable
log redaction, and mobile receiver validation. The repository does not define
repeatable exact-head evidence for paired phone/Wear transport or live
Crashlytics delivery with private local credentials.

## Requirements

1. Add an exact-commit matrix for installation, pairing, dummy messages, Java
   and native-style report envelopes, timeout/failure handling, metadata,
   uncaught exceptions, mobile receipt, and live Crashlytics delivery.
2. Require synthetic exceptions and sanitized Android, device-class,
   transport, project, result, and evidence fields with explicit pass, fail,
   blocked, or not-run outcomes.
3. Keep repository, Gradle, emulator, paired-device, and hosted Crashlytics
   evidence separate so portable checks cannot imply external execution.
4. Add mutation-sensitive contracts for the matrix, repository guidance, and
   completed plan evidence.

## Scope Boundaries

- Do not change Java, manifests, Gradle, dependencies, report schemas,
  transport paths, timeouts, Crashlytics configuration, or runtime behavior.
- Do not add real API keys, project identifiers, device identifiers, crash
  payloads, stack traces, account data, screenshots, logs, APKs, or archives.
- Do not claim paired-device transport or live Crashlytics delivery from
  repository, static, Java, or Gradle checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded repository validation.
