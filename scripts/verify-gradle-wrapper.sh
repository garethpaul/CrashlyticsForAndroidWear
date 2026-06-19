#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

GRADLE_USER_HOME="$TMP_DIR/good-home" \
  "$ROOT_DIR/gradlew" --version --no-daemon >"$TMP_DIR/good.out"

if ! grep -Fq 'Gradle 1.12' "$TMP_DIR/good.out"; then
  printf '%s\n' "Wrapper did not execute the reviewed Gradle 1.12 distribution." >&2
  cat "$TMP_DIR/good.out" >&2
  exit 1
fi

mkdir -p "$TMP_DIR/bad/gradle/wrapper"
cp "$ROOT_DIR/gradlew" "$TMP_DIR/bad/gradlew"
cp "$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar" "$TMP_DIR/bad/gradle/wrapper/gradle-wrapper.jar"
printf '%s\n' 'not a Gradle distribution' >"$TMP_DIR/bad/distribution.zip"

cat >"$TMP_DIR/bad/gradle/wrapper/gradle-wrapper.properties" <<EOF
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=0000000000000000000000000000000000000000000000000000000000000000
distributionUrl=file\://$TMP_DIR/bad/distribution.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

if GRADLE_USER_HOME="$TMP_DIR/bad-home" \
  "$TMP_DIR/bad/gradlew" --version --no-daemon >"$TMP_DIR/bad.out" 2>&1; then
  printf '%s\n' "Wrapper accepted a distribution with the wrong checksum." >&2
  cat "$TMP_DIR/bad.out" >&2
  exit 1
fi

if ! grep -Fq 'Verification of Gradle distribution failed!' "$TMP_DIR/bad.out"; then
  printf '%s\n' "Wrapper failed for an unexpected reason during checksum rejection." >&2
  cat "$TMP_DIR/bad.out" >&2
  exit 1
fi

printf '%s\n' "Gradle wrapper bootstrap and checksum rejection passed."
