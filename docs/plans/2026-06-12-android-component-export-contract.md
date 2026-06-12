# Android Component Export Contract

Status: Planned

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
- Remove the obsolete `tools:ignore="ExportedService"` suppression and unused
  tools namespace.
- Extend manifest contracts and security documentation for every component.

## Verification

- Parse both manifests as XML.
- Run SDK-free and SDK-backed `make check`.
- Run the complete gate through an absolute Makefile path and fresh clone.
- Reject focused component export, listener action, lint-suppression,
  documentation, and plan mutations.
- Pass exact-head pull-request baseline and CodeQL verification.

## Boundaries

- Do not make launcher activities or the Play Services listener private.
- Do not expose internal crash or dummy-message services or broadcast
  receivers.
- Do not change crash payloads, report allowlists, broadcasts, dependencies,
  or the placeholder Crashlytics credential.
