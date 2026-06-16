# Security Policy

## Supported Versions

The supported security scope for `CrashlyticsForAndroidWear` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: An example of Crashlytics implementation in an Android Wear Project.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/CrashlyticsForAndroidWear` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- Both launcher activities are explicitly exported for user entry, and the
  mobile Wear listener is explicitly exported only for the legacy Google Play
  services `BIND_LISTENER` action. Internal crash receivers and Wear intent
  services are explicitly non-exported.

- This repository appears to be an Android mobile application or sample. The active security scope is the code and documentation on the default branch.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Mobile and wear app-data backup should stay disabled by default for this sample.
- Internal Wear listener broadcasts should avoid Java object serialization and keep payloads as typed Intent extras.
- Mobile Crashlytics ingestion should accept only the declared metadata keys,
  must not log metadata values, and must not collect hardware serial identifiers.
- Wear uncaught-exception handling must not write throwable stack traces to Logcat;
  the report payload and previous default handler retain the original throwable.
- Dummy Wear message receipt logs must not include decoded or raw payload content;
  retain only constant delivery diagnostics.
- Dummy Wear message path diagnostics must not include peer-controlled path values;
  retain only a constant category before parent fallback handling.
- Crashlytics Wear message path diagnostics must not include peer-controlled path values;
  retain only a constant category before parent fallback handling.
- Malformed Crashlytics payload diagnostics must not include peer-triggered parser exception details.
- Wear send diagnostics must not expose paired-device display names or raw provider status messages;
  retain only constant outcome categories.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: build.gradle, gradle.properties. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- GitHub Actions runs the guarded `make check` baseline with a commit-pinned
  checkout action, read-only repository access, and hosted Android SDK
  variables cleared; review workflow, Gradle, and checker changes as part of
  the supply-chain surface.
- The direct wrapper uses a generated Gradle 8.14.5 bootstrap and pins the
  official Gradle 1.12 distribution checksum; review all wrapper artifacts and
  checksum changes as one supply-chain boundary.

## Mobile Privacy Notes

The mobile Wear event broadcaster keeps paired-peer message paths out of Logcat while preserving package-scoped routing.
Wear peer connection diagnostics omit paired-device display names while preserving package-scoped node extras.

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
