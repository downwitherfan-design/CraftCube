# CraftCube {{TAG}} — Android release

> Development / pre-release build. Debug-signed. Not store-ready.
> Generated from this template by `.github/workflows/craftcube-release.yml`.

| Field | Value |
|---|---|
| Application version | `{{APP_VERSION}}` |
| Android version code | `{{VERSION_CODE}}` |
| Git tag | `{{TAG}}` |
| Source commit | `{{COMMIT}}` |
| APK file | `{{APK_NAME}}` |
| Architecture | `{{ARCH}}` |
| Signing | `{{SIGNING}}` (development keystore) |
| Size (bytes) | `{{SIZE}}` |
| SHA-256 | `{{SHA256}}` |

## What's in this build

<!-- Replace with the player-facing changes for this version. -->

## Verification (exact commit above)

- Domain test suite: `godot --headless --path game --script res://tests/run_tests.gd`
- Android pipeline: `bash game/ci/build_android.sh` → `CI: PASS`
- APK metadata verified by `game/ci/verify_apk.py` (package, versionName, versionCode, minSdk,
  architecture, signing) against `game/app_version.json`.
- Version consistency verified by `game/ci/validate_version.py`.

## Known limitations

- Debug-signed with a development keystore; **not** a production/store release.
- No physical Android device was used; the APK was built and statically verified in CI.
- The APK is produced by the pipeline and attached as a release asset; it is not committed to source.

## Policy

See `12_RELEASE/ANDROID_RELEASE_POLICY.md`. Every release must produce a versioned APK
attached to a GitHub Release; an ordinary CI pass is not the release deliverable.
