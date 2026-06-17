---
title: Crashlytics Wear Secure Hosted Android Verification
type: security
date: 2026-06-17
status: completed
execution: code
---

# Crashlytics Wear Secure Hosted Android Verification

## Context

The canonical GitHub Actions workflow intentionally clears `ANDROID_HOME` and
`ANDROID_SDK_ROOT`, so `make check` runs only the portable source and Java
snapshot contracts. The same exact repository head passes mobile and Wear
lint, Gradle checks and task discovery, and both debug APK assemblies locally
with Java 8, Android API 21, and build-tools 24.0.3.

A clean temporary Gradle user home also downloaded the checksum-pinned Gradle
1.12 distribution, the legacy Android/Fabric dependency graph, and assembled
both debug APKs successfully. That probe exposed one prerequisite: Gradle's
legacy `jcenter()` shorthand requests artifacts over HTTP. The existing exact
JCenter coordinates are available through HTTPS, so hosted SDK-backed
verification can close both the execution gap and this transport weakness
without changing dependency versions.

## Priority

1. Force the existing JCenter artifact graph through HTTPS before making fresh
   hosted dependency bootstrap canonical.
2. Run the real Android lint, check, task-discovery, and assembly gates on both
   canonical hosted events instead of treating portable checks as sufficient.
3. Preserve the credential-free, read-only, bounded workflow and immutable
   action pins.
4. Keep modernization of Gradle, the Android plugin, Fabric, Crashlytics, Play
   Services, JCenter artifact coordinates, target SDKs, and runtime behavior
   outside this unit.

## Requirements

- Replace both `jcenter()` repository declarations with the explicit
  `https://jcenter.bintray.com` endpoint while preserving every artifact
  coordinate and version.
- Install `platform-tools`, Android API 21, and build-tools 24.0.3 with the
  runner's command-line tools before selecting the Java 8 runtime required by
  Gradle 1.12.
- Select Amazon Corretto 8 with the repository's reviewed immutable
  `actions/setup-java` pin.
- Run the unchanged canonical `make check` target with the hosted Android SDK
  visible so mobile and Wear lint, Gradle checks, task discovery, and both
  debug APK assemblies execute.
- Increase the bounded job timeout only enough to cover SDK installation,
  dependency bootstrap, and the full gate.
- Retain Ubuntu 24.04, read-only contents permission, concurrency cancellation,
  and disabled checkout credential persistence.
- Replace the SDK-free workflow contracts in `scripts/check-baseline.sh` with
  mutation-sensitive requirements for HTTPS-only repositories, the SDK
  packages, Java distribution and version, setup ordering, full verification
  step, timeout, and absence of the empty SDK override.
- Update maintained guidance and changelog text so portable checks cannot be
  mistaken for the hosted Android build evidence.
- Record completed local and exact-head hosted verification in this plan after
  implementation succeeds.

## Key Technical Decisions

### Preserve coordinates while forcing HTTPS

This unit will not upgrade or substitute the legacy Android dependencies. It
will replace only Gradle's HTTP-producing JCenter shorthand with the explicit
HTTPS endpoint and prove a fresh bootstrap no longer requests repository
artifacts over HTTP.

### Install SDK packages before selecting Java 8

The current Android command-line tools require a newer Java runtime than the
legacy build. The workflow will use the runner's default Java for `sdkmanager`,
then switch to Corretto 8 before invoking Gradle. This follows a working local
repository pattern and avoids changing the application build stack.

### Keep one canonical gate

The workflow will continue invoking `make check` rather than duplicating Gradle
commands in YAML. The Makefile already owns the complete lint, portable test,
Gradle check, task, and assembly sequence for both modules.

### Do not cache the legacy dependency graph in this unit

Fresh dependency bootstrap completed within the intended timeout. Avoiding a
new cache contract keeps the workflow focused and proves that hosted builds do
not depend on an opaque pre-existing Gradle cache.

## Implementation Units

### 1. Secure legacy repository transport

Files:

- `build.gradle`

