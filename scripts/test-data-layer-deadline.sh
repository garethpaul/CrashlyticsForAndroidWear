#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/crashlytics-data-layer-deadline.XXXXXX")
cleanup() {
  rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 1' 1 2 3 15

javac -source 1.7 -target 1.7 -Xlint:-options \
  -d "$BUILD_DIR" \
  "$ROOT_DIR/wear/src/main/java/arno/di/loreto/crashlyticsforandroidwear/wearable/DataLayerDeadline.java" \
  "$ROOT_DIR/scripts/DataLayerDeadlineCheck.java"
java -cp "$BUILD_DIR" arno.di.loreto.crashlyticsforandroidwear.wearable.DataLayerDeadlineCheck
