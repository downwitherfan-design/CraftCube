# OpenHands Resume State â€” CraftCube Recovery

AI-13-owned persistent checkpoint. Purpose: let this work resume correctly after a
context reset, session end, or handover. Factual only; every claim carries a label
(VERIFIED / INFERRED / ASSUMED / UNKNOWN / CONFLICT / BLOCKED). Update after each
meaningful milestone.

## 1. Last verified repository state

- **Inspection time:** 2026-10-10 (Epic 0.3 session 10; last milestone H, head `5af28e1`). Earlier recovery inspection also recorded below.
- **Epic 0.3 session 10 (VERIFIED):** working branch `godot-migration`; branch head `5af28e1` after Milestones E/F/G/H, all pushed
  (`bab56ee..5af28e1`). `integration` = `3df70ae7518a9d6055b46d7dd690bbb13c8eeb51` (does NOT yet contain `game/` — PR #11 unmerged).
  Remote write worked this session via the injected `GITHUB_TOKEN` (pushes succeeded); the earlier "remote write BLOCKED" note in
  this section was a prior-runtime condition and does not hold here. GitHub Actions `CraftCube Android build` green on the head.
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
- **Tests/evidence (VERIFIED):** domain suite **134 passed / 0 failed** (was 52), including a real `Main.tscn` scene-integration test; headless boot clean; **`game/ci/build_android.sh` → CI: PASS**; signed debug APK `dist/CraftCube.apk` (arm64-v8a, minSdk 24) — digest in `game/docs/OPENHANDS_STATUS.md`. Logs refreshed under `game/docs/evidence/`.
- **Governance/docs:** added `game/docs/OPENHANDS_STATUS.md`; refreshed `game/docs/ENGINE_AND_BUILD.md` evidence + APK digest; CI workflow now triggers on `ai-*`/`godot-*` branches.
- **Gate status unchanged:** Phase 00 remains **NOT PASSED** (CR-0012 not in `origin/integration`; CR-0013 + human ODs open).
- **Next safe action:** identical to §11 (unblock write, publish, land CR-0012, record PD-030).
- **Phase-00 validator sweep on the current tree (VERIFIED, read-only):** product-lock pass=14/fail=0; registry 27 contracts/27 DRAFT/0 consumable; AI-04 32/0; ownership OK; AI-08 audio OK (motifs=5 cues=29); environment 9/0; narrative 35 groups/0; UIUX 6 fixtures/0; performance positives=1 negatives=4 failures=0; release 10/0/10 fixtures; AI-03 content PASS (0 errors, 1 warning). The current tree `= local integration (with CR-0012) + Godot slice` satisfies all validators. NOTE: `origin/integration` is still `55f6b9b` (pre-CR-0012) — the gate blocker is the *push*, not the code.

## 13. Write-access blocker — RESOLVED (Session 6)

> **RESOLVED 2026-10-10 (Session 6).** A write-enabled token was supplied and verified
> (repository owner `downwitherfan-design`; reversible ref probe create→201 / delete→204).
> All pushes below are now on `origin`. The historical description is retained for context.

Historical finding (now moot): the runtime `GITHUB_TOKEN` was a **read-only `ghu_`
integration token** — `POST /repos/.../git/refs` returned HTTP `403`
`{"message":"Resource not accessible by integration"}`, and `git push` failed the same way.

## 14. Session 6 (2026-10-10) — delivery: pushes, PR, green CI (AI-13)

- **Write access restored (VERIFIED):** identity `downwitherfan-design`; the supplied token
  can create/delete refs. Credential kept transiently in `/tmp/.ghtok` (mode 600), never
  committed and never printed.
- **Pushed branches (VERIFIED on `origin`):**
  - `integration` `55f6b9b → 3df70ae` (fast-forward; brings the AI-10 CR-0012 fix to the canonical remote).
  - `godot-migration` `1d63bbf → ab8416b` (the Godot slice + all hardening).
  - `ai-13-integration` `397cfb6 → f01be1b`.
- **PR opened:** [#11](https://github.com/downwitherfan-design/CraftCube/pull/11) `godot-migration → integration` (integration request; base is the canonical `integration`, not `main`).
- **CI now GREEN (VERIFIED):** run `38075134745` on `godot-migration` **success**; the clean
  runner installed Godot 4.7.2 + Android SDK, built + signed the APK, and uploaded artifact
  `CraftCube-debug-apk` (28,122,828 bytes). This closes the "no remote build evidence" gap.
- **CI defect found + fixed (this session):** the `Create debug keystore` step failed when the
  alias already existed (`keytool: alias <androiddebugkey> already exists`), failing the job
  before the build. Guarded with an existence check; added a toolchain-path diagnostic step.
  Fix commit pushed on `godot-migration`.
- **Remote state correction:** only PR #11 is currently open. The earlier PRs (#1/#5/#9/#10)
  are closed/merged on the live repo — so the historical "PR #1/#5 target `ai-13-integration`"
  note is no longer actionable. Recorded per live evidence.
- **Still open (unchanged):** Phase 00 gate NOT PASSED — CR-0013 (AI-01 product-register
  update) and the human-controlled decisions remain outstanding. PR #11 does not claim the gate.
- **PR #11 status:** `mergeable`, `mergeable_state: clean`; both `build-and-test` checks on the
  head commit (`e6e0ff9`) are `success`. Marked **READY_FOR_REVIEW**.
- **Merge decision (AI-13):** deliberately **not merged**. The Phase-00 gate is NOT PASSED and
  the engine change is a product-authority matter pending CR-0013 (AI-01) and the AI-03
  Chapter-01 binding confirmation. Merging now would bypass the documented order
  (governance -> product/IP lock -> narrative/core -> remaining tracks). No `main` push and no
  release was performed.

## 15. Session 7 (2026-10-10) — engine-migration completion, Chapter 01 quality, Phase 00 closure work (AI-13)

- **Engine:** locked to **Godot 4.x + GDScript, Android-first**. This session provisioned **Godot
  4.7.2-stable locally** and ran the *real* engine, so the game evidence below is from Godot itself,
  not a model. VERIFIED.
- **Live remote heads at session start (VERIFIED):** `main` 584141ce; `integration` 3df70ae7;
  `ai-01-product` 8846a7b8; `ai-13-integration` f01be1b6; `godot-migration` a3243323.
  Only **PR #11** (`godot-migration -> integration`) and **PR #12** (`ai-01-product-godot -> integration`)
  are open; PRs #1–#10 are closed/merged on the live repo.

### Workstream A — AI-01 product / CR-0013 (DONE)
- Branch `ai-01-product-godot`; **PD-030** (HUMAN_DECIDED, v1.3.0) records **Godot 4.x stable + GDScript,
  Android-first**, superseding PD-025; PD-029 items 4/5 restated engine-neutrally; PRODUCT_LOCK engine row
  updated; `validate_product_lock.py` §8 checks the Godot decision. PR **#12**.
- **Integration finding (fixed):** PD-030 was labelled `v1.3.0` while the register header stayed 1.2.0
  (CUT 1.1.0). AI-10's `QA_PHASE00_VALIDATOR.py` check **E3** (source-baseline drift) rejects exactly this
  -> 2 E3 FAILs. Fixed: register -> 1.3.0, CUT -> 1.2.0. QA E3 FAILs **2 -> 0**.
- **Artifact-leak fix:** a commit accidentally staged `dist/CraftCube.apk` (~28 MB) + `game/.godot/*`
  (the root `.gitignore` is owned on the Godot branch and was absent on the product branch). Removed from
  the index; those paths are gitignored once the branches integrate.

### Workstream C — Chapter 01 rule semantics (DONE)
- Characterized the AI-03 draft `rule.axis_lock {axes:[X,Z]}` on `level.01.awaken` against the **real engine**:
  legal=`[U,D]`, **solved on scramble**, min_solve=**0** -> degenerate. The implemented binding already drops
  that lock; the chapter's single "introduce one constraint" moment stays on `level.01.hollow_stone`
  (Y-lock -> U/D illegal; verified min_solve 6 vs 4 without the lock).
- Recorded the resolved conflict in `game/scripts/domain/level_catalog.gd`; added
  `_test_level_rule_semantics()` regression proof. No further engine change was needed.

### Workstream D — gameplay/mobile audit (DONE)
- **Real defect:** the HUD face controls were a **six-wide row** (min 96px => ~624px) -> overflow on a
  360px portrait phone. Rebuilt as a **3-column grid** inside a **ScrollContainer**.
- **Real defect:** the scene-integration test called `remove_child(main)` on an unparented node -> engine
  `ERROR` on every run. Guarded on `get_parent() != null`.
- Added `_test_hud_layout_and_wiring()` (grid fits ~360px; Y-lock level disables U/D) and
  `_test_save_corruption_variants()` (empty / truncated / zero-version / wrong-typed / negative-index).

### Workstream B — doc reconciliation (DONE)
- `11_INTEGRATION/ENGINE_MIGRATION_UNITY_TO_GODOT.md`, `game/docs/ENGINE_AND_BUILD.md`,
  `game/docs/OPENHANDS_STATUS.md` updated to the resolved PD-030 state and the new test count.

### Verified results on the intended combined tree (`godot-migration` + `ai-01-product-godot`)
- Godot domain suite: **166 passed / 0 failed** (was 134). VERIFIED.
- QA content validator: **fail=0** (was 2). VERIFIED.
- Validator sweep: **13 / 13 PASS**. VERIFIED.
- `game/ci/build_android.sh` and remote CI re-verification are the remaining step (Workstream F).
- **Branch/commit:** `godot-migration` @ `862698b` (pushed, PR #11); `ai-01-product-godot` @ `e2bc430`
  (pushed, PR #12).

### Gate status (UNCHANGED)
- **Phase 00 integration gate: NOT PASSED.** Human-controlled decisions still open (OD-0001 branch
  protection, OD-0005 IP/title clearance; OD-0002 engine now answered by PD-030) and the AI-03 Chapter-01
  binding confirmation is requested in `AI03-DRAFT-RULE-001`. No PR was self-merged.

### Next safe action
1. Re-run the Android export (`bash game/ci/build_android.sh`) on `godot-migration@862698b` and refresh
   `game/docs/evidence/` (Workstream F).
2. Land PD-030 (PR #12) and the Godot slice (PR #11) into `integration` **only** when the gate conditions
   and human decisions permit.
3. AI-03 confirms/rescinds the Chapter-01 binding (`AI03-DRAFT-RULE-001`); human owner decides OD-0001/OD-0005.


## Session 8 — Gameplay-quality sprint (AI-13, godot-migration)
### Environment
- Re-provisioned Godot 4.7.2-stable locally (same release as CI); the fresh runtime had no engine.
- GITHUB_TOKEN in this runtime is a read-only App installation token (git push and API writes both
  return 403 "Resource not accessible by integration"). The commits below are LOCAL and unpushed;
  no remote write, no merge, no `main` push was possible.

### Real defects found by RUNNING the game (not by reading it)
1. Completion feedback clobbered — world reaction, reward narrative and discovery all wrote to one
   shared label; the last signal won. Level 2 lost the reaction text; level 3's Nox reward narrative
   was never shown at all. Fix: dedicated accumulating `_story` panel; clears per level; no duplicate
   on re-confirm. Commit `69de79d`.
2. Cube camera mis-framed — projecting the cube through the scene camera showed x -15..548 on the
   720px canvas: off-centre and clipped at the left on every viewport. Recomputed the Transform3D
   (now x 126..583, 63% width, centred); also corrected the row/column order of the stored Basis.
   Commit `298ec98`.
3. Resume replayed the solved level — relaunch always reopened the level just completed. Now resumes
   at the first unsolved level; keeps the saved position when the chapter is complete. Commit `4f4190f`.
4. UX: aligned-cue now also refreshes after Undo/Restart; guarded mobile haptics + fullscreen. Commit `8793822`.

### Verified results (this branch, this runtime)
- Godot domain suite: 198 passed / 0 failed (was 166). Command: godot --headless --path game --script res://tests/run_tests.gd
- Main scene boots clean headless (--quit-after 180, exit 0, no engine errors).
- HUD layout measured at the real 720x1280 canvas: 12 buttons, 0 offscreen, normal + large-text.
- Validators on THIS branch: registry 27/27 PASS, product_lock 14/0 PASS. QA validator still fail=20 —
  all pre-existing and in files this branch does not contain/touch (AI-04/AI-06/audio fixtures + E3
  product-doc version drift). E3 is fixed by PR #12. None of the 20 are in the game code changed here.

### Branch / commits
- godot-migration @ 8793822 (4 commits ahead of origin/godot-migration). PR #11 target `integration`.
- New regressions: _test_completion_feedback, _test_camera_framing, _test_resume_selection,
  _test_chapter_playthrough (all in game/tests/run_tests.gd).

### Next safe action
- Push godot-migration (69de79d..8793822) once a write-capable credential is available, so CI can rebuild
  and re-sign the APK on the fixed commit and refresh game/docs/evidence/.
- Then run PR #11 through the Phase 00 gate; do NOT merge until the gate and human decisions permit.

### Android build reproduced locally (Workstream F closed)
- Provisioned JDK 21, Android SDK (platform-tools + platforms;android-35 + build-tools;35.0.0) and the
  Godot 4.7.2-stable export templates; set export/android paths in editor_settings-4.7.tres; created the
  standard debug keystore.
- `bash game/ci/build_android.sh` -> **CI: PASS** on commit 8793822: import 0, **198 tests, 0 failed**,
  main-scene boot 0, debug APK exported and **signed** (`apksigner`, build-tools 35.0.0).
- APK: 28,338,657 bytes; package `com.downwitherfandesign.craftcube` v0.1.0; arm64-v8a; targetSdk 36.
  Full log: `game/docs/evidence/android_export_run_8793822.log`.
- Limitation: no physical Android device / emulator in this session (adb daemon unavailable) -> NOT a
  device playtest; the pipeline itself is VERIFIED. APK hashes differ between runs (non-reproducible zip);
  the log's hash is the authoritative artifact for that run.



---

## Session 9 — Chapter 01 gameplay-quality sprint (2026-10-10)

- **Branch:** `godot-migration` (PR #11 → `integration`). Remote sync VERIFIED.
- **HEAD:** `2067351` (pushed). Range this session: `958566a..2067351`.
- **Working tree:** clean at session end.

### Verified results (this branch, this runtime)
- Godot domain suite: **239 passed / 0 failed** (`godot --headless --path game --script res://tests/run_tests.gd`). Was 198 at session start.
- `bash game/ci/build_android.sh` → **CI: PASS** on `2067351`. import 0, tests 239/0, main-scene boot 0, signed debug APK.
  Log: `game/docs/evidence/android_export_run_2067351.log`. APK: 28,346,849 bytes, package
  `com.downwitherfandesign.craftcube` v0.1.0, targetSdk 36; sha256 `53c5c785…` (zip non-deterministic → per-run hash).
  Earlier this session: `game/docs/evidence/android_export_run_44d099d.log` (CI: PASS, 234/0).
- **Rendered playability evidence:** real 720x1280 frames from the running scene under Xvfb/GL
  (`game/docs/evidence/screenshots/session9_initial.png`, `…_after_moves.png`); the cube visibly
  changes colour after animated turns while the HUD stays laid out. See that folder's README.
- Main scene boots clean headless (exit 0, no engine errors).

### Real defects fixed (found by running the slice)
1. Domain labelled the **bottom** face `U` → the "U" control twisted an invisible face, contradicting authored
   hints ("Align the top"). U now renders on top, D below; each face carries one letter. Commit `f3aa28b`.
2. `CubeView` was static-only; rebuilt as a **position-based animated view** (turn tweens about the cube centre,
   input locked in flight, re-synced to truth on settle) so overlapping inputs cannot desync render from logic.
   Commit `f3aa28b`.
3. World started **empty after resume** even with saved progress → `WorldView.sync_lit()` lights the growth ring
   from authoritative progression; `react()` is capped (no over-lighting). Commit `1307db2`.
4. No partial objective feedback → `PuzzleEngine.objective_progress()` + HUD "Aligned N/M required faces". `1307db2`.
5. `confirm_solve`/`next_level` could fire mid-turn and free the animating pivot → both now refuse while a turn
   is in flight. Commit `44d099d`.
6. Status line did not name the objective or show par → now "Align top, front · 1/2 aligned · Moves: 4 (par 7)".
   Commit `3212201`.

### New regressions (game/tests/run_tests.gd)
`_test_face_orientation`, `_test_layer_selection`, `_test_animation_locks_and_syncs`, `_test_world_state_and_resume`,
`_test_objective_progress`, `_test_animated_chapter_end_to_end` (plays all 3 Chapter 01 levels through the real scene
with ANIMATED turns; asserts render==truth after every turn + progression/rewards/discoveries), `_test_hud_status_text`.

### Next safe action
- Run PR #11 through the Phase 00 gate; do NOT merge until the gate and human decisions permit.
- Phase 00 gate remains **NOT PASSED**. Human decisions still open: OD-0001 (branch protection), OD-0005 (IP/title clearance).

### Integration-review conclusion for PR #11 (AI-13, this session)
- Live state (VERIFIED via API): `integration` = `3df70ae` (Phase 00 docs tree; no `game/`), `main` = `584141c`,
  PR #11 OPEN, base `integration`, head `godot-migration`, mergeable_state `unstable` (CI was re-running).
- PR #11 carries the Godot game slice only; `integration` has no game subtree → the merge adds new files and cannot
  be a stale-baseline overwrite. Rebased cleanly on the docs tree (merge-base `55f6b9b`).
- **Ordering dependency (BLOCKED until resolved):** the product decision that authorises the Godot engine (**PD-030**)
  lives in **PR #12** (`ai-01-product-godot`, OPEN, AI-01-owned). If #11 merged first, `integration` would carry the
  Godot game without the product register entry that authorises the engine. #12 must merge before #11. Recorded in
  `11_INTEGRATION/ENGINE_MIGRATION_UNITY_TO_GODOT.md` and restated in the PR body.
- Gate rows L1…L13 are NOT satisfied by an integrated tree yet (`integration` holds no product lock, story bibles,
  QA evidence as merged artifacts). AI-13's own L13 contribution (registry/gate/merge-sequence) is validated:
  `python3 11_INTEGRATION/scripts/validate_registry.py` → PASS on this branch.
- Verdict: PR #11 is READY_FOR_REVIEW but **must not merge** before PR #12 and before the gate/human decisions.

### Known limitations
- No physical Android device / emulator in this runtime (adb daemon unavailable) → the pipeline is VERIFIED, but this is
  **not** a device playtest.
- QA validator (`08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py`) still reports pre-existing failures in files this branch
  does not touch; E3 product-doc version drift is addressed by PR #12 (not this branch).

## Session 10 — Epic 0.3: extended gameplay development (2026-10-10)

- **Branch:** `godot-migration` (PR #11 → `integration`). Remote sync VERIFIED (`git push` succeeded this runtime).
- **Commits this session:** `314d836` (Milestone A), `efda6de` (Milestone B), `a899179` (Milestone C, CI green
  run `38086874943`), and the Milestone D commit (this section). Start of session: `5bf80b7`.
- **Working tree:** clean at each commit; evidence committed alongside code.

### Milestones (all real features, verified, committed)
- **A — deterministic guided-solving.** `game/scripts/domain/puzzle_solver.gd` (`PuzzleSolver.route_to_solved()`):
  free-group reduction of the engine's scramble+history, then reverse-replay, so a hint never merely undoes the
  previous move (no hint loop) and always routes to solved. Controller guide API (`guide_status`/`guide_next_move`/
  `guided_move`, cached route, invalidation on move/undo/restart/level); HUD Hint + "Guide: next step" controls.
  Rewritten once after a test caught an oscillation defect.
- **B — interactive orbit/zoom camera.** `game/scripts/presentation/orbit_camera.gd` (`class_name OrbitCamera`):
  drag to orbit, wheel/pinch to zoom, clamped distance (4.2–12.0) and pitch (0.12–1.35), smoothed, `reset_view()`.
  Reads only `_unhandled_input`, so a HUD tap never rotates the view; HUD labels set `MOUSE_FILTER_IGNORE` so
  empty-space drags reach the camera while buttons still consume events. Wired into `Main.tscn` + `GameController`.
- **C — world remembers progression.** `WorldView` now reveals one distinct ward stone per Chapter 01 level, warms
  its ground, and shows Nox the companion only on chapter completion. One authoritative revealed count drives the
  tally ring, wards and companion, so `sync_lit()` on resume restores exactly the matching prefix.
- **D — per-face readiness readout.** `PuzzleEngine.face_readiness()` returns `{face, distinct, solid}` for all six
  faces (U,D,L,R,F,B); HUD shows "Faces: top* solid · …" marking objective faces, so partial mastery across the
  whole cube is visible, not only the win condition.
- **E — equipment delivers its declared capability.** `GameState.has_capability(slot)` and
  `StoryContent.effect_slot()/equipment_by_id()` close the protected loop `Reward → Equipment/Capability`.
  The granted Rootweave Gauntlet's `perceive.resonance` effect surfaces a HUD line naming faces one turn from
  settling (distinct==2). Capability is keyed off the effect slot, not the equipment id; appears only while
  equipped (PD-002: perception, never puzzle truth).
- **F — accessibility persistence.** The large-text choice is written to a separate settings file
  (`SaveManager.save_settings/load_settings`, `user://craftcube_settings.json`) and restored by a
  fresh HUD, so it survives a restart. Progression and settings are independent: a corrupt or
  version-mismatched save cannot reset accessibility, and a malformed settings file falls back to
  normal text without failing.
- **G — progress flush on exit.** `GameController.save_progress()` (idempotent, test-isolatable via `save_path`)
  is called from `_notification()` on `NOTIFICATION_WM_CLOSE_REQUEST` / `NOTIFICATION_WM_GO_BACK_REQUEST`, so a
  session ended by the Android back gesture or a window close persists progress and quits cleanly.
- **H — reduced motion.** A persisted accessibility toggle (`_reduced_motion`) reaches `CubeView.reduced_motion`;
  a turn still runs the same animated lifecycle (logic advances exactly once when the turn settles) but the
  sweep is instant. Restored from settings alongside large text.

### Verified results
- Godot domain suite: **375 passed / 0 failed** (was 239 at Session 9 end; 277 after A, 296 after B, 310 after C,
  341 after D, 350 after E, 359 after F, 364 after G).
- `bash game/ci/build_android.sh` → **CI: PASS** on this tree. import 0, tests 375/0, main-scene boot 0, signed
  debug APK (28,359,497 bytes, sha256 `018458ba…`). Log: `game/docs/evidence/session10_build.log`.
- Rendered evidence (Xvfb/GL, 720x1280) via new `game/tests/capture_frames.gd`:
  `session10_initial/orbit/hint/world_complete.png`. The capture script now preserves/restores the player save it
  used to overwrite (found because a leftover save broke save-sensitive tests in a later run).

### New regressions (game/tests/run_tests.gd)
`_test_guided_solver_domain`, `_test_guided_solver_controller`, `_test_orbit_camera`, `_test_world_progression_landmarks`,
`_test_face_readiness`, `_test_hud_readiness_line`, `_test_equipment_capability`, `_test_hud_resonance_line`,
`_test_settings_persistence`, `_test_hud_big_text_persistence`, `_test_progress_flush_on_exit`,
`_test_reduced_motion_persistence`.

### Next safe action
- Continue Epic 0.3 with the remaining milestone tasks; keep PR #11 green.
- Phase 00 gate remains **NOT PASSED**; PR #12 (AI-01 `PD-030`) must merge before PR #11. Human decisions still open:
  OD-0001 (branch protection), OD-0005 (IP/title clearance).

### Known limitations (Session 10)
- No physical Android device / emulator in this runtime → the pipeline is VERIFIED; this is **not** a device playtest.
- Rendering under Mesa llvmpipe is a software GL path; it validates layout/geometry, not device GPU performance.

