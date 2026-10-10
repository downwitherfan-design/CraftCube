# OpenHands Resume State â€” CraftCube Recovery

AI-13-owned persistent checkpoint. Purpose: let this work resume correctly after a
context reset, session end, or handover. Factual only; every claim carries a label
(VERIFIED / INFERRED / ASSUMED / UNKNOWN / CONFLICT / BLOCKED). Update after each
meaningful milestone.

## 1. Last verified repository state

- **Inspection time:** 2026-10-10 (recovery session).
- **Repo:** `downwitherfan-design/CraftCube`.
- **Default branch:** `main` = `584141ce53ce87cc934b08d6a026f7de6b95bc24` ("Initial CraftCube v7 WORLDCLASS baseline"); `integration` is now `c4cc93e` (13-branch Phase 00 merge). VERIFIED.
- **Working branch for this session:** `ai-13-integration` @ `4580959` (pushed). `integration` advanced from `584141c` to `c4cc93e` (all 13 branches merged, steps 1â€“8). VERIFIED.
- **PRs:** #9 MERGED (mergeCommit `c607272`), #10 MERGED (`6b5818f`). #1,#2,#3,#4,#5,#6,#7,#8 still show OPEN though each head is an ancestor of `integration` (their content is integrated; GitHub records them open because the direct `integration` push â€” see Â§4). VERIFIED.
- **Clone note:** local clone was shallow with refspec limited to `main`; repaired by `git fetch --unshallow` and setting `remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*`. VERIFIED.
- **REMOTE WRITE ACCESS: RESOLVED (2026-10-10).** The runtime's `GH_TOKEN`/`GITHUB_TOKEN` still inject the old read-only `ghu_` integration token (403 on write). A write-enabled PAT provided by the human owner was applied out-of-band: it is read from a `600` file at `/tmp/.ghtok` (outside the repository) and used via `GIT_ASKPASS=/tmp/.gitaskpass` for Git and `GH_TOKEN="$(cat /tmp/.ghtok)"` for `gh`/API. The token value is never printed, logged, committed, or written into any repo file or remote URL. Verified writes: created+deleted a probe ref, pushed `ai-13-integration`, retargeted PRs #1/#5, pushed `ai-09-narrative`. NOTE for any future runtime: the credential must be registered as the supported `GH_TOKEN`/`GITHUB_TOKEN` secret; the current runtime does not expose it there.
  - **REGRESSION (Session 4, 2026-10-10):** the out-of-band PAT is **absent** in the current runtime (`/tmp/.ghtok` and `/tmp/.gitaskpass` do not exist). The injected `GITHUB_TOKEN` has **empty OAuth scopes** (`x-oauth-scopes:` blank; read works, `x-accepted-github-permissions: metadata=read`). `git ls-remote` reads fine; `git push` has no credential helper and prompts for a username. **Remote write is BLOCKED again** in this environment. Branch `godot-migration` is committed locally only. See §11.

## 2. Branch / PR inventory (VERIFIED 2026-10-10)

Remote heads verified via `git ls-remote`: `main`, `integration`, and `ai-01-product` â€¦ `ai-13-integration`.

| PR | Branch | Base | Head | Mergeable | Note |
|---|---|---|---|---|---|
| #9 | ai-13-integration | integration | 80602dd | CLEAN | step 1 of merge order |
| #10 | ai-01-product | integration | 8846a7b | CLEAN | step 2, product/IP lock |
| #5 | ai-09-narrative | integration | ea12651 | (rechecking) | CR-0008 resolved; CR-0011 fixed â†’ validator PASS |
| #1 | ai-02-core | integration | 8b8d5b2 | MERGEABLE | CR-0008 resolved |
| #4 | ai-11-performance | integration | 1606127 | CLEAN | step 7 |
| #6 | ai-04-gameplay | integration | 9c47cf6 | CLEAN | step 6 |
| #7 | ai-10-qa | integration | 8e8787a | CLEAN | step 8 |
| #8 | ai-12-build | integration | 3940a11 | CLEAN | step 7 |
| #2 | ai-05-world | integration | 0223a55 | UNKNOWN | step 6 |
| #3 | ai-07-uiux | integration | 2e8142c | UNKNOWN | step 6 |

Branches with **no PR yet**: `ai-03-puzzle`, `ai-06-creatures`, `ai-08-audio`. VERIFIED.

## 3. Phase / gate status