Replace both JCenter shorthand declarations with the explicit HTTPS endpoint.
Do not change dependency coordinates, versions, repository precedence, or the
separate Fabric and Google Maven endpoints.

### 2. Hosted Android toolchain

Files:

- `.github/workflows/check.yml`

Install the exact legacy SDK packages, select Corretto 8 after installation,
remove the empty SDK environment override, increase the timeout, and rename the
final step to reflect full Android verification.

### 3. Portable workflow contracts

Files:

- `scripts/check-baseline.sh`

Require HTTPS-only repository declarations plus the exact hosted toolchain and
ordering. Reject restoration of JCenter shorthand or HTTP endpoints, the
SDK-free environment, weakened action pins, missing packages, a non-Java-8
runtime, insufficient timeout, or a workflow that bypasses `make check`.

### 4. Maintained evidence and guidance

Files:

- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-17-hosted-android-sdk-verification.md`

Describe what hosted CI now executes, preserve the device and live Crashlytics
boundaries, and record exact verification without implying emulator, paired
transport, physical-device, or credentialed service execution.

## Validation

- Run POSIX shell syntax and the focused baseline checker.
- Bootstrap and assemble from an empty temporary Gradle user home using Java 8,
  Android API 21, and build-tools 24.0.3, capturing output to prove no
  repository artifact is requested over HTTP.
- Run complete repository-root and external-working-directory `make check`
  gates with the Android SDK enabled.
- Reject isolated workflow and checker mutations for JCenter transport, SDK
  package versions, setup order, Java distribution/version, timeout, SDK
  visibility, canonical command, maintained guidance, plan status, and
  verification evidence.
- Audit the exact diff, workflow permissions, action pins, dependency and
  manifest drift, generated artifacts, whitespace, conflict markers, and
  credential-shaped additions.
- Require both exact-head push and pull-request hosted checks to complete
  successfully before recording terminal evidence.

## Edge Cases And Failure Handling

- A missing legacy SDK package must fail during installation rather than fall
  back to the SDK-free Make path.
- Java 8 must not be selected before `sdkmanager`, because current command-line
  tools may reject that runtime.
- Gradle or repository dependency bootstrap failures must fail the canonical
  job; the workflow must not retry by weakening or skipping Android tasks.
- Placeholder Crashlytics credentials must continue disabling upload-oriented
  debug tasks without adding secrets or contacting a private project.
- Hosted success proves compilation and static checks only. It does not prove
  emulator, paired phone/Wear transport, physical hardware, live Logcat, or
  Crashlytics delivery.

## Scope Boundaries

- Do not change Gradle 1.12, Android Gradle Plugin 0.12.2, Fabric 1.14.4,
  Crashlytics 2.2.0, Play Services 6.1.71, JCenter artifact coordinates,
  application IDs, SDK levels, permissions, components, report schemas,
  logging behavior, or Data Layer behavior.
- Do not add API keys, signing material, service credentials, device data,
  build outputs, logs, or archives.
- Do not merge or close this stacked pull request or any predecessor without
  explicit authorization.

## Verification Results

- A clean empty temporary Gradle user home downloaded the checksum-pinned
  Gradle distribution and the unchanged legacy dependency graph through HTTPS,
  loaded the complete task graph, and assembled both debug APKs. The captured
  output confirmed that no repository artifact was requested over HTTP.
- Repository-root and external working directory `make check` passed under
  Corretto 8 with Android API 21 and build-tools 24.0.3, including zero-finding
  mobile/Wear lint, Gradle checks, task discovery, portable fixtures, and both
  debug APK assemblies.
- Fifteen isolated hostile mutations were rejected across root and module
  repository transport, SDK packages, setup ordering, Java selection, timeout, SDK
  visibility, canonical command execution, action pinning, duplicate workflow
  strings, maintained guidance, plan status, and hosted-boundary evidence.
- Exact-head push run `27662776027` and pull-request run `27662790231`
  succeeded on implementation head `adda63a1efa0a47493df580b96221335ffad145f`.
