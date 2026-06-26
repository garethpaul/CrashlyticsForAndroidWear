# Wear Node Discovery Status Implementation Plan

**Status:** Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Reject failed connected-node discovery results before either Wear sender reads or iterates the node list.

**Architecture:** Keep the pinned `NodeApi` flow and add identical fail-closed status checks at the two ownership points. Enforce ordering with a portable source contract and hostile mutations because the Google Play services types are unavailable to SDK-free unit tests.

**Tech Stack:** Java 7, legacy Google Play services Wearable API, POSIX shell, Python 3 source-contract tests, GNU Make

---

### Task 1: Add the failing discovery contract

**Files:**
- Create: `scripts/test-wear-node-discovery-status.sh`
- Modify: `Makefile`

**Step 1: Write the failing test**

Parse both sender methods and require `nodes.getStatus()` null/success checks to
appear before the first `nodes.getNodes()` access, with constant diagnostics.

**Step 2: Run test to verify it fails**

Run: `scripts/test-wear-node-discovery-status.sh`

Expected: FAIL because neither sender validates discovery status.

**Step 3: Wire the focused test into Make**

Add the script to `make test` without changing existing target authority.

### Task 2: Implement minimal status guards

**Files:**
- Modify: `wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java`
- Modify: `wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/services/SendDummyMessageIntentService.java`

**Step 1: Guard Crashlytics discovery**

Return with a constant diagnostic when the discovery result or status is
missing or unsuccessful, before reading `getNodes()`.

**Step 2: Guard dummy discovery**

Apply the same ordering and privacy boundary to the dummy sender.

**Step 3: Run the focused test to verify it passes**

Run: `scripts/test-wear-node-discovery-status.sh`

Expected: PASS.

### Task 3: Add hostile mutations and documentation

**Files:**
- Create: `scripts/test-wear-node-discovery-status-mutations.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`
- Modify: `README.md`
- Modify: `CHANGES.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: `docs/plans/2026-06-25-wear-node-discovery-status.md`

**Step 1: Add mutation cases**

Reject removal of each status guard, success check, ordering boundary, and
constant diagnostic.

**Step 2: Run mutations**

Run: `scripts/test-wear-node-discovery-status-mutations.sh`

Expected: every hostile mutation is rejected.

**Step 3: Synchronize maintained guidance**

Document discovery-result validation and the paired-device nonclaim.

### Task 4: Complete verification

**Files:**
- Modify: `docs/plans/2026-06-25-wear-node-discovery-status.md`

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

- The focused source contract failed before implementation because the
  Crashlytics sender did not validate connected-node discovery status.
- The focused contract passes after both senders reject missing or unsuccessful
  statuses before node-list access.
- All six hostile node-discovery mutations were rejected for removed guards,
  inverted success checks, and weakened constant diagnostics.
- Repository-root and external-Makefile `make check`, shell syntax, staged
  whitespace checks, and the detached hostile-baseline harness passed.
- The Android SDK was unavailable locally, so Gradle lint, checks, task
  discovery, and debug assembly were skipped pending hosted verification.
- Paired-device delivery was not exercised locally.
- Exact-head hosted Check runs `28219654941` and `28219655844` passed the
  Android SDK-backed lint, checks, task discovery, and mobile/Wear debug builds.
- Exact-head CodeQL run `28219654907` passed Actions and Java/Kotlin analysis.
- Exact-head hosted Check and CodeQL passed.
