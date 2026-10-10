# Change Requests — AI-13 Integration Governance

Actionable requests returned to owning accounts. AI-13 does not implement these;
it records the failing artifact, evidence, expected behavior, acceptance test and
rollback note, per `05_PROMPTS/INTEGRATION_GATE_PROMPT_AI13.md`.

**ID rule:** `CR-nnnn`, sequential, never reused. **States:** OPEN → ACKNOWLEDGED → RESOLVED / REJECTED / SUPERSEDED.
**Ownership of target file** is stated per request; when the target owner is not an AI account (shared governance doc), the request is routed to Product (AI-01) + Human for approval and AI-13 applies the change only after that approval is recorded.

| ID | Target owner | Phase due | Severity | State |
|---|---|---|---|---|
| CR-0001 | Product (AI-01) + Human — `07_GITHUB/GITHUB_MODEL.md` | 01 | Low (doc) | OPEN |
| CR-0002 | AI-12 (`07_GITHUB/scripts/`, `.github/`) + Product for CODEOWNERS | 01 (before any CI ownership enforcement) | Medium | OPEN |
| CR-0003 | AI-02 / AI-03 / AI-09 (ID-vocabulary owners) | 01 | Low | OPEN |
| CR-0004 | Product (AI-01) — `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md` | 01 | Low (doc) | OPEN |
| CR-0005 | AI-03 | 01 | Medium | OPEN |
| CR-0006 | AI-02, AI-03, AI-09 | 01 | Medium | OPEN |
| CR-0007 | AI-02, AI-03, AI-08, AI-12 | 01 | Medium | OPEN (partially answered — see `PHASE00_GATE_REVIEW_INCOMING.md` F2) |
| CR-0008 | AI-02 (PR #1), AI-09 (PR #5) | 00 (before merge) | Low (process) | **RESOLVED** (2026-10-10) |
| CR-0009 | AI-01, AI-06, AI-09, AI-10, AI-11 (+ any account using `CC.*` for non-contracts) | 01 | Medium | OPEN |
| CR-0010 | AI-13 (gate procedure) + all accounts (shared-file convention) | 00 (before merging the second account PR) | Low (process) | **RESOLVED** (2026-10-10) |
| CR-0011 | AI-09 (PR #5) | 00 (before merge) | High (gate blocker) | **RESOLVED** (2026-10-10) |
| CR-0012 | AI-10 (QA) | 00 (before Phase 00 gate can pass) | High (gate blocker) | OPEN |

---

### CR-0001 — Branch naming in `07_GITHUB/GITHUB_MODEL.md` does not match the repository
- **Failing artifact:** `07_GITHUB/GITHUB_MODEL.md` lists `ai-01/product … ai-13/integration`.
- **Evidence:** `git branch -r` shows `ai-01-product … ai-13-integration` (see `evidence/phase00_preflight_repo_facts.txt`, section "git branch -r" and "GITHUB_MODEL.md branch names vs actual").
- **Expected behavior:** Documentation matches actual branch names so no account creates a second set of branches. Actual names are canonical per `00_CONTROL/CONTEXT_PRIORITY_RULES.md` rule 1.
- **Acceptance test:** `grep -oE 'ai-[0-9]+[/-][a-z-]+' 07_GITHUB/GITHUB_MODEL.md | sort -u` equals the set of `origin/ai-*` branch names.
- **Rollback:** Revert the doc commit; branches are unaffected.
- **Note:** AI-13 has already published the authoritative mapping in `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md` so downstream work is not blocked.

### CR-0002 — `CODEOWNERS_EXAMPLE.txt` and `validate_ownership.py` use a stale account numbering
- **Failing artifact:** `07_GITHUB/CODEOWNERS_EXAMPLE.txt`, `07_GITHUB/scripts/validate_ownership.py`.
- **Evidence:** Both map `Assets/Art → AI-04`, `src/UI → AI-05`, `tests/ → AI-07`, `.github/ → AI-08`, `Release/ → AI-08`. `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` defines AI-04 = Gameplay, AI-05 = Environment, AI-07 = UI/UX, AI-08 = Audio, AI-10 = QA, AI-12 = Build/Release. Captured in `evidence/phase00_preflight_repo_facts.txt` section "CODEOWNERS_EXAMPLE owner mapping".
- **Expected behavior:** Ownership tooling reflects the 13-account matrix before it is wired into CI. Path prefixes must also be re-derived from the real project layout once Phase 02 creates it (no `src/`, `Assets/` exist today).
- **Acceptance test:** `python3 07_GITHUB/scripts/validate_ownership.py` prints an owner map whose account per path equals the matrix; a unit check asserting `owner_for('.github/x') == 'AI-12'` and `owner_for('tests/x') == 'AI-10'` passes.
- **Rollback:** Revert; the files are non-enforcing today so no runtime impact.
- **Risk link:** RISK-0003.

### CR-0003 — Example stable IDs use a pre-v7 biome/chapter vocabulary
- **Failing artifact:** `01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` (`biome.overworld.meadow`, `chapter.01.meadow`), `06_CONTRACTS/CONTRACT_FIRST_RULES.md` (`game.bloom.*`).
- **Evidence:** v7 canon biomes are Hearthwild, Glassroot, Sunken Grid, Ember Hollow, Verdant Archive, The Quiet Engine (`01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`). No `meadow`/`overworld` biome exists in canon.
- **Expected behavior:** When AI-02/AI-03/AI-09 freeze real content IDs in Phase 01 they must not adopt the example vocabulary by accident. Examples may stay as examples if labelled "illustrative, not canon".
- **Acceptance test:** Phase 01 ID registry contains no `overworld`/`meadow` IDs unless a design decision introduces such a biome.
- **Rollback:** N/A (preventive).

### CR-0004 — `PHASE_KICKOFF_PROCEDURE.md` says "eight independent branches"
- **Failing artifact:** `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md` step 2 ("هشت branch مستقل").
- **Evidence:** `evidence/phase00_preflight_repo_facts.txt` section "PHASE_KICKOFF_PROCEDURE stale count"; the model is 13 accounts (`00_CONTROL/manifest.json` `accounts: 13`).
- **Expected behavior:** "13" (or "one branch per account").
- **Acceptance test:** `grep -c "هشت" 05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md` returns 0.
- **Rollback:** Revert doc commit.

### CR-0005 — Declare whether `CC.DISCOVERY.EVENT` and `DiscoveryDefinition` are one contract
- **Target owner:** AI-03 (owner of DiscoveryDefinition per `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`).
- **Failing artifact:** `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md` lists `CC.DISCOVERY.EVENT`; the register lists `DiscoveryDefinition`. Registry entry `CC.DISCOVERY.DEFINITION` deliberately does **not** alias them.
- **Expected behavior:** AI-03 states in its Phase 01 handoff either (a) one contract → AI-13 adds the alias, or (b) two contracts (definition = authored data, event = runtime occurrence) → AI-03 requests registration of the second with owner, consumers and fixture.
- **Acceptance test:** `validate_registry.py` passes after the registry update; no two entries share semantics.
- **Rollback:** Registry entry reverted to this Phase 00 state.

### CR-0006 — Resolve overlap between newly-registered `CC.*` contracts and register families
- **Target owners:** AI-02 (`CC.BIOME.STATE` vs `CC.WORLD.STATE`; `CC.ITEM.ACQUISITION` vs `CC.REWARD.DEFINITION`; `CC.ITEM.IDENTITY` vs `CC.ITEM.DEFINITION`; `CC.PUZZLE.AFFINITY` consumers), AI-03 (`ChapterSpec` vs `CC.NARRATIVE.CHAPTER`; reward/acquisition boundary), AI-09 (`CC.NARRATIVE.MEMORY_FLAG` vs `CC.NARRATIVE.CHARACTER_MEMORY`; chapter ownership).
- **Failing artifact:** `11_INTEGRATION/registry/contract_registry.json` entries marked `owner_evidence: INFERRED` or with an overlap `note`.
- **Evidence:** `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md` lists five `CC.*` IDs absent from both register tables; `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` names `ChapterSpec`; `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §5.1 defines an item identity card separately from `ItemDefinition`.
- **Expected behavior:** Each owner declares, per pair, one of: SAME (alias), SUB-SCHEMA (child of), SEPARATE (distinct purpose, distinct fixture). Rule: `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md` anti-duplication — two implementations may not exist for the same semantic responsibility.
- **Acceptance test:** Every registry entry has `owner_evidence: VERIFIED`, non-empty consumers, and the note field no longer says "must be declared".
- **Rollback:** Registry entries reverted to Phase 00 DRAFT state.

### CR-0007 — Register contract families that exist only in policy prose
- **Target owners:** AI-02 (Simulation API / `IPuzzleEngine`, runtime DTOs), AI-03 (content schemas: BiomeSpec, CreatureSpec, ChapterSpec, EffectSpec, CompanionSpec, balance tables), AI-08 (audio cue IDs), AI-12 (build/environment contracts).
- **Failing artifact:** `06_CONTRACTS/CONTRACT_FIRST_RULES.md` "Contract families" list and `00_CONTROL/PROGRESS.md` baseline names have no registry entry (see `registry/contract_registry.json` → `unregistered_families`).
- **Expected behavior:** Each owner submits, in its Phase 01 handoff, a registry row (ID in `CC.<DOMAIN>.<NAME>` form, owner, consumers, fixture path, compatibility promise) and AI-13 adds it. Asset-manifest ownership is a separate open decision (OD-0004).
- **Acceptance test:** `unregistered_families` is empty or every remaining entry carries an approved deferral phase.
- **Rollback:** Remove added rows; no downstream consumer may depend on a DRAFT row.

### CR-0008 — PRs #1 and #5 target `ai-13-integration` instead of `integration`
- **Target owners:** AI-02 (PR #1 `ai-02-core`), AI-09 (PR #5 `ai-09-narrative`).
- **Failing artifact:** GitHub PR base branch (VERIFIED via REST API; `evidence/phase00_incoming_pr_scan.txt` "Open PRs").
- **Evidence:** `07_GITHUB/GITHUB_MODEL.md` and `05_PROMPTS/PROMPT_USAGE_GUIDE.md` §6: "PRs go to `integration`, never directly to `main`"; `ai-13-integration` is AI-13's working branch, not an integration target. At the time these PRs were opened, `integration` may not have existed yet (created by AI-13 during Phase 00) — this is understood and not a fault.
- **Expected behavior:** PR base = `integration`. Content of the PRs is unaffected.
- **Acceptance test:** GitHub API `pulls/1` and `pulls/5` return `base.ref == "integration"`.
- **Rollback:** N/A (metadata change).
- **Resolution (2026-10-10):** applied via `gh pr edit --base integration`. Verified: `PR#1 base=integration mergeable=MERGEABLE state=CLEAN`; `PR#5 base=integration mergeable=MERGEABLE state=CLEAN`. Retarget safety was checked first (`git diff --name-only origin/ai-13-integration...origin/<branch> | grep 11_INTEGRATION` = 0 for both), so no dependency is hidden.

### CR-0009 — `CC.*` namespace used for document IDs and ID-family labels
- **Target owners:** AI-01 (`CC.PRODUCT.LOCK`, `.DECISIONS`, `.CUTLIST`, `.IGM`, `.COMPETITORS`, `.PROGRESSION_POLICY`), AI-06 (`CC.CHARVFX.LOCK`, `.REACTION_MODEL`, reuse of `CC.PRODUCT.LOCK`), AI-10 (`CC.QA.*` as labels for `QAT-/QAR-/QAF-` families; reuse of `CC.PRODUCT.*`), AI-11 (`CC.PERF.LOCK`, `.DEVICE_MATRIX`, `.METHOD`), AI-09 (`cc.narrative.canon_registry` lowercase schema id).
- **Failing artifact:** see `evidence/phase00_incoming_pr_scan.txt` "CC.* IDs used per branch not present in registry".
- **Evidence:** `11_INTEGRATION/registry/contract_registry.json` `id_format` reserves `CC.<DOMAIN>.<NAME>` for contracts, following the pre-existing convention in `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md`. The same stem `CC.PRODUCT.LOCK` is now referenced from three branches with no single owner-registered definition.
- **Expected behavior:** `CC.*` identifies **contracts only** (schemas/DTOs/events consumed across tracks). Documents use a non-`CC` prefix (proposal: `DOC.<ACCOUNT>.<NAME>`, e.g. `DOC.AI11.PERF_LOCK`); ID **families** (`QAT-###`, `PERF-###`, `PD-###` …) are registered by prefix in an ID-family table AI-13 opens in Phase 01 — not as `CC.*`. Genuine contract proposals (`CC.AUDIO.CUE`, `CC.INTERACTION.COMMAND`, `CC.CONTENT.LEVEL`, `CC.CONTENT.CHAPTER_SIGNATURE`, `CC.ASSET.MANIFEST`) are **correct** uses and will be registered. Case is uppercase (`CC.NARRATIVE.…`, not `cc.narrative.…`).
- **Acceptance test:** after each owner's next edit, `git grep -ohE '\\bCC\\.[A-Z]+(\\.[A-Z_]+)+\\b' <branch> -- . ':!06_CONTRACTS' ':!05_PROMPTS'` returns only IDs present in `registry/contract_registry.json` (or pending-registration proposals listed in a handoff).
- **Rollback:** N/A — no rename is required before Phase 01; existing Phase 00 documents are accepted as-is with this CR recorded.
- **Owner confirmation needed:** AI-01 to confirm the namespace ruling as a product-level naming decision (it affects all tracks).

### CR-0010 — `00_CONTROL/PROGRESS.md` shared-append conflict between account PRs
- **Target owner:** AI-13 (gate procedure / merge order) with the account edit convention confirmed by Product (AI-01).
- **Failing artifact:** merging `ai-13-integration` (PR #9) and `ai-01-product` (PR #10) onto `integration` produces a textual conflict in `00_CONTROL/PROGRESS.md`, because both accounts independently append their own `### AI-XX` section at end-of-file.
- **Evidence:** local gate simulation — `git merge --no-ff origin/ai-13-integration` then `origin/ai-01-product` on `origin/integration` (584141c) → `UU 00_CONTROL/PROGRESS.md`, conflict markers around the AI-13 and AI-01 sections. Reproduced 2026-10-10 in the recovery session; see `OPENHANDS_RESUME_STATE.md` §4.
- **Expected behavior:** merging each account PR must not require a content decision. AI-13 resolves the conflict by **keeping both sections unchanged** (the file's own rule: "Each AI must update only its own section"); no account text is dropped or rewritten. This is a mechanical resolution, not an edit to any owner's content, so it stays within AI-13 gate scope.
- **Acceptance test:** after merging any two account PRs onto `integration`, `00_CONTROL/PROGRESS.md` contains one `### AI-XX` section per merged account with 0 conflict markers, and each section is byte-identical to its source branch.
- **Rollback:** revert the merge commit; the branch state is untouched.
- **Risk link:** RISK-0002 (manual gate); a phase with 13 accounts will hit this on nearly every merge until the convention or tooling changes.
- **Resolution (2026-10-10):** the merge sequence (steps 1–8, all 13 branches) was executed on `integration` with the documented mechanical resolution — conflict markers removed, **both account sections kept byte-identical** — in merge commit `c4cc93e`. Accidental-whole-file-overwrite risk (`git checkout --theirs`/`--ours`) was explicitly avoided; `grep '^### AI-'` on the result shows one section per account. The convention itself still needs a Product-confirmed rule (e.g. per-account include files) before Phase 01, so the CR stays `RESOLVED` for the Phase 00 merges only.

### CR-0011 — AI-09 PR #5 fails AI-09's own validator on its own head; handoff claims a clean run
- **Target owner:** AI-09 (`ai-09-narrative`, PR #5).
- **Failing artifact / evidence:** on the PR head `187b1da` (merged onto `origin/integration` @ `584141c` in a local gate simulation), `python3 11_NARRATIVE/tools/validate_narrative_registry.py` exits **1** with:
  - `FAIL  11_NARRATIVE/CHAPTER_BEAT_MAP.md: references undefined ID 'nar.chapter.07_silent_engine'`
  - `FAIL  01_PREPRODUCTION/STORY_BIBLE_V7.md: references undefined ID 'nar.chapter.07_silent_engine'`
  Registry is v0.1.1 `[APPROVED_BASELINE]` where the canonical ID is `nar.chapter.07_quiet_engine` and `silent_engine` is only a `superseded_ids.old` entry. `11_NARRATIVE/HANDOFF_PHASE00_AI09.md` states "Result of final run: 24 pass groups, 0 failures … exit 0" and "validator run clean" — this is **not reproducible on the PR head** (actual: 35 pass groups, 2 failures, exit 1). The mismatch means the handoff evidence does not match the delivered tree.
- **Defect 1 (substantive):** `11_NARRATIVE/CHAPTER_BEAT_MAP.md` still names Chapter 7 `### Ch.07 The Silent Engine — nar.chapter.07_silent_engine`. PD-028 §B makes "Quiet Engine" canonical and "Silent Engine" non-canonical, so this section is stale canon, not merely a broken link.
- **Defect 2 (validator gap):** `01_PREPRODUCTION/STORY_BIBLE_V7.md` line 11 is the **v0.1.1 version-history row that documents the rename** (`nar.chapter.07_silent_engine` → `nar.chapter.07_quiet_engine`). Quoting the old ID inside a changelog is legitimate history, but the validator's markdown cross-reference scan (§11 of the tool) does not exempt version-history / supersession documentation, so it flags a correct statement. The fix is a validator refinement (skip the version-history table row, or allow an ID that appears only as a `superseded_ids.old`), not a content rewrite.
- **Expected behavior:** `python3 11_NARRATIVE/tools/validate_narrative_registry.py` exits 0 on the PR head; the handoff's recorded result matches the tree; Chapter 7 is labelled "Quiet Engine" everywhere except deliberate rename history.
- **Acceptance test:** the exact command above exits 0 on `ai-09-narrative` head; `git grep -n 'Silent Engine'` returns hits only in rename-history context; a negative fixture proving the scan still catches a genuinely undefined ID passes.
- **Rollback:** revert AI-09's fix commit; validator behaviour for other files is unchanged.
- **Note:** this is returned to AI-09 (producer). AI-13 does not patch `ai-09-narrative` (`05_PROMPTS/INTEGRATION_GATE_PROMPT_AI13.md`). PR #5 also carries the base-branch defect CR-0008.
- **Resolution (2026-10-10), commit `ea12651` on `ai-09-narrative`:** executed as an explicitly scoped AI-09 task on the owner's branch (the recovery agent had to run several account tasks sequentially; each is separately scoped, committed and evidenced). (a) `11_NARRATIVE/CHAPTER_BEAT_MAP.md` Ch.07 heading corrected to `### Ch.07 The Quiet Engine — nar.chapter.07_quiet_engine`; (b) `11_NARRATIVE/tools/validate_narrative_registry.py` §11 now exempts a superseded old ID only when the same document also cites its registered `superseded_ids.new`; (c) the handoff's stale "24 pass groups / 0 failures" line corrected to the real result. **No check was weakened:** an orphaned superseded ID (`nar.chapter.07_silent_engine` without `nar.chapter.07_quiet_engine` in the same file) and a genuinely undefined ID (`nar.chapter.99_ghost`) both still FAIL (verified by injected fixtures). Validator on the new PR head: `35 pass groups, 0 failures`, exit 0.

### CR-0012 - AI-10 QA Phase-00 validator FAILS on the integrated Phase 00 tree (passed only in isolation)
- **Target owner:** AI-10 (`ai-10-qa`, PR #7).
- **Failing artifact / evidence:** on the fully integrated tree (all 13 branches merged into `integration` at `c4cc93e`), `python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py` exits **1**, `SUMMARY fail=20 info=692 skip=0`. The same validator exits 0 on the `ai-10-qa` branch alone (`evidence/validator_run_ai-10-qa_only.log`), so the defect is only observable once the other accounts' artifacts land - exactly the integration-time condition the gate exists to catch. Two independent causes:
  1. **C2 terminology false positives (16 FAILs).** The `IDENTIFIER` scope (severity `FAIL`, `QA_IP_TERMINOLOGY_RULES.json`) matches affirmative forbidden terms inside other accounts' **negative/declaration data**:
     - `04_AI_ACCOUNTS/AI-04/phase_00/fixtures/interaction_terminology_registry.v0.1.0.json:94` - the `"forbiddenTerms"` list contains `minecraft`, `creeper`, `redstone`, `steve` (QAR-001).
     - `01_PREPRODUCTION/CHARACTERS_VFX/AI06_CHARACTERS_VFX_REGISTER_PHASE00.json:178` - `ipForbiddenTerms.terms` contains `minecraft`, `creeper`, `enderman`, `redstone`, `steve`, `rubik`, `speedcube` (QAR-001/002).
     - Same file lines 132-133 - `domainCutList` entries literally describing rejected categories ("damage", "attack") (QAR-005).
     - `09_ART_AUDIO/AUDIO/fixtures/audio_cue_registry_draft.v0.1.0.json:103,142` - the word "attack" inside a **prose description** field ("Loom attack + ..."), not an identifier (QAR-005).
     The validator already excludes its own `08_QA_RELEASE/phase_00/` path for the same reason ("QA's own rule/register files quote the terms by design"); the same reasoning applies to other accounts' forbidden-term lists and to prose descriptions. This is a **false positive class**, not real IP contamination (AI-10's own `QA_PHASE00_FINDINGS_REGISTER.md` acknowledges the DESIGN_DOC-scope hits are negations).
  2. **E3 stale source baselines (4 FAILs).** The QA plan records `sourceBaseline` versions of Product documents as 1.0.0, but AI-01 advanced them (PD-work on PR #10): SRC-PRODUCT-LOCK 1.1.0, SRC-PD 1.2.0, SRC-IGM 1.0.2, SRC-CUT 1.1.0. QA's baseline must track the **integrated** Product versions or the check can never pass after any Product revision.
- **Expected behavior:** `QA_PHASE00_VALIDATOR.py` exits 0 on the integrated tree. (a) C2 `IDENTIFIER` scanning must not FAIL on a file whose matched term is part of a declared forbidden-terms/cut-list entry (structured data), and should treat free-text `description` fields as `DESIGN_DOC`/INFO, not `IDENTIFIER`; the exclusion must be by *structure/semantics*, not by loosening the term list. (b) E3 `sourceBaseline` versions must be updated to the merged Product document versions.
- **Acceptance test:** `python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py` exits 0 on `integration@c4cc93e`; its F self-test (negative fixtures) still produces failures; a negative case (a real forbidden term used affirmatively in an ID) still FAILS.
- **Rollback:** revert AI-10's fix commit; no other track is affected.
- **Note:** returned to AI-10 (producer). AI-13 does not patch `ai-10-qa` (`05_PROMPTS/INTEGRATION_GATE_PROMPT_AI13.md`). PR #7 is already represented in `integration`; this CR must be resolved by a **follow-up commit on `ai-10-qa`**.
- **Gate impact:** HIGH. AI-10 owns the G-case (measurability) of the gate; while its own validator fails on the integrated tree, L6/L12 measurability cannot be certified. Phase 00 verdict therefore remains **NOT PASSED**.

### CR-0013 — Official engine change: Unity 6 + URP → Godot 4.x + GDScript (product-register update needed)
- **Target owner:** AI-01 (`ai-01-product`) for the product-decision record; AI-02/AI-12 for architecture/build documents (secondary).
- **Trigger / evidence:** Human Project Owner directive (2026-10-10) to move the project to **Godot 4.x stable + GDScript**, Android-first, to remove the Unity licence/CI dependency and produce a runnable build. Executed and evidenced by AI-13: `11_INTEGRATION/ENGINE_MIGRATION_UNITY_TO_GODOT.md`, `game/docs/ENGINE_AND_BUILD.md`, `game/docs/evidence/{unit_tests_run,main_scene_boot,android_export_run}.log`. A signed Android **debug** APK (`com.downwitherfandesign.craftcube`, v0.1.0, minSdk 24, arm64-v8a) was produced (VERIFIED).
- **Failing artifact:** `01_PREPRODUCTION/PRODUCT/PRODUCT_DECISION_REGISTER.md` `PD-025` still records **HUMAN_DECIDED … "Unity 6 + URP + Android"**, and `PD-029` items 4/5 reference Unity version pinning and Unity licence custody. `validate_product_lock.py` §8 **hard-codes** the string `"Unity 6 + URP + Android"` (approx. lines 276-281), so it cannot pass a Godot restatement by editing text alone.
- **Expected behavior:** the product authority's engine change is recorded as a **new superseding** entry (next free ID `PD-030`) with a `Supersedes: PD-025` line; `PD-025` gains a `Superseded by:` pointer; `PD-029` items 4/5 are restated engine-neutrally; `validate_product_lock.py` §8 is updated to the new canonical engine string. The numeric-version ban is preserved (it becomes "no numeric **Godot**/SDK/JDK version pinned in PRODUCT/").
- **Why AI-13 does not make this edit:** the PD register, `PD-025`, and the product validator are **AI-01-owned**; `05_PROMPTS/INTEGRATION_GATE_PROMPT_AI13.md` forbids AI-13 rewriting another account's implementation to make a gate pass. AI-13 therefore records the technical migration and routes the product record to AI-01.
- **Acceptance test:** `python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py` exits 0 with §8 reading the Godot engine string; `PD-030` exists with `Supersedes: PD-025`; `PD-025` shows a matching `Superseded by: PD-030`.
- **Rollback:** revert AI-01's commit; the technical migration files remain valid and independent.
- **Gate impact:** MEDIUM. The engine decision is a product-authority matter; the technical slice is already runnable, but the product record and the validator remain inconsistent with the directive until AI-01 records it. Tracked alongside RISK-0001 (engine/toolchain).

