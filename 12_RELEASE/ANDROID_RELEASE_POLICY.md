# CraftCube Android Release Policy — Versioned APKs via GitHub Releases

| Field | Value |
|---|---|
| Owner | AI-13 — Integration / Technical Production / Architecture Governance |
| Status | ACTIVE (mandatory). Applies to every future milestone, build and handoff. |
| Applies to | Android delivery for the Godot 4.x project under `game/` |
| Related | `12_RELEASE/phase_00/RELEASE_AND_BUILD_DIRECTION_LOCK_V1.md`, `.github/workflows/craftcube-release.yml`, `game/ci/build_android.sh` |
| Supersedes | nothing (new permanent rule) |

This is a permanent project requirement. Future agents inherit it; it is not a one-time task.
It is enforced by code in the pipeline, not by convention alone.

## 1. The rule

Every release-ready development milestone must produce a real Android APK and make it
downloadable through the repository's **GitHub Releases** section.

A successful CI run, a local APK, or an Actions artifact alone does **not** satisfy the rule.
The expected deliverables are all of:

1. A real, non-empty APK built from the exact candidate source commit.
2. A versioned APK filename.
3. A corresponding versioned release record in GitHub Releases.
4. Release notes describing changes, verification results and known limitations.
5. A reproducible record linking the release to its source commit and build evidence.

The APK is produced by the pipeline and attached as a release asset. It is never committed to
source (see `.gitignore`: `dist/`, `*.apk`, `*.aab`).

## 2. Versioning

Semantic Versioning `MAJOR.MINOR.PATCH`:

- **PATCH** — bug fixes, stability, small polish with no meaningful new capability.
- **MINOR** — new gameplay features and backward-compatible functional improvements.
- **MAJOR** — major product milestones or incompatible changes (e.g. breaking save/progression).

Choose the version from the actual changes. Never invent a version, reuse a published version,
or bump merely to look new. Git tags use the form `vMAJOR.MINOR.PATCH`.

`version_code` is a **separate, strictly increasing** Android integer. Never publish two
different APKs with the same version and version code.

## 3. Single source of truth

`game/app_version.json` is authoritative:

```json
{
  "app_version": "0.2.0",
  "version_code": 2,
  "android": { "package": "...", "min_sdk": 24, "target_sdk": 36,
               "architectures": ["arm64-v8a"], "signing": "debug" },
  "released": [ { "version": "0.1.0", "version_code": 1, ... } ]
}
```

Consistency is enforced by `game/ci/validate_version.py`, which fails if any of these drift:

- `game/export_presets.cfg` → `version/name`, `version/code`, `package/unique_name`,
  enabled `architectures/*`, `gradle_build/min_sdk`
- `game/scripts/game/version.gd` (the runtime reader; must read `res://app_version.json`)
- the `released[]` ledger (monotonic `version_code`, no version reuse)

The on-screen version in the HUD comes from the same file via `Version.display()`.

## 4. Filenames

`CraftCube-vMAJOR.MINOR.PATCH-android-<arch>-<signing>.apk`, e.g.

- `CraftCube-v0.2.0-android-arm64-v8a-debug.apk` (development)
- `CraftCube-v0.2.0-android-arm64-v8a-release.apk` (properly release-signed)

The filename must accurately state the version, platform/architecture and signing/build type.
Never name a debug-signed APK as a production release.

## 5. Pipeline

`bash game/ci/build_android.sh`:

1. Deletes stale `dist/*.apk` outputs (never publishes a previous run's artifact).
2. Runs `validate_version.py`.
3. Imports the project, runs the full test suite, boots the main scene.
4. Exports the debug APK from the current commit.
5. Runs `verify_apk.py` against `app_version.json` (package, versionName, versionCode, minSdk,
   architecture, signing) and requires a signature.
6. On success only, stages the versioned APK plus `.sha256` and `.json` provenance into
   `dist/release/`.
7. Fails visibly (`CI: FAIL`, non-zero exit) if any step fails.

`.github/workflows/craftcube-release.yml` builds on tag `v*` or manual dispatch, uploads the
versioned APK as an Actions artifact, and publishes a GitHub Release with the APK attached and
rendered notes. If permissions prevent the Release, the step fails visibly; the versioned APK
and checksum remain in `dist/release/` and as an Actions artifact, and the blocked operation is
reported — it is never silently skipped or claimed as success.

`game/ci/verify_apk.py` reads the real artifact without aapt/apksigner: it parses the ZIP
central directory, the binary `AndroidManifest.xml` (AXML string pool + element/attribute
chunks), `lib/<abi>/` entries and the signature entries / APK Signing Block.

## 6. Debug vs production

While no valid production signing key exists, the pipeline produces a **debug** APK, labelled
as a development/pre-release asset and stated as debug-signed and not store-ready. Never invent
or commit a production keystore, signing password or other release secret. A production release
may be labelled stable/store-ready only after release-signing and validation genuinely pass.

## 7. Release notes

Each versioned APK's notes must state: application version and version code; source commit and
tag; new features and important fixes; test and build results for that exact commit; APK
filename, architecture, signing type, size and SHA-256; known limitations (including whether a
physical device was tested); and whether the build is development/pre-release or production.

Template: `12_RELEASE/release_notes/RELEASE_NOTES_TEMPLATE.md`.

## 8. Acceptance criteria (definition of done for a release)

- Version metadata has one validated source of truth.
- Android version codes increase monotonically.
- A fresh APK builds from the candidate commit.
- The artifact's version and package metadata are verified.
- A versioned APK is attached to a GitHub Release when permissions and release conditions allow.
- The release record references the exact tested commit and includes the checksum and truthful notes.
- The process is documented and repeatable by future sessions.

## 9. Ownership

`12_RELEASE/` and `.github/` are **AI-12**-owned (`04_AI_ACCOUNTS/ACCOUNT_MATRIX.md`,
`04_AI_ACCOUNTS/AI-12_Track.md`). This policy, the pipeline scripts under `game/ci/`, and the
runtime version reader are delivered by AI-13 as integration/release enablement. Changes to the
AI-12-owned release workflow are raised as change requests (`11_INTEGRATION/CHANGE_REQUESTS.md`)
rather than silently overwritten; AI-12 confirms them on its branch.
