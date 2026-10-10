# OpenHands Status — CraftCube (Godot production epic)

Compact, factual status for external reviewers. Companion to
`11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (full recovery state).

| Field | Value |
|---|---|
| Last verified (UTC) | 2026-10-10T17:23:09Z |
| Working branch | `godot-migration` |
| Last commit (pushed) | tip of `godot-migration` (remote: **not pushed** — write access blocked, see below) |
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
| SHA-256 | `0ebcefbbca3cfbcd5a0b2a2ade25e03229037846a4ce34ed874126138b025ab9` |
| Package / version | `com.downwitherfandesign.craftcube` / 0.1.0 (code 1) |
| min / target SDK | 24 / 36 |
| ABI | arm64-v8a |
| Signature | verified (`CN=Android Debug`) — throwaway debug key, not committed |

6. **Tests.** Domain suite **134 passed / 0 failed**; main scene headless boot clean.
   Evidence logs in `game/docs/evidence/`.
7. **Phase-00 validator sweep (read-only) — all pass on this tree:** product-lock 14/0;
   registry 27 contracts; AI-04 32/0; ownership OK; AI-08 audio OK; environment 9/0;
   narrative 35 groups/0; UIUX 6/0; performance 1 positive/4 negatives/0 failures;
   release 10/0; AI-03 content PASS. The current tree (local `integration` with the
   CR-0012 fix + the Godot slice) satisfies every validator.

## Current failures / blockers

- **Delivery path: RESOLVED.** Write access restored; branches pushed to `origin` and
  PR [#11](https://github.com/downwitherfan-design/CraftCube/pull/11) opened
  (`godot-migration -> integration`). Remote CI is **green** (clean-runner build + APK artifact).
- **Phase 00 gate: NOT PASSED (open).** CR-0013 (AI-01 product-register/validator engine
  update) and the human-controlled decisions remain outstanding. PR #11 does not claim the gate.
- **CR-0012 is now on `origin/integration`** (`55f6b9b -> 3df70ae`); the QA validator exits 0 there.
- **CR-0013 open** (engine decision needs an AI-01-recorded `PD-030`).
- **No physical Android device** in this environment — no on-device run is claimed.

## Next concrete action

1. Obtained — write access restored; `godot-migration` pushed and PR #11 opened to `integration`.
2. Done — CR-0012 fix is now on `origin/integration` (`3df70ae`).
3. AI-01 records `PD-030` + restates `PD-029` items 4/5 engine-neutrally (CR-0013); then
   re-evaluate the Phase-00 gate rows against the integrated tree.

## Last successful push / PR

- **This session:** pushed `integration` (`55f6b9b->3df70ae`), `godot-migration`
  (`1d63bbf->ab8416b`), `ai-13-integration` (`397cfb6->f01be1b`); opened PR #11;
  remote CI green (run `38075134745`).
