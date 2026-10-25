#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
TARGET_DIR="${1:-$PWD}"
TARGET_DIR="$(CDPATH= cd -- "$TARGET_DIR" && pwd)"

WORKER_SOURCE="$SCRIPT_DIR/../.agent/WORKER_RULES.md"
PLAYTEST_SOURCE="$SCRIPT_DIR/playtest.mjs"
STATE_SOURCE="$SCRIPT_DIR/../templates/STATE.md"

mkdir -p "$TARGET_DIR/.agent" "$TARGET_DIR/scripts"

copy_if_needed() {
  source_path="$1"
  target_path="$2"
  if [ "$source_path" = "$target_path" ]; then
    printf 'unchanged %s\n' "$target_path"
    return
  fi
  cp "$source_path" "$target_path"
  printf 'copied   %s\n' "$target_path"
}

copy_if_needed "$WORKER_SOURCE" "$TARGET_DIR/.agent/WORKER_RULES.md"
copy_if_needed "$PLAYTEST_SOURCE" "$TARGET_DIR/scripts/playtest.mjs"

if [ -e "$TARGET_DIR/STATE.md" ]; then
  printf 'kept     %s (already exists)\n' "$TARGET_DIR/STATE.md"
else
  cp "$STATE_SOURCE" "$TARGET_DIR/STATE.md"
  printf 'created  %s\n' "$TARGET_DIR/STATE.md"
fi

printf 'AI workflow bootstrap complete in %s\n' "$TARGET_DIR"
