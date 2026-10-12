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
STAGE="$DIST/release"
EXPORT_PRESET="${EXPORT_PRESET:-Android}"
fail=0

step() { echo; echo "=== $1 ==="; }

step "clean stale build outputs"
# Never let a previous run's APK stand in for a failed fresh build.
rm -f "$DIST"/*.apk "$DIST"/*.apk.idsig
rm -rf "$STAGE"
mkdir -p "$DIST"

step "version validation (single source of truth)"
if ! python3 "$PROJECT/ci/validate_version.py" --root "$REPO_ROOT"; then
  echo "VERSION VALIDATION FAILED"; fail=1
fi

# Resolve the versioned artifact name and expected metadata from the source of truth.
APP_VERSION="$(python3 -c "import json;print(json.load(open('$PROJECT/app_version.json'))['app_version'])")"
VERSION_CODE="$(python3 -c "import json;print(json.load(open('$PROJECT/app_version.json'))['version_code'])")"
PACKAGE="$(python3 -c "import json;print(json.load(open('$PROJECT/app_version.json'))['android']['package'])")"
SIGNING="$(python3 -c "import json;print(json.load(open('$PROJECT/app_version.json'))['android']['signing'])")"
ARCHS="$(python3 -c "import json;print('_'.join(json.load(open('$PROJECT/app_version.json'))['android']['architectures']))")"
APK_NAME="CraftCube-v${APP_VERSION}-android-${ARCHS}-${SIGNING}.apk"
echo "target artifact: $APK_NAME  (versionCode $VERSION_CODE, package $PACKAGE)"

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
if "$GODOT_BIN" --headless --path "$PROJECT" --export-debug "$EXPORT_PRESET" "$DIST/CraftCube.apk"; then
  echo "APK produced:"
  ls -la "$DIST/CraftCube.apk"
else
  echo "EXPORT FAILED — check that export templates and the Android SDK/JDK are configured."
  fail=1
fi

step "verify APK metadata against the source of truth"
if [ -f "$DIST/CraftCube.apk" ]; then
  if ! python3 "$PROJECT/ci/verify_apk.py" "$DIST/CraftCube.apk" \
      --expect-package "$PACKAGE" \
      --expect-version "$APP_VERSION" \
      --expect-version-code "$VERSION_CODE" \
      --expect-arch "${ARCHS%%_*}" \
      --expect-signing "$SIGNING" \
      --require-signed; then
    echo "APK VERIFICATION FAILED"; fail=1
  fi
else
  echo "no APK to verify (export failed)"; fail=1
fi

step "stage versioned release artifact"
if [ "$fail" -eq 0 ]; then
  mkdir -p "$STAGE"
  cp "$DIST/CraftCube.apk" "$STAGE/$APK_NAME"
  SHA="$(sha256sum "$STAGE/$APK_NAME" | awk '{print $1}')"
  SIZE="$(stat -c%s "$STAGE/$APK_NAME")"
  printf '%s  %s\n' "$SHA" "$APK_NAME" > "$STAGE/$APK_NAME.sha256"
  cat > "$STAGE/$APK_NAME.json" <<EOF
{
  "app_version": "$APP_VERSION",
  "version_code": $VERSION_CODE,
  "package": "$PACKAGE",
  "architectures": ["${ARCHS%%_*}"],
  "signing": "$SIGNING",
  "apk": "$APK_NAME",
  "size_bytes": $SIZE,
  "sha256": "$SHA",
  "commit": "${GITHUB_SHA:-$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)}",
  "source": "game/ci/build_android.sh"
}
EOF
  echo "staged: $STAGE/$APK_NAME"
  cat "$STAGE/$APK_NAME.sha256"
else
  echo "SKIPPED staging: build or verification failed (no stale artifact is published)."
fi

echo
if [ "$fail" -eq 0 ]; then echo "CI: PASS"; else echo "CI: FAIL"; fi
test "$fail" -eq 0
