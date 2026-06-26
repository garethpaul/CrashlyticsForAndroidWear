#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE="$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrachlyticsWearUncaughtExceptionHandler.java"
CONTRACT="$ROOT_DIR/scripts/test-uncaught-handler-delegation.sh"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM

reject_mutation() {
  name=$1
  source=$2
  if UNCAUGHT_HANDLER_SOURCE="$source" "$CONTRACT" >/dev/null 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    exit 1
  fi
  printf '%s\n' "Mutation rejected: $name"
}

cp "$SOURCE" "$TEMP_DIR/no-finally.java"
sed -i.bak 's/} finally {/} catch (RuntimeException ignored) {/' "$TEMP_DIR/no-finally.java"
rm "$TEMP_DIR/no-finally.java.bak"
reject_mutation "removed finally guarantee" "$TEMP_DIR/no-finally.java"

python3 - "$SOURCE" "$TEMP_DIR/delegate-after-finally.java" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
delegation = "mDefaultUncaughtExceptionHandler.uncaughtException(thread, ex);"
source = source.replace(delegation, 'Log.e(MYLOGGER, "Delegation removed");', 1)
finally_start = source.index("finally {")
opening_brace = source.index("{", finally_start)
depth = 0
closing_brace = None
for index in range(opening_brace, len(source)):
    if source[index] == "{":
        depth += 1
    elif source[index] == "}":
        depth -= 1
        if depth == 0:
            closing_brace = index
            break
if closing_brace is None:
    raise SystemExit("finally block is unbalanced")
source = source[:closing_brace + 1] + "\n        " + delegation + source[closing_brace + 1:]
Path(sys.argv[2]).write_text(source, encoding="utf-8")
PY
reject_mutation "moved delegation after finally" "$TEMP_DIR/delegate-after-finally.java"

python3 - "$SOURCE" "$TEMP_DIR/start-before-try.java" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
startup = "mApplication.startService(errorIntent);"
source = source.replace(startup, 'Log.e(MYLOGGER, "Service startup removed");', 1)
source = source.replace("try {", startup + "\n        try {", 1)
Path(sys.argv[2]).write_text(source, encoding="utf-8")
PY
reject_mutation "moved service startup before try" "$TEMP_DIR/start-before-try.java"

printf '%s\n' "All uncaught-handler delegation mutations were rejected"
