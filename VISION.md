## Crashlytics For Android Wear Vision

Crashlytics For Android Wear is a legacy Android Wear sample that forwards
wear-device crash reports to a paired mobile app so Crashlytics can report them.

The repository is useful as an example of handling libraries that need internet
access when the wear device itself cannot report directly. Project details live
in [`README.md`](README.md).

The goal is to preserve the sample's crash-forwarding design while making
modernization, credentials, and wearable messaging behavior explicit.

The current focus is:

Priority:

- Preserve the uncaught-exception-to-wear-message flow
- Keep Crashlytics handling separated from other wearable messages
- Avoid committing Fabric or Crashlytics credentials
- Maintain the mobile/wear module relationship

Next priorities:

- Document current build requirements and legacy dependency constraints
- Replace dynamic dependency versions with reproducible versions
- Modernize Fabric/Crashlytics and wearable APIs in a dedicated pass
- Add manual verification notes for crash forwarding across paired devices

Contribution rules:

- One PR = one focused crash-reporting, wearable, build, or documentation change.
- Verify both mobile and wear modules for message-flow changes.
- Keep credential setup local and documented.
- Preserve the README's explanation of design tradeoffs.

## Security And Privacy

Crash reports may contain stack traces, device details, and user-adjacent data.
Changes should avoid adding unnecessary payloads, logs, or external reporting
paths.

Credentials for Fabric, Crashlytics, or any replacement service must stay out
of git.

## What We Will Not Merge (For Now)

- Hardcoded reporting credentials
- Crash payload expansion without privacy notes
- Wearable message rewrites without paired-device verification
- Broad dependency migrations mixed with crash behavior changes

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
