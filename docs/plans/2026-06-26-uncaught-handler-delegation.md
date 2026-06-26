# Uncaught Handler Delegation Implementation Plan

**Status:** Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Guarantee that Wear crash forwarding failures cannot bypass the previous default uncaught-exception handler.

**Architecture:** Keep the existing intent forwarding attempt unchanged inside a `try` block and move previous-handler delegation into `finally`. Enforce the lifecycle ordering with an SDK-free source contract and isolated hostile mutations.

**Tech Stack:** Java 7, Android uncaught-exception handling, POSIX shell, Python 3 source-contract tests, GNU Make

---

### Task 1: Add the failing delegation contract

**Files:**
- Create: `scripts/test-uncaught-handler-delegation.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`

**Step 1: Write the failing test**

Isolate `uncaughtException(...)` and require service startup to occur inside a
`try` block before previous-handler delegation inside `finally`.

**Step 2: Run test to verify it fails**

Run: `scripts/test-uncaught-handler-delegation.sh`

Expected: FAIL because delegation currently follows forwarding without a
`finally` guarantee.

**Step 3: Wire the focused test into Make**

Add the executable script to `make test` and the exact baseline graph.

### Task 2: Implement guaranteed delegation

**Files:**
- Modify: `wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrachlyticsWearUncaughtExceptionHandler.java`

**Step 1: Protect the forwarding phase**

Wrap the existing receipt log, intent construction, and service startup in
`try` without changing their behavior.

**Step 2: Guarantee previous-handler chaining**

Move the existing previous-handler null guard and invocation into `finally`.

**Step 3: Run the focused test**

Run: `scripts/test-uncaught-handler-delegation.sh`

Expected: PASS.

### Task 3: Add mutations and maintained guidance

**Files:**
- Create: `scripts/test-uncaught-handler-delegation-mutations.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: `CHANGES.md`

**Step 1: Add isolated hostile mutations**

Reject removal of `finally`, delegation outside `finally`, and service startup
outside the protected forwarding phase.

**Step 2: Run mutation cases**

Run: `scripts/test-uncaught-handler-delegation-mutations.sh`

Expected: every hostile mutation is rejected.

**Step 3: Synchronize maintained guidance**

Document that forwarding failures cannot bypass previous-handler delegation.

### Task 4: Complete verification

**Files:**
- Modify: `docs/plans/2026-06-26-uncaught-handler-delegation.md`

**Step 1: Run focused and full local gates**

Run: `make check`, `make -f "$PWD/Makefile" check`, `/bin/sh -n scripts/*.sh`,
and `git diff --check`.

Expected: PASS; Android SDK work may skip locally with an explicit message.

**Step 2: Commit and open the PR**

Commit the focused change, push the branch, and open a pull request against
`master`.

**Step 3: Run hosted and review gates**

Require exact-head Check and CodeQL. Run `codex review --base origin/master`,
verify any findings manually, and merge only when no actionable finding remains.

## Verification Results

- The focused source contract failed before implementation because service
  startup was not protected by a `try/finally` delegation boundary.
- The focused contract passes after previous-handler chaining moved into
  `finally` without changing crash intent construction or service startup.
- All three hostile mutations were rejected for removing `finally`, moving
  delegation after `finally`, and moving service startup before `try`.
- The complete portable test graph and shell syntax checks passed.
- The Android SDK was unavailable locally, so Gradle lint, checks, task
  discovery, and debug assembly were skipped pending hosted verification.
- Paired-device forwarding and user-visible crash UI were not exercised locally.
