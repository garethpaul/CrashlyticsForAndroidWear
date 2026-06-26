# Wear Node Discovery Status Design

## Evidence

- Both Wear senders call `getConnectedNodes(...).await(...)` and read
  `getNodes()` without checking the result status first.
- `NodeApi.GetConnectedNodesResult` implements the Google Play services
  `Result` interface and therefore exposes `getStatus()`.
- Google documents `Status.isSuccess()` as the success boundary for a result:
  <https://developers.google.com/android/reference/com/google/android/gms/common/api/Status>
- The repository already treats missing or failed per-node send statuses as
  terminal category-level diagnostics without logging provider details.

## Approaches

### 1. Inline status guards in both senders

Check for a null result, null status, or unsuccessful status before reading the
node list. This preserves Gradle 1.12-era APIs and keeps the change local.

### 2. Shared result-validation helper

Extract a helper around `GetConnectedNodesResult`. This reduces duplication but
adds an API-coupled abstraction for only two call sites and complicates portable
testing.

### 3. Migrate to `NodeClient`

Move to the current Wear API. This requires dependency and asynchronous-flow
modernization and conflicts with the repository's dedicated-migration boundary.

## Decision

Use inline status guards. They are the smallest compatible correction and match
the existing send-result policy. Emit one constant failure category per sender,
then return before `getNodes()`.

## Validation

- Add a source-level contract that parses each send method and requires the
  status guard before node-list access.
- Watch the new contract fail on the current implementation.
- Add the two minimal guards and rerun the focused contract.
- Add hostile mutations that remove or weaken each guard.
- Run repository and external `make check`, then hosted Android and CodeQL gates.

## Boundaries

- Do not change message paths, payloads, timeouts, dependencies, manifests,
  credentials, or per-node send behavior.
- Do not log raw provider status messages or device identity.
- Paired-device delivery remains a manual verification boundary.
