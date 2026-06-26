#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
HANDLER=${UNCAUGHT_HANDLER_SOURCE:-"$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrachlyticsWearUncaughtExceptionHandler.java"}

python3 - "$HANDLER" <<'PY'
from pathlib import Path
import sys

source_path = Path(sys.argv[1])
source = source_path.read_text(encoding="utf-8")

def extract_block(text, opening_brace):
    depth = 0
    for index in range(opening_brace, len(text)):
        character = text[index]
        if character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return text[opening_brace + 1:index]
    raise SystemExit("Uncaught handler delegation contract failed: block is unbalanced")

signature = "public void uncaughtException(Thread thread, Throwable ex)"
signature_index = source.find(signature)
if signature_index < 0:
    raise SystemExit("Uncaught handler delegation contract failed: method signature is missing")

body_start = source.find("{", signature_index + len(signature))
if body_start < 0:
    raise SystemExit("Uncaught handler delegation contract failed: method body is missing")

body = extract_block(source, body_start)
try_index = body.find("try {")
finally_index = body.find("finally {")

if min(try_index, finally_index) < 0:
    raise SystemExit(
        "Uncaught handler delegation contract failed: forwarding must be protected by try/finally delegation"
    )

try_brace = body.find("{", try_index)
finally_brace = body.find("{", finally_index)
try_body = extract_block(body, try_brace)
finally_body = extract_block(body, finally_brace)
startup = "mApplication.startService(errorIntent);"
previous_guard = "mDefaultUncaughtExceptionHandler != null"
delegation = "mDefaultUncaughtExceptionHandler.uncaughtException(thread, ex);"

if startup not in try_body or previous_guard not in finally_body or delegation not in finally_body:
    raise SystemExit(
        "Uncaught handler delegation contract failed: service startup must be in try and previous-handler delegation in finally"
    )

if body.count(delegation) != 1:
    raise SystemExit(
        "Uncaught handler delegation contract failed: previous handler must be delegated to exactly once"
    )

print("Uncaught handler delegation contract passed")
PY