- **Current phase:** 00 â€” Product/IP Lock. VERIFIED.
- **Phase 00 integration gate verdict:** **NOT PASSED**. VERIFIED (`11_INTEGRATION/PHASE00_INTEGRATION_GATE.md` Â§1).
- Gate needs: the 12 other accounts' Phase 00 artifacts merged onto `integration`, plus Human decisions OD-0001â€¦OD-0007.

## 4. Completed this session

- Reconstructed live branch/PR state (all 13 account branches + 10 open PRs). VERIFIED.
- Read mandatory governance docs (control, prompts, account matrix/track, integration pack). VERIFIED.
- **PR #9 gate check performed locally:** diff `integration...ai-13-integration` = 18 files, all under `11_INTEGRATION/**` + additive AI-13 section in `00_CONTROL/PROGRESS.md`; no out-of-scope paths; simulated `--no-ff` merge onto `integration` merged clean; `validate_registry.py --check-render` â†’ `PASS: 27 contracts, 27 DRAFT, 0 consumable; governance IDs consistent.`, exit 0. VERIFIED.
- **PR #10 (AI-01) content gate review performed locally:** diff `integration...ai-01-product` = 12 files, all under `01_PREPRODUCTION/PRODUCT/**` + additive AI-01 section in `00_CONTROL/PROGRESS.md`; no out-of-scope paths. `validate_product_lock.py` â†’ `SUMMARY pass=14 fail=0`, exit 0. Content coherent with Product Lock (L1 product truth, L2 scope+cut list); PD-025..029 recorded by Human Product Authority. VERIFIED.
- **Combined-tree gate check (PR #9 + PR #10 simulated on `integration`):** the two merge cleanly except `00_CONTROL/PROGRESS.md` (both append an `### AI-XX` section â†’ `UU`). Resolved by keeping both sections; both validators then PASS on the combined tree (registry PASS; product pass=14 fail=0). Filed **CR-0010** for this shared-append conflict. VERIFIED.
- **PR #5 (AI-09) content gate review performed locally:** `validate_narrative_registry.py` **FAILS on the PR head** (`187b1da`) â†’ exit 1, 2 failures (`nar.chapter.07_silent_engine` undefined, referenced from `CHAPTER_BEAT_MAP.md` and `STORY_BIBLE_V7.md`). AI-09's handoff claims "exit 0 / 0 failures" â€” not reproducible. Filed **CR-0011** (High, gate blocker). PR #5 also carries CR-0008 (wrong base). VERIFIED.
- **CR-0008 retarget safety verified:** `ai-09-narrative` and `ai-02-core` have no dependency on `ai-13-integration` (`diff --name-only origin/ai-13-integration...origin/ai-09-narrative` âˆ© `11_INTEGRATION` = 0), and both merge cleanly onto `integration`. Retargeting base `ai-13-integration` â†’ `integration` is safe. VERIFIED (not applied â€” write access blocked).
- **Bulk validator gate check (all account branches merged onto `integration` one at a time):**

  | Branch | merge | validator exit | result |
  |---|---|---|---|
  | ai-02-core | clean | 0 | PASS (10 groups, 0 findings) |
  | ai-03-puzzle | clean | 0 | 33 unittest cases OK; validator PASS (1 warning) |
  | ai-04-gameplay | clean | 0 | 32 passed, 0 failed |
  | ai-05-world | clean | 0 | 9 passed, 0 failed |
  | ai-06-creatures | clean | 0 | 187 passed, 0 failed |
  | ai-07-uiux | clean | 0 | 6 fixtures, 0 failures |
  | ai-08-audio | clean | 0 | registry OK; 17/17 test cases pass |
  | ai-10-qa | clean | 0 | fail=0 info=556 skip=5 |
  | ai-11-performance | clean | 0 | positives=1 negatives=4 failures=0 |
  | ai-12-build | clean | 0 | 10 passed, 0 failed, 10 fixtures |
  | **ai-09-narrative** | clean | **1** | **FAIL â€” 2 findings (CR-0011)** |

  Every account branch merges cleanly onto `integration` (only `00_CONTROL/PROGRESS.md` may conflict; see CR-0010). Exactly one PR is a validated gate blocker: **#5 (AI-09)**. VERIFIED.
- Created this checkpoint.
- **Write-enabled session (2026-10-10, part 2):** pushed `ai-13-integration`; retargeted PRs #1/#5 to `integration` (CR-0008 RESOLVED); fixed CR-0011 on `ai-09-narrative@ea12651` (validator exit 0, negative tests still fail) and pushed it; executed merge steps 1â€“8 (all 13 branches) into `integration`, resolving the `PROGRESS.md` conflict mechanically each time; pushed `integration@c4cc93e`. PRs #9 and #10 auto-registered MERGED (`c607272`, `6b5818f`). Re-ran **all** owner validators on the integrated tree â†’ 12/13 pass; **AI-10 `QA_PHASE00_VALIDATOR.py` exits 1 (fail=20)** â†’ filed **CR-0012** and posted it on PR #7. Posted a CR-0011 resolution note on PR #5. VERIFIED.

## 5. Open decisions / blockers

- **OD-0001** branch protection (Human admin) â€” BLOCKED (human).
- **OD-0002** engine/toolchain lock Unity 6 + URP (Human + AI-01) â€” BLOCKED (human); no Unity in this sandbox (VERIFIED).
- **OD-0003** `CC.WORLD.STATE_EVENT` owner (AI-01 + AI-02) â€” open.
- **OD-0004** asset-manifest owner â€” answered by PD-023 once PR #10 merges.
- **OD-0005** IP-safe direction / title clearance (Human legal) â€” BLOCKED (human).
- **OD-0006** currency layer â€” answered by PD-004 once PR #10 merges.
- **OD-0007** item families + rarity labels â€” answered by PD-002 once PR #10 merges.
- **CR-0008** PRs #1/#5 base branch â€” open (needs retarget to `integration`).
- **CR-0009** `CC.*` contract-only namespace â€” open (AI-01 to confirm at product level).

## 6. Current task and acceptance criteria

- **Task:** Phase 00 merge step 1 â€” gate-review and merge PR #9 into `integration`.
- **Acceptance:** ownership clean; validator PASS on merged tree; no conflicts; merge commit (no fast-forward). All three verified locally; awaiting merge authorization/decision.

## 7. Tests already run (actual results)

```bash
# on /workspace/wt/ai13 (ai-13-integration)
python3 11_INTEGRATION/scripts/validate_registry.py --check-render
# â†’ PASS: 27 contracts, 27 DRAFT, 0 consumable; governance IDs consistent. exit=0

# on /workspace/wt/integ (gate-check of origin/integration + origin/ai-13-integration)
git merge --no-ff --no-commit origin/ai-13-integration   # â†’ clean
python3 11_INTEGRATION/scripts/validate_registry.py --check-render   # â†’ same PASS, exit=0
```

## 8. Next safe action

**Done this session:** CR-0008 (retarget #1/#5) applied; CR-0011 fixed on `ai-09-narrative` (`ea12651`); CR-0010 resolved by the merge sequence; **CR-0012 filed for AI-10** (validator fails on the integrated tree). Merge sequence steps 1â€“8 executed and pushed as `integration@c4cc93e`.

**Next safe actions (in order):**

1. **Land the CR-0012 fix onto `integration`.** The fix is committed on `ai-10-qa@8bd03f0` and referenced by `ai-13-integration@f01be1b`, but is **not** in `origin/integration`. Verified read-only: merging `8bd03f0` onto `integration@55f6b9b` makes `QA_PHASE00_VALIDATOR.py` exit 0 (`fail=0 info=727`, F self-test 23 cases) while the product/registry/narrative validators also pass. This is the only remaining validator-gate action; it needs **remote write access** (currently BLOCKED — see §1 regression / §11).
2. On the human owner: decide **OD-0001** (branch protection), **OD-0002** (engine lock), **OD-0005** (IP/title clearance). Phase 00 cannot be declared PASSED while these and CR-0012 are open.
3. Optional process decision (Product/AI-01): confirm the `00_CONTROL/PROGRESS.md` merge convention before Phase 01 re-triggers CR-0010 on every merge.
4. Only after the gate passes: AI-13 Phase 01 preparation per `05_PROMPTS/phase_01/` and the phase-kickoff procedure.
5. **Never** promote `integration` â†’ `main` without explicit human release approval.

## 9. Rollback

- PR #9 not merged yet â†’ `integration` remains at `584141c`; nothing to roll back.
- If merged: `git revert -m 1 <merge-commit>` on `integration` (all files under `11_INTEGRATION/**` + one appended PROGRESS.md section).
- Never force-push, reset shared branches, or delete branches/tags.

## 10. Environment (updated Session 5)

- AI-13 sandbox: Python 3.13 + `gh` 2.102. **No Unity** (engine-migration rationale). **Godot 4.7.2-stable and a full Android toolchain ARE now provisioned** (JDK 21, Android SDK / build-tools 34.0.0, export templates, local debug keystore) — see §11/§12. VERIFIED.
- A signed **debug** APK has been built (see `game/docs/OPENHANDS_STATUS.md` for the digest); no **physical-device** run and no **release/store** build are claimed.
- No CI runs the Phase-00 *content* validator (RISK-0002); that gate step is manual. The Godot *build* workflow `.github/workflows/craftcube-android.yml` runs in CI.

## 11. Session 4 (2026-10-10) — Godot engine migration + playable Android slice (AI-13)

- **Directive:** Human Project Owner — official engine change to **Godot 4.x stable + GDScript**, Android-first, to remove the Unity dependency and produce a runnable build.
- **Branch:** `godot-migration`, created from `integration` @ `55f6b9b` (current `origin/integration`). VERIFIED.
- **Toolchain provisioned and VERIFIED in this sandbox:**
  - Godot `4.7.2.stable.official.ed1daf0bf` at `/opt/godot`, symlinked to `/usr/local/bin/godot`.
  - Export templates 4.7.2-stable installed to `~/.local/share/godot/export_templates/4.7.2.stable/`.
  - OpenJDK 21 (`openjdk-21-jdk-headless`) + Android SDK at `/opt/android-sdk` (`platform-tools`, `platforms;android-34`, `build-tools;34.0.0`); Godot editor settings point at both; debug keystore created.
- **Built (VERIFIED):** a real Godot project under `game/` — 11 GDScript classes, `project.godot`, `scenes/Main.tscn`, `export_presets.cfg`, `icon.svg`, a headless test runner, a CI script, and a GitHub Actions workflow.
  - Domain: deterministic NxN puzzle (`cube_state.gd` geometry-derived permutations, `move_table.gd`, `puzzle_engine.gd` seeded scramble + reverse-replay solvability proof, `level_catalog.gd`).
  - Game: `game_state.gd`, `save_manager.gd` (versioned JSON), `story_content.gd`, `game_controller.gd`, `hud.gd`.
  - Presentation: `cube_view.gd`, `world_view.gd` (procedural, no external assets).
  - Playable Chapter 01 slice: 3 levels (AI-03 IDs), progression, save, world reaction, a reward + equipment grant, one optional discovery, mobile HUD with a large-text toggle.
- **Tests / evidence (VERIFIED):** unit tests **52 passed / 0 failed**; headless main-scene boot clean; **signed Android debug APK** built — `com.downwitherfandesign.craftcube`, v0.1.0, minSdk 24, arm64-v8a. Logs in `game/docs/evidence/`.
- **Fixed during the session (real defects found by tests, not worked around):** rotation was about the corner not the cube centre; `apply_move` never resolved the `layer=-1` ("outer") sentinel; scramble generation recursed infinitely on a rejected seed. All three fixed and re-tested.
- **Design finding (routed to AI-03):** the draft fixture's `rule.axis_lock {axes:[X,Z]}` + `objective.align{U}` is degenerate (level starts solved). The binding uses no axis lock for levels 1–2 and a **Y-axis lock** for level 3. Documented in `game/docs/ENGINE_AND_BUILD.md` and `11_INTEGRATION/ENGINE_MIGRATION_UNITY_TO_GODOT.md`.
- **Governance:** added `11_INTEGRATION/ENGINE_MIGRATION_UNITY_TO_GODOT.md` (AI-13 record) and **CR-0013** (route engine change to AI-01; `PD-025` + `validate_product_lock.py` §8 remain Unity-scoped and are AI-01-owned). AI-13 did **not** rewrite the AI-01 product register/validator.
- **Gate status unchanged:** Phase 00 remains **NOT PASSED**. The CR-0012 fix (`8bd03f0`) is committed on `ai-10-qa` and referenced by `f01be1b` on `ai-13-integration`, but **neither is in `origin/integration`** (validator still fails `fail=20`, F self-test 14 cases). This is the open validator blocker.
- **BLOCKED (write):** `git push` needs the PAT that is absent this session (see §1 regression). The session's commits are local on `godot-migration` only.
- **Next safe action:** (1) restore write access and push `godot-migration` + open a PR to `integration`; (2) land the CR-0012 fix onto `integration` (fast-forward/re-merge `ai-10-qa@8bd03f0` or equivalent) so the QA validator exits 0; (3) AI-01 records `PD-030` (CR-0013) and restates `PD-029` items 4/5 engine-neutrally; (4) AI-03 confirms the Chapter 01 rule binding.

## 12. Session 5 (2026-10-10) — deep audit, hardening, verified Android build (AI-13)

- **Branch:** `godot-migration`, committed on top of Session 4. Commits: `765e959` (hardening), `1f1d099` (discovery content), `dad1ad8` (scene integration test). VERIFIED local; **not pushed** (write blocked, §13).
- **Read-only audit:** read all 11 GDScript classes, `Main.tscn`, `project.godot`, `export_presets.cfg`, and the test runner in full. The cube geometry/permutations, order-4 and inverse properties, determinism, seeded scramble, and reverse-replay solvability were re-verified by new property tests (the engine core is sound).
- **Real defects found via the audit and fixed (each with a regression test):**
  1. Duplicate completion — a repeated "I solved it" re-fired the world reaction (double marker), reward, and discovery. `confirm_solve()` is now idempotent per level.
  2. Non-atomic save → temp file + `flush()` + atomic `rename()`.
  3. Unparseable/wrong-typed save could mis-load → quarantined to `<path>.corrupt`; `GameState.from_dict` validates types, clamps negatives, truncates an over-cap loadout.
  4. `next_level()` did not persist position → now advances to the nearest unsolved level and saves.
  5. Hardcoded reward→equipment map → `StoryContent.equipment_id_for()`.
  6. **`build_android.sh` resolved a relative export path against `game/`**, so the export silently failed and a *stale* APK could read as fresh. Fixed to absolute paths + SHA-256 output.
  7. **`level.01.hollow_stone` referenced `discovery.01.stone_mark`, which was undefined and could never fire.** Added a `DISCOVERIES` registry authoritative by ID; the controller resolves any `discovery_id` generically.
- **Tests/evidence (VERIFIED):** domain suite **132 passed / 0 failed** (was 52), including a real `Main.tscn` scene-integration test; headless boot clean; **`game/ci/build_android.sh` → CI: PASS**; signed debug APK `dist/CraftCube.apk` (arm64-v8a, minSdk 24) — digest in `game/docs/OPENHANDS_STATUS.md`. Logs refreshed under `game/docs/evidence/`.
- **Governance/docs:** added `game/docs/OPENHANDS_STATUS.md`; refreshed `game/docs/ENGINE_AND_BUILD.md` evidence + APK digest; CI workflow now triggers on `ai-*`/`godot-*` branches.
- **Gate status unchanged:** Phase 00 remains **NOT PASSED** (CR-0012 not in `origin/integration`; CR-0013 + human ODs open).
- **Next safe action:** identical to §11 (unblock write, publish, land CR-0012, record PD-030).
- **Phase-00 validator sweep on the current tree (VERIFIED, read-only):** product-lock pass=14/fail=0; registry 27 contracts/27 DRAFT/0 consumable; AI-04 32/0; ownership OK; AI-08 audio OK (motifs=5 cues=29); environment 9/0; narrative 35 groups/0; UIUX 6 fixtures/0; performance positives=1 negatives=4 failures=0; release 10/0/10 fixtures; AI-03 content PASS (0 errors, 1 warning). The current tree `= local integration (with CR-0012) + Godot slice` satisfies all validators. NOTE: `origin/integration` is still `55f6b9b` (pre-CR-0012) — the gate blocker is the *push*, not the code.

## 13. Write-access blocker (Session 5, definitive)

`git push` and every write API are blocked. VERIFIED this session:

- The runtime `GITHUB_TOKEN` is a **read-only `ghu_` integration token**:
  `POST /repos/downwitherfan-design/CraftCube/git/refs` → HTTP `403`,
  body `{"message":"Resource not accessible by integration"}`.
- `git push` through a `credential.helper` that echoes `$GITHUB_TOKEN` →
  `remote: Permission ... denied` / `fatal: ... error: 403`.
- The repo `permissions` JSON field (`push:true, admin:true`) reflects the **account's
  role**, not the token's scope — it is not evidence of token write access.
- The write-capable PAT used in an earlier session (`/tmp/.ghtok`,
  `GIT_ASKPASS=/tmp/.gitaskpass`) **does not exist** this session.

**Unblock:** register a write-enabled credential (scope `repo`) as the supported
`GITHUB_TOKEN`/`GH_TOKEN` secret. No workaround that stores or exposes a secret was used.
