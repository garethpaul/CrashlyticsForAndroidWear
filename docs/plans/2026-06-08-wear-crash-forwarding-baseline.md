---
title: Wear Crash Forwarding Baseline
type: fix
status: superseded
date: 2026-06-08
---

# Wear Crash Forwarding Baseline

Superseded by `docs/plans/2026-06-08-crashlytics-wear-build-baseline.md`,
which combines this crash-forwarding guard with the repository hygiene and
legacy build baseline.

## Summary

Raise the baseline for the legacy Android Wear Crashlytics sample by making
dependency resolution more reproducible, keeping the Gradle wrapper download on
HTTPS, constraining app-internal wearable broadcasts, and adding defensive
guards around crash payload forwarding.

---

## Problem Frame

The project uses an HTTP Gradle wrapper URL and dynamic dependency selectors for
Fabric, Google Play Services Wearable, and the Wear support library. The mobile
module receives serialized data from a normal broadcast action, and the wear
module assumes crash payloads, initialized context, and GoogleApiClient
connections are always available. Those assumptions make the sample fragile for
source-only maintenance and paired-device testing.

---

## Requirements

- R1. Gradle wrapper downloads must use HTTPS.
- R2. Legacy dynamic dependency selectors must be removed where the dependency
  is needed, or the unused dependency must be removed.
- R3. Build-tools pins must match an installed local SDK baseline.
- R4. Wearable listener broadcasts must be package-scoped before dispatch.
- R5. Broadcast receivers must ignore unexpected actions and missing payloads.
- R6. Crash forwarding must handle missing intent, throwable, DataMap payload,
  and uninitialized application state without throwing a secondary crash.
- R7. GoogleApiClient message sends must check connection status and disconnect.
- R8. README and a source check must document and guard the baseline.

---

## Implementation Units

### U1. Reproducible Build Metadata

- **Goal:** Avoid dynamic dependency drift and broken wrapper downloads.
- **Files:** `gradle/wrapper/gradle-wrapper.properties`, `mobile/build.gradle`,
  `wear/build.gradle`
- **Patterns:** HTTPS wrapper URL, installed build-tools 24.0.3, pinned Fabric
  plugin, pinned Play Services Wearable, Google Maven for Play Services, and
  removal of the unused Wear support dependency.
- **Verification:** `scripts/check-baseline.sh`, Gradle task discovery when the
  legacy wrapper can run.

### U2. Broadcast Boundary

- **Goal:** Keep serialized wearable events app-internal and tolerant of
  malformed payloads.
- **Files:** `WearableListenerBroadcaster.java`,
  `WearableListenerReceiver.java`
- **Patterns:** Set package on internal broadcasts, verify action on receive,
  and guard missing serialized bytes before deserialization.
- **Verification:** `scripts/check-baseline.sh`

### U3. Crash Forwarding Guards

- **Goal:** Avoid secondary crashes while forwarding reports from wear to phone.
- **Files:** `CrashlyticsWear.java`,
  `CrachlyticsWearUncaughtExceptionHandler.java`,
  `CrashlyticsWearIntentService.java`,
  `CrashlyticsWearableListenerReceiver.java`,
  `SendDummyMessageIntentService.java`
- **Patterns:** Guard missing application, intent, throwable, DataMap bytes, and
  GoogleApiClient connection failures; disconnect clients in finally blocks.
- **Verification:** `scripts/check-baseline.sh`

### U4. Documentation And Guardrail

- **Goal:** Make the legacy maintenance contract repeatable.
- **Files:** `README.md`, `scripts/check-baseline.sh`, this plan.
- **Patterns:** Document source checks, Gradle limitations, credential boundary,
  and paired-device manual verification.
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

---

## Risks & Dependencies

- Fabric Crashlytics and the old Wearable APIs remain legacy and need a
  dedicated migration to modern Firebase Crashlytics and AndroidX-era tooling.
- Source checks do not prove live paired-device crash delivery.
- Gradle 1.12 and Android Gradle Plugin 0.12.2 may still fail on modern hosts
  even with a fixed wrapper URL.

---

## Sources / Research

- `build.gradle`, `mobile/build.gradle`, `wear/build.gradle`, and the Gradle
  wrapper define the legacy build surface.
- `WearableListenerBroadcaster.java` sends app event broadcasts.
- `WearableListenerReceiver.java` deserializes broadcast event payloads.
- `CrashlyticsWearIntentService.java` and
  `SendDummyMessageIntentService.java` send messages over the Wearable API.
- `CrashlyticsWearableListenerReceiver.java` forwards wear reports into
  Crashlytics.
