#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-event-snapshots.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

STUB_DIR="$TMP_DIR/com/google/android/gms/wearable"
CLASS_DIR="$TMP_DIR/classes"
mkdir -p "$STUB_DIR" "$CLASS_DIR"

cat > "$STUB_DIR/MessageEvent.java" <<'EOF'
package com.google.android.gms.wearable;

public interface MessageEvent {
    byte[] getData();
    String getPath();
    int getRequestId();
    String getSourceNodeId();
}
EOF

cat > "$STUB_DIR/Node.java" <<'EOF'
package com.google.android.gms.wearable;

public interface Node {
    String getDisplayName();
    String getId();
}
EOF

javac -d "$CLASS_DIR" \
  "$STUB_DIR/MessageEvent.java" \
  "$STUB_DIR/Node.java" \
  "$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/SerializableMessageEvent.java" \
  "$ROOT_DIR/mobile/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/SerializableNode.java" \
  "$ROOT_DIR/scripts/WearEventSnapshotCheck.java"

java -cp "$CLASS_DIR" WearEventSnapshotCheck
