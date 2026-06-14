---
title: Make Root Override Protection
type: reliability
status: in_progress
date: 2026-06-14
---

# Make Root Override Protection

## Status: In Progress

## Problem Frame

The Makefile derives its root from `MAKEFILE_LIST`, and the baseline checker
requires that assignment, but command-line variables can still override it.
That redirects both repository scripts and SDK-backed Gradle commands.

## Scope Boundaries

- Protect only the repository-derived `ROOT`; preserve the intentional
  `ANDROID_HOME` and `GRADLE` overrides.
- Preserve the reviewed Gradle wrapper, Android manifests, dependencies,
  privacy contracts, Wear protocol, and application behavior.
- Do not add credentials or run paired-device Crashlytics delivery.

## Requirements

- R1. A hostile `ROOT` variable must not redirect scripts or Gradle.
- R2. Repository and external-working-directory verification must pass.
- R3. The existing Make-root checker contract must require the protected form.
- R4. Completed plan evidence and isolated mutations must be enforced.

## Verification

Pending implementation and validation.
