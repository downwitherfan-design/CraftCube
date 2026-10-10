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
| CR-0008 | AI-02 (PR #1), AI-09 (PR #5) | 00 (before merge) | Low (process) | OPEN |
| CR-0009 | AI-01, AI-06, AI-09, AI-10, AI-11 (+ any account using `CC.*` for non-contracts) | 01 | Medium | OPEN |
| CR-0010 | AI-13 (gate procedure) + all accounts (shared-file convention) | 00 (before merging the second account PR) | Low (process) | OPEN |
| CR-0011 | AI-09 (PR #5) | 00 (before merge) | High (gate blocker) | OPEN |

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
