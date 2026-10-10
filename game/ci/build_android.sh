#!/usr/bin/env bash
# CraftCube Android-first CI: import, unit-test, then export a debug APK.
# Verifies the *pipeline*, not a shipped store build (that needs the owner's keystore).
#
# Requires on the runner:
#   - Godot 4.7.2-stable (matching the pinned engine; see game/docs/ENGINE_AND_BUILD.md)
#   - Godot export templates for 4.7.2-stable
#   - Android SDK (cmdline-tools + platform + build-tools) and a JDK, paths set in
#     the editor settings (or via the env vars below) before the export step.
#
# Env (optional): GODOT_BIN, ANDROID_HOME, JAVA_HOME
set -uo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
# Resolve repo root from this script's location so relative paths are never ambiguous.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT="$REPO_ROOT/game"
DIST="$REPO_ROOT/dist"
EXPORT_PRESET="${EXPORT_PRESET:-Android}"
fail=0

step() { echo; echo "=== $1 ==="; }

step "engine version"
"$GODOT_BIN" --version || fail=1

step "import (populate .godot cache)"
"$GODOT_BIN" --headless --path "$PROJECT" --import || fail=1

step "domain unit tests"
if ! "$GODOT_BIN" --headless --path "$PROJECT" --script res://tests/run_tests.gd; then
  echo "UNIT TESTS FAILED"; fail=1
fi

step "main scene smoke boot"
"$GODOT_BIN" --headless --path "$PROJECT" --quit-after 30 || fail=1

step "android export (debug)"
mkdir -p "$DIST"
if "$GODOT_BIN" --headless --path "$PROJECT" --export-debug "$EXPORT_PRESET" "$DIST/CraftCube.apk"; then
  echo "APK produced:"
  ls -la "$DIST/CraftCube.apk"
  sha256sum "$DIST/CraftCube.apk" 2>/dev/null || true
else
  echo "EXPORT FAILED — check that export templates and the Android SDK/JDK are configured."
  fail=1
fi

echo
if [ "$fail" -eq 0 ]; then echo "CI: PASS"; else echo "CI: FAIL"; fi
test "$fail" -eq 0
