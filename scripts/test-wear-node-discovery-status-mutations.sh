#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-node-discovery-status.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

mkdir "$TMP_DIR/candidate"
(cd "$ROOT_DIR" && tar --exclude=.git -cf - .) | (cd "$TMP_DIR/candidate" && tar -xf -)

if ! "$TMP_DIR/candidate/scripts/test-wear-node-discovery-status.sh" >"$TMP_DIR/control.out" 2>&1; then
  printf '%s\n' "Unmodified candidate failed the node discovery status contract." >&2
  cat "$TMP_DIR/control.out" >&2
  exit 1
fi

expect_rejected() {
  name=$1
  file=$2
  old=$3
  new=$4

  rm -rf "$TMP_DIR/repo"
  cp -R "$TMP_DIR/candidate" "$TMP_DIR/repo"
  python3 - "$TMP_DIR/repo/$file" "$old" "$new" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]
source = path.read_text()
if old not in source:
    raise SystemExit("Mutation source was not found: %s" % old)
path.write_text(source.replace(old, new, 1))
PY

  if "$TMP_DIR/repo/scripts/test-wear-node-discovery-status.sh" >"$TMP_DIR/$name.out" 2>&1; then
    printf '%s\n' "Hostile node discovery mutation was accepted: $name" >&2
    cat "$TMP_DIR/$name.out" >&2
    exit 1
  fi

  printf '%s\n' "Rejected hostile node discovery mutation: $name"
}

CRASH_SERVICE=wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java
DUMMY_SERVICE=wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/services/SendDummyMessageIntentService.java
GUARD='nodes == null || nodes.getStatus() == null || !nodes.getStatus().isSuccess()'

expect_rejected crash-missing-status-guard "$CRASH_SERVICE" "$GUARD" 'nodes == null'
expect_rejected dummy-missing-status-guard "$DUMMY_SERVICE" "$GUARD" 'nodes == null'
expect_rejected crash-accepts-failure "$CRASH_SERVICE" '!nodes.getStatus().isSuccess()' 'nodes.getStatus().isSuccess()'
expect_rejected dummy-accepts-failure "$DUMMY_SERVICE" '!nodes.getStatus().isSuccess()' 'nodes.getStatus().isSuccess()'
expect_rejected crash-missing-diagnostic "$CRASH_SERVICE" 'Connected node discovery failed for crashlytics report' 'Crash discovery issue'
expect_rejected dummy-missing-diagnostic "$DUMMY_SERVICE" 'Connected node discovery failed for dummy message' 'Dummy discovery issue'

printf '%s\n' "Wear node discovery hostile mutation tests passed."
