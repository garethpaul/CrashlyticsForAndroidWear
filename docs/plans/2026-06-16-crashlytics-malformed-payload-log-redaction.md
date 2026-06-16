# Crashlytics Malformed Payload Log Redaction

## Status: Completed

## Context

The phone receiver catches `IllegalArgumentException` when a paired wearable
sends malformed Crashlytics bytes, but currently passes that exception object
to `Log.e`. Provider/parser exception details are peer-triggered diagnostic
data and do not need to be exposed in Logcat to preserve the rejection path.

## Objectives

- Keep malformed Crashlytics payloads rejected without crashing the receiver.
- Log only a constant malformed-payload category, without the exception object.
- Preserve valid report parsing, metadata allowlisting, Crashlytics forwarding,
  message-path redaction, and parent fallback handling.
- Protect the boundary with the existing SDK-free source baseline and hostile
  mutation coverage.

## Scope

- Update `mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearableListenerReceiver.java`.
- Extend `scripts/check-baseline.sh` and maintained security guidance.
- Do not alter dependencies, manifests, message schemas, or runtime permissions.

## Verification

- `sh -n scripts/check-baseline.sh`
- Repository-root and external-directory `make check`
- Isolated mutations restoring exception-object logging, removing the constant
  category, weakening maintained guidance, and reverting completed plan status
- `git diff --check`
- Generated artifact and sensitive-value audits

No emulator, physical wearable, paired transport, or live malformed message is
available in this environment; runtime confirmation remains in
`DEVICE_VERIFICATION.md`.

## Verification Results

- Four isolated hostile mutations were rejected for exception-object logging,
  missing constant-category logging, weakened security guidance, and incomplete
  plan status.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed before the
  complete package gate.
- Repository-root and external-directory `make check` passed, including
  zero-finding mobile/Wear lint, Gradle check and task discovery, immutable
  snapshot verification, and mobile/Wear debug assembly.
