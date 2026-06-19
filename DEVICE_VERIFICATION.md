# Crashlytics Wear Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so paired-device transport and Crashlytics evidence cannot be
transferred to a different report-forwarding implementation.

## Evidence Rules

- Use synthetic exceptions and dummy messages that contain no user, account,
  employer, customer, location, or production information.
- Record Android versions, phone and Wear device classes, pairing state,
  transport state, Crashlytics project class, result, and evidence identifier.
- Do not include API keys, project identifiers, device identifiers, full stack
  traces, crash payloads, account data, screenshots, logs, APKs, or archives.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android phone / API | `not run` |
| Wear device / API | `not run` |
| Pairing / Data Layer state | `not run` |
| Crashlytics project class | `not run` |
| Synthetic exception identifier | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Mobile and Wear install | Exact-head debug APKs install and launch without stale app state or real credentials in git. | `not run` | `not run` |
| Paired node discovery | The Wear app discovers a connected phone node or records a bounded missing-node result. | `not run` | `not run` |
| UTF-8 dummy message | Accented, CJK, and emoji text arrives unchanged on the paired phone. | `not run` | `not run` |
| Connection timeout | An unavailable Data Layer connection returns within the five-second boundary without hanging the service. | `not run` | `not run` |
| Node lookup timeout | Stalled connected-node discovery returns within the five-second boundary. | `not run` | `not run` |
| Send timeout or failure | A stalled or failed per-node send returns safely without reading a missing status. | `not run` | `not run` |
| Declared CRASH report | A synthetic CRASH envelope reaches the mobile receiver with only declared fields and metadata keys. | `not run` | `not run` |
| Declared EXCEPTION report | A synthetic EXCEPTION envelope reaches the mobile receiver and reconstructs the throwable for Crashlytics. | `not run` | `not run` |
| Unsupported report type | The mobile receiver rejects an unsupported type before writing Crashlytics metadata. | `not run` | `not run` |
| Incomplete report | Missing `ERROR` or `REPORT_TYPE` data is rejected before Crashlytics writes. | `not run` | `not run` |
| Uncaught Wear exception | The handler forwards a synthetic exception, avoids Throwable Logcat output, and delegates to the previous handler. | `not run` | `not run` |
| Metadata privacy | Forwarded metadata omits hardware serial and undeclared or non-string keys. | `not run` | `not run` |
| Live Crashlytics delivery | A synthetic report appears only in the designated private test project with a sanitized evidence identifier. | `not run` | `not run` |
| Relaunch after report | Phone and Wear apps relaunch without stale message, node, report, or client state. | `not run` | `not run` |

## Current Status

No paired Android/Wear devices, Data Layer transport, physical crash,
private Crashlytics project, or live report delivery was exercised for this checklist.
Treat every phone, Wear, pairing, transport, crash, and Crashlytics row as unexecuted
until evidence is attached to the exact commit.
