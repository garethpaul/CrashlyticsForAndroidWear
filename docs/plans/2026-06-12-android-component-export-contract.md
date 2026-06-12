# Android Component Export Contract

Status: Completed

## Context

CodeQL alert 1 (`java/android/implicitly-exported-component`) identifies the
mobile `WearableListenerBroadcaster`. Its legacy
`com.google.android.gms.wearable.BIND_LISTENER` filter makes it exported, but
the manifest records that behavior only through a lint suppression.

The mobile and Wear launcher activities and the two internal Wear intent
services also rely on target-SDK-era export defaults. Every component trust
boundary should be explicit while preserving current launch and data-layer
behavior.

## Goal

Remove implicit component exposure across both manifests without breaking
launcher entry points, Google Play services listener binding, internal crash
forwarding, or dummy-message delivery.

## Changes

- Mark both launcher activities explicitly exported.
- Mark `WearableListenerBroadcaster` explicitly exported and constrain it to
  the single required `BIND_LISTENER` action.
- Keep both mobile broadcast receivers and both internal Wear intent services
  explicitly non-exported.
- Retain the service-local `tools:ignore="ExportedService"` annotation because
  AGP 1.1 warns about the required permissionless Play Services binding even
  after the export policy is explicit; do not broaden it into lint.xml.
- Extend manifest contracts and security documentation for every component.

## Verification

- Parse both manifests as XML.
- Run SDK-free and SDK-backed `make check`.
- Run the complete gate through an absolute Makefile path and fresh clone.
- Reject focused component export, listener action, lint-annotation,
  documentation, and plan mutations.
- Pass exact-head pull-request baseline and CodeQL verification.

### Completed local evidence

- Both manifests parse as XML.
- SDK-free and SDK-backed `make check` pass; legacy lint reports zero issues
  for mobile and Wear, and both debug applications assemble successfully.
- The complete SDK-backed gate passes from a fresh external clone with the
  reviewed patch applied.
- Twenty-nine focused mutations are rejected across component inventory,
  export policy, launcher filters, listener binding, isolated service process,
  lint annotation, documentation, and plan contracts.
- On reviewed implementation head
  `42f2da730712fea266ad41ee0b8ff26df06d32e9`, push run `27404727879`
  and pull-request run `27404729914` completed successfully.
- CodeQL run `27404728054` completed successfully for Actions and Java/Kotlin,
  and `refs/pull/1/head` reported zero open code-scanning alerts. Alert 1
  remains open only on `master` until this pull request is merged.

## Boundaries

- Do not make launcher activities or the Play Services listener private.
- Do not expose internal crash or dummy-message services or broadcast
  receivers.
- Do not change crash payloads, report allowlists, broadcasts, dependencies,
  or the placeholder Crashlytics credential.
