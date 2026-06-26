#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
senders = (
    (
        root / "wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/crashlytics/CrashlyticsWearIntentService.java",
        "Connected node discovery failed for crashlytics report",
    ),
    (
        root / "wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/services/SendDummyMessageIntentService.java",
        "Connected node discovery failed for dummy message",
    ),
)


def fail(message):
    raise SystemExit(message)


for path, diagnostic in senders:
    source = path.read_text()
    method_start = source.index("    private void sendMessage(")
    method = source[method_start:]
    status_guard = "nodes == null || nodes.getStatus() == null || !nodes.getStatus().isSuccess()"
    if status_guard not in method:
        fail("%s must reject missing or failed connected-node discovery status." % path.name)
    if diagnostic not in method:
        fail("%s must use a constant connected-node discovery failure diagnostic." % path.name)
    if method.index(status_guard) > method.index("nodes.getNodes()"):
        fail("%s must validate discovery status before reading connected nodes." % path.name)
    if "nodes.getStatus().getStatusMessage()" in method:
        fail("%s must not log raw connected-node discovery provider details." % path.name)

print("Wear node discovery status contract passed.")
PY
