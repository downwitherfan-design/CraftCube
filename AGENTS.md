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

`v0.3.0` (version_code 4) is published as a GitHub pre-release with
`CraftCube-v0.3.0-android-arm64-v8a-debug.apk` (sha256
`7abcd64872cecc9bc1596e501a4df9df5aa81380eb07dac981c0851b90b90f78`). Development version is
`0.3.1` / version_code 5. Build locally with `bash game/ci/build_android.sh` (needs JDK 21 + the
Android SDK; the runtime here installs them under `/workspace/android-sdk`).
