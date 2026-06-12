---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Authenticate the direct Gradle wrapper while retaining Gradle 1.12, the legacy
Android/Fabric/Play Services toolchain, both mobile/Wear modules, and crash
forwarding behavior.

## Requirements

- Regenerate all wrapper artifacts with official Gradle 8.14.5 tooling while
  retaining the official Gradle 1.12 all distribution.
- Pin the official distribution SHA-256 and exact generated artifacts.
- Preserve build files, modules, credentials placeholder, manifests, crash
  reporting, bounded Wear waits, and existing credential-free CI.
- Pass fresh bootstrap, wrong-checksum rejection, SDK-free/SDK-backed gates,
  external-working-directory execution, hostile mutations, and hosted gates.

## Scope And Verification

Only wrapper artifacts, checker contracts, guidance, and evidence change.

Verification completed on 2026-06-12 with Amazon Corretto 8 and the local
Android SDK:

- A fresh temporary Gradle user home downloaded and ran the official Gradle
  1.12 distribution through the generated wrapper.
- A disposable wrapper with an incorrect checksum was rejected before Gradle
  execution.
- SDK-free `make check` passed before and after the wrapper change.
- SDK-backed `make check` passed, including mobile and Wear lint, Gradle task
  discovery, checks, and both debug APK assemblies.
- The full gate passed from an external working directory.
- Checker hostile mutations rejected altered properties, launcher, JAR,
  guidance, and completion evidence.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle 1.12 checksum](https://services.gradle.org/distributions/gradle-1.12-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)
