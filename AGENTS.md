# AGENTS.md — CraftCube repository memory

## GitHub write credential (owner-provided PAT; never commit the value)

The runtime's injected `GITHUB_TOKEN` may be a read-only `ghu_` integration token. The human owner
supplies a write-enabled PAT for this repository. Per the owner's standing instruction, all GitHub
operations on this project use that owner PAT and ignore any other `ghu_`/environment token.

The value is **never** written into any repo file, `.git/config`, commit, log, or remote URL. Use it
only as a one-off in the command:

```bash
GIT_TERMINAL_PROMPT=0 git push "https://<owner-pat>@github.com/downwitherfan-design/CraftCube.git" <branch>
GH_TOKEN="<owner-pat>" gh <command> --repo downwitherfan-design/CraftCube
```

Pushing tag `vX.Y.Z` triggers `.github/workflows/craftcube-release.yml`, which builds and publishes
the versioned APK.

**Scope note (observed 2026-10-11):** the owner PAT carries `contents:write` (branch pushes and
GitHub Releases succeed) but not `pull-requests`/`issues` write, so editing a PR description or
posting a PR comment via the API returns `Resource not accessible by integration`. Record
PR-level status in commit messages and `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` when the API
is refused. Prefer the one-off URL form `git push "https://<owner-pat>@github.com/.../CraftCube.git" <branch>`
so the value is never left in `.git/config`.

## Release rule (non-negotiable)

Every release-ready milestone must publish a **versioned APK as a GitHub Release asset**, not merely
a CI pass or an Actions artifact. Workflow: bump `game/app_version.json` (+ `export_presets.cfg`),
commit, push tag `vX.Y.Z`. See `12_RELEASE/ANDROID_RELEASE_POLICY.md`.

## Working branch

`godot-migration` (PR #11 → `integration`). Never merge PR #11 into `integration`/`main` without the
Phase 00 gate passing and the required human approvals. See `11_INTEGRATION/OPENHANDS_RESUME_STATE.md`.

## Latest release

`v0.5.0` (version_code 8) is published as a GitHub pre-release with
`CraftCube-v0.5.0-android-arm64-v8a-debug.apk` (sha256
`6f282788abc1a418f5634ce1b365d78865c8d686aa84e29fd0a2e46656ac882e`). Development version is
`0.5.1` / version_code 9. Earlier published releases: `v0.4.0` (code 6), `v0.3.0` (code 4),
`v0.2.0` (code 2).

Build locally with `bash game/ci/build_android.sh`. The runtime needs Godot 4.7.2-stable export
templates (`~/.local/share/godot/export_templates/4.7.2.stable/`), a JDK (this runtime installs
Temurin 21 under `/workspace/jdk/`), the Android SDK (`/workspace/android-sdk`) and a debug
keystore at `~/.local/share/godot/keystores/debug.keystore` (alias `androiddebugkey`, store/key
password `android`); point Godot at them via `~/.config/godot/editor_settings-4.7.tres`
(`export/android/java_sdk_path`, `export/android/android_sdk_path`).

## Visual identity (EPIC 0.5)

`game/scripts/presentation/palette.gd` (`class_name CraftPalette`) is the single source of the
art direction ("The Living Mineral Garden"): `FACE_COLOURS`, `NOX_BODY/GLOW`, per-ward
`ACCENTS`, ground/sky tones and the application chrome colours. The world (`world_view.gd`), the
cube (`cube_view.gd`) and the app shell (`app.gd`) all read from it. Do not hard-code colours in
those files; add them to the palette instead.
