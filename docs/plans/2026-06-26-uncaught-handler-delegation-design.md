# Uncaught Handler Delegation Design

## Evidence

- The Wear uncaught-exception handler forwards the throwable through
  `startService(...)` before invoking the previous default handler.
- Intent construction, extra parceling, or service startup can throw while the
  process is already handling a fatal exception.
- A forwarding failure currently bypasses the previous handler, which can
  suppress the platform's normal crash termination and user-visible handling.
- The repository already documents report forwarding and previous-handler
  delegation as separate responsibilities that must both remain intact.

## Approaches

### 1. Delegate from a `finally` block

Keep the existing forwarding attempt in a `try` block and invoke the previous
handler from `finally`. This guarantees chaining without hiding a forwarding
failure when no previous handler exists.

### 2. Catch forwarding exceptions before delegation

Catch `RuntimeException`, log a category, and continue to delegation. This also
preserves chaining but broadens behavior by suppressing forwarding failures and
requires a policy for which throwable classes to catch.

### 3. Extract a forwarding helper

Move intent construction and service startup into a helper called from a
`try/finally`. This makes the phases explicit but adds indirection without
changing the single call site's correctness boundary.

## Decision

Use a local `try/finally`. It is the smallest correction, preserves the current
forwarding attempt and diagnostics, and guarantees the previous default handler
gets control even when forwarding fails.

## Validation

- Add a portable source contract that isolates `uncaughtException(...)` and
  requires forwarding to occur inside `try` before delegation inside `finally`.
- Run the contract against the current implementation and observe failure.
- Apply the minimal `try/finally` change and rerun the contract.
- Reject hostile mutations that remove `finally`, move delegation after it, or
  move service startup outside the protected forwarding phase.
- Run repository, external Makefile, hosted Android, and CodeQL gates.

## Boundaries

- Do not change crash payloads, service targets, log contents, or report types.
- Do not catch or suppress forwarding failures.
- Keep the existing null guards for the application, throwable, and previous
  default handler.
- Paired-device forwarding and user-visible crash UI remain manual verification
  boundaries.
