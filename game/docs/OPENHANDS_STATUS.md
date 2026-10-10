# OpenHands Status — CraftCube (Godot production epic)

Compact, factual status for external reviewers. Companion to
`11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (full recovery state).

| Field | Value |
|---|---|
| Last verified (UTC) | 2026-10-10T17:23:09Z |
| Working branch | `godot-migration` |
| Last commit (pushed) | `acb8951` (remote: **not pushed** — write access blocked, see below) |
| Engine | Godot 4.7.2-stable + GDScript, Android-first |
| Milestone | M1 — delivery path + deep audit + hardening + verified Android build |
| Phase 00 gate | **NOT PASSED** (CR-0012 fix not yet on `integration`; CR-0013 + human ODs open) |

## Completed work (this session)

1. **Credential check.** The runtime's `GITHUB_TOKEN` is a read-only `ghu_` integration
   token: `POST /git/refs` → `Resource not accessible by integration`; `git push`
   (with a `$GITHUB_TOKEN`-backed helper) → `403`. **Remote writes are blocked.**
2. **Delivery path documented.** The write-enabled PAT used in a prior session
   (`/tmp/.ghtok`, `GIT_ASKPASS=/tmp/.gitaskpass`) is **absent**; nothing was written
   to any repo file or remote URL.
3. **Deep audit of `game/`** (all 11 GDScript classes, scene, presets, tests read in
   full). The cube geometry, permutations, order-4/inverse properties, determinism,
   seeded scramble, reverse-replay solvability, and the level-3 Y-axis-lock playability
   were **re-verified** (now by property/round-trip tests, not only the original suite).
4. **Defects found and fixed** (all covered by new regression tests):
   - Duplicate completion effects: a repeated "I solved it" re-fired the world reaction
     (double-lighting a marker), reward, and discovery → `confirm_solve()` is now
     idempotent per level.
   - Non-atomic save → temp-file + `flush()` + atomic `rename()`.
   - Unparseable/wrong-typed save could mis-load → quarantined to `<path>.corrupt`,
     arrays type-checked, negative index clamped, over-cap loadout truncated.
   - `next_level()` did not persist the new position and relied on an external click →
     it now advances to the nearest unsolved level and saves.
   - Hardcoded reward→equipment mapping → single source of truth
     `StoryContent.equipment_id_for()`.
   - `build_android.sh` wrote a relative export path that Godot resolved against
     `game/`, so the export silently failed and a stale APK could read as fresh → the
     script now resolves absolute paths and prints the artifact SHA-256.
5. **Android build verified (genuine).** `bash game/ci/build_android.sh` → **CI: PASS**;
   `dist/CraftCube.apk` rebuilt from the working tree:

| Artifact field | Value |
|---|---|
| Size | 28,338,657 bytes |
| SHA-256 | `110e106ad9e66c1fe926e15fbe0fba85bf03db47baef70ae34035645b3f1b486` |
| Package / version | `com.downwitherfandesign.craftcube` / 0.1.0 (code 1) |
| min / target SDK | 24 / 36 |
| ABI | arm64-v8a |
| Signature | verified (`CN=Android Debug`) — throwaway debug key, not committed |

6. **Tests.** Domain suite **116 passed / 0 failed**; main scene headless boot clean.
   Evidence logs in `game/docs/evidence/`.

## Current failures / blockers

- **Remote write BLOCKED.** Required fix: register a write-enabled credential as the
  supported `GITHUB_TOKEN`/`GH_TOKEN` secret (scope `repo`). A `ghu_` integration token
  cannot push to this repo.
- **CR-0012 not on `integration`.** The fix `8bd03f0` (branch `ai-10-qa`) is verified to
  make the QA validator exit 0, but `origin/integration` is still `55f6b9b`.
- **CR-0013 open** (engine decision needs an AI-01-recorded `PD-030`).
- **No physical Android device** in this environment — no on-device run is claimed.

## Next concrete action

1. Restore write access, push `godot-migration`, open a PR to `integration`
   (base corrected from `ai-13-integration` if it still points there).
2. Publish the CR-0012 fix branch (`ai-10-qa`) and land it on `integration`.
3. Have AI-01 record `PD-030` + restate `PD-029` items 4/5 engine-neutrally (CR-0013).

## Last successful push / PR

- Last successful remote write: prior session (`ai-13-integration`, `ai-09-narrative`).
- **This session: none** — no push and no PR were performed; no remote state was changed.
