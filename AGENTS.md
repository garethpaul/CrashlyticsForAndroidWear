# AGENTS.md

## Repository purpose

`garethpaul/CrashlyticsForAndroidWear` is an Android application or sample. An example of Crashlytics implementation in an Android Wear Project.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper
- `gradle` - repository source or sample assets
- `mobile` - repository source or sample assets
- `wear` - repository source or sample assets

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Java (13).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- No dedicated test files were detected; treat `make check` as the minimum baseline.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- The committed Crashlytics API key is an all-zero placeholder that lets the legacy Gradle plugin run without storing a real Fabric credential.
- Replace the placeholder only in local, private configuration when testing against a real Crashlytics/Fabric project.
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- The Gradle wrapper is intentionally kept on the legacy 1.12 distribution, but it must use HTTPS. Fabric and Play Services Wear dependencies are pinned to avoid dynamic resolution drift, and the unused legacy wearable support dependency is intentionally removed.
- Debug builds disable Fabric resource tasks while the all-zero Crashlytics API key placeholder is present. Use local untracked configuration for real Crashlytics credentials when testing against Fabric.
- Wear crash forwarding sends stack traces as text, package-scopes internal broadcasts, and disconnects GoogleApiClient clients after message sends.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
