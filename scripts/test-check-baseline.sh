#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)

cleanup() {
  git -C "$ROOT_DIR" worktree remove --force "$TMP_DIR/repo" >/dev/null 2>&1 || true
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

if ! grep -Fq 'uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654' "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq 'run: scripts/verify-gradle-wrapper.sh' "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions must execute the reviewed wrapper verification with pinned Java setup." >&2
  exit 1
fi

git -C "$ROOT_DIR" worktree add --detach "$TMP_DIR/repo" HEAD >/dev/null
git -C "$ROOT_DIR" diff --binary HEAD -- . ':!scripts/test-check-baseline.sh' |
  git -C "$TMP_DIR/repo" apply
git -C "$TMP_DIR/repo" add -A
git -C "$TMP_DIR/repo" \
  -c user.name='Baseline Test' \
  -c user.email='baseline-test@example.invalid' \
  commit -m 'test candidate' >/dev/null

expect_rejected() {
  name=$1
  mutation=$2

  git -C "$TMP_DIR/repo" reset --hard HEAD >/dev/null
  sh -c "$mutation" sh "$TMP_DIR/repo"

  if "$TMP_DIR/repo/scripts/check-baseline.sh" >"$TMP_DIR/$name.out" 2>&1; then
    printf '%s\n' "Hostile mutation was accepted: $name" >&2
    cat "$TMP_DIR/$name.out" >&2
    exit 1
  fi
}

expect_rejected "ignored-baseline-failure" '
  repo=$1
  sed -i.bak "s/run: make check/run: make check || true/" "$repo/.github/workflows/check.yml"
  rm "$repo/.github/workflows/check.yml.bak"
'

expect_rejected "skipped-baseline-step" '
  repo=$1
  sed -i.bak "/name: Run baseline/a\\
        if: false" "$repo/.github/workflows/check.yml"
  rm "$repo/.github/workflows/check.yml.bak"
'

expect_rejected "extra-workflow-step" '
  repo=$1
  cat >>"$repo/.github/workflows/check.yml" <<EOF

      - name: Unreviewed command
        run: echo unreviewed
EOF
'

expect_rejected "wrong-distribution-checksum" '
  repo=$1
  sed -i.bak "s/cf111fcb34804940404e79eaf307876acb8434005bc4cc782d260730a0a2a4f2/0000000000000000000000000000000000000000000000000000000000000000/" "$repo/gradle/wrapper/gradle-wrapper.properties"
  rm "$repo/gradle/wrapper/gradle-wrapper.properties.bak"
'

expect_rejected "modified-wrapper-jar" '
  repo=$1
  printf x >>"$repo/gradle/wrapper/gradle-wrapper.jar"
'

expect_rejected "modified-wrapper-verifier" '
  repo=$1
  printf "exit 0\\n" >>"$repo/scripts/verify-gradle-wrapper.sh"
'

expect_rejected "private-wear-listener" '
  repo=$1
  python3 - "$repo/mobile/src/main/AndroidManifest.xml" <<EOF
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
marker = "arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerBroadcaster"
before, after = text.split(marker, 1)
after = after.replace("android:exported=\"true\"", "android:exported=\"false\"", 1)
path.write_text(before + marker + after)
EOF
'

expect_rejected "exported-internal-wear-service" '
  repo=$1
  python3 - "$repo/wear/src/main/AndroidManifest.xml" <<EOF
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
marker = "arno.di.loreto.crashlyticsforandroidwear.crashlytics.CrashlyticsWearIntentService"
before, after = text.split(marker, 1)
after = after.replace("android:exported=\"false\"", "android:exported=\"true\"", 1)
path.write_text(before + marker + after)
EOF
'

printf '%s\n' "Baseline hostile mutation tests passed."
