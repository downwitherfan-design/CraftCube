# Phase 00 — AI-13 Preflight Findings

**Account:** AI-13 · **Phase:** 00 Product/IP Lock · **Baseline commit:** `584141c` ("Initial CraftCube v7 WORLDCLASS baseline")
**Labels:** VERIFIED = observed directly in the repository or command output · INFERRED = derived from verified facts · ASSUMED = working assumption, needs confirmation · UNKNOWN / MISSING / CONFLICT = must not be guessed.

Evidence for every VERIFIED item is in `11_INTEGRATION/evidence/phase00_preflight_repo_facts.txt`.

## 1. Repository state (VERIFIED)

| Fact | Value |
|---|---|
| Remote | `https://github.com/downwitherfan-design/CraftCube.git` |
| Commits on baseline | 1 (`584141c`) |
| Branches at preflight start | `main` + `ai-01-product` … `ai-13-integration` (13 account branches), all pointing at `584141c` |
| `integration` branch | **MISSING at preflight start.** Created by AI-13 from `584141c` and pushed (see §5). |
| Tracked files | 322 files on baseline (318 `.md`, 1 `.json`, 1 `.csv`, 1 `.py`, 1 `.txt`); **no Unity project, no C#, no `.github/workflows`, no `Contracts/` code directory, no tests** |
| Manifest | `00_CONTROL/manifest.json` → `version: v7.1`, `status: WORLDCLASS_START_READY_PRODUCTION_PACK`, 13 accounts, 18 phases, 234 phase prompts |
| PROGRESS.md | Phase 0 / planning package; all contract baselines `TBD 1.0.0`; no account sections filled |

INFERRED: the repository is a planning pack, not a code base. Phase 00 deliverables across all tracks are documents, decisions, registers and fixtures — not runtime code.

## 2. Branch naming CONFLICT (VERIFIED)

| Source | Naming |
|---|---|
| `07_GITHUB/GITHUB_MODEL.md` | `ai-01/product`, `ai-02/core`, `ai-03/puzzle-content`, `ai-04/gameplay-mobile`, `ai-05/environment-art`, `ai-06/characters-vfx`, `ai-07/uiux`, `ai-08/audio`, `ai-09/narrative-localization`, `ai-10/qa`, `ai-11/performance-android`, `ai-12/release`, `ai-13/integration` |
| Actual GitHub branches | `ai-01-product`, `ai-02-core`, `ai-03-puzzle`, `ai-04-gameplay`, `ai-05-world`, `ai-06-creatures`, `ai-07-uiux`, `ai-08-audio`, `ai-09-narrative`, `ai-10-qa`, `ai-11-performance`, `ai-12-build`, `ai-13-integration` |

Resolution (per `00_CONTROL/CONTEXT_PRIORITY_RULES.md` rule 1 — current repository state wins): **the actual branch names are canonical.** `07_GITHUB/GITHUB_MODEL.md` is documentation owned by the GitHub/release area; AI-13 does not rewrite it. Raised as `CR-0001` (see `CHANGE_REQUESTS.md`). The mapping is recorded in `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`.

## 3. Ownership-model CONFLICTS in `07_GITHUB/` (VERIFIED)

`07_GITHUB/CODEOWNERS_EXAMPLE.txt` and `07_GITHUB/scripts/validate_ownership.py` map paths to an **older account numbering** (e.g. `/Assets/Art/ → AI-04`, `/src/UI/ → AI-05`, `tests/ → AI-07`, `.github/ → AI-08`, `Release/ → AI-08`). This contradicts `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` and `00_CONTROL/13_AI_EXECUTION_MANUAL.md`, in which AI-04 = Gameplay, AI-05 = Environment, AI-07 = UI/UX, AI-08 = Audio, AI-10 = QA, AI-12 = Build/Release.

Both files self-describe as "example"/"conceptual" and "adapt … to real GitHub usernames". They are not enforcing anything today (no CI exists). They must be corrected before any CI ownership enforcement is enabled. Raised as `CR-0002`. AI-13 does **not** patch them: `.github/` and release tooling are AI-12 ownership and the CODEOWNERS file is a shared governance artifact requiring a decision record.

## 4. Contract register state (VERIFIED)

- `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md` lists 13 contract families with owner and consumers but **no version, no status, no ID format**.
- `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` lists 10 more families, same gaps.
- `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md` lists 13 dotted IDs of the form `CC.NARRATIVE.CHAPTER`, `CC.ITEM.DEFINITION` … overlapping semantically with the register families (e.g. `CC.ITEM.DEFINITION` ≙ `ItemDefinition`, `CC.WORLD.STATE` ≙ `WorldState`).
- `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md` defines the per-contract fields (ID, owner, version, status DRAFT/FROZEN/RELEASED/DEPRECATED, consumers, compatibility promise, breaking-change policy, test suite, fixture set, migration, decision ID) but **no registry instance exists**.
- `00_CONTROL/PROGRESS.md` lists five *different* baseline contract names (Simulation, Content schema, Save schema, Event IDs, Asset manifest) — a third vocabulary.

CONFLICT (naming): three overlapping contract vocabularies exist (register PascalCase families, `CC.*` dotted IDs, PROGRESS.md baseline names). No two agree on the set. Resolved in this phase by AI-13 governance: the machine-readable registry `11_INTEGRATION/registry/contract_registry.json` assigns **one canonical ID per semantic contract** and records the aliases from each source so nothing is lost and no second semantic system is created. See `CONTRACT_REGISTRY.md` §"Alias policy".

Ownership CONFLICT (VERIFIED): `V7_MASTER_CONTRACT_REGISTER.md` assigns `WorldStateEvent` to "AI-13 governance + AI-02 domain". Under `ACCOUNT_MATRIX.md` "No two AI accounts co-own implementation files". Recorded in the registry as owner `AI-02` (domain semantics) with `governance: AI-13`, which is the pattern the register itself intends and is consistent with `NARRATIVE_ITEM_CONTRACTS.md` ("AI-13 versioning and integration governance"). Flagged `OD-0003` for confirmation; no contract content was invented.

## 5. Actions taken during preflight (VERIFIED)

1. Cloned repository to `/home/user/CraftCube`.
2. Created `integration` branch from `584141c` and pushed to origin (`git checkout -b integration 584141c && git push -u origin integration`). This is AI-13 merge-sequencing ownership. No branch protection was configured — that requires repository-admin (human) action; see `OD-0001`.
3. Checked out `ai-13-integration` as the working branch.

## 6. Engine / platform assumptions (VERIFIED as documented, UNKNOWN as decided)

- `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` states **Unity 6 + URP + Android**. `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` and `13_AI_EXECUTION_MANUAL.md` refer to "Unity build pipeline", "reproducible Unity builds".
- The sandbox in which this AI-13 session runs is a Flutter/Dart toolchain, **not Unity**. AI-13 therefore cannot build, run or test any Unity artifact in this environment, and makes no claim to have done so. This is recorded as `RISK-0001` (engine/toolchain availability across accounts) and `OD-0002` (Product/Human confirmation of engine lock before Phase 02 Bootstrap).
- No Unity version, URP version, Android minSdk/targetSdk, or Google Play policy date is stated anywhere in the repository. These are `UNKNOWN` and are Phase 01 contract inputs for AI-02/AI-11/AI-12, not for AI-13 to invent.

## 7. Terminology surfaces relevant to IP-safety (VERIFIED)

- `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` explicitly states the source GDD used Minecraft-specific names/creatures/presentation and that the mechanical ideas must be separated from proprietary branding.
- Repository canon terminology already present (owned by AI-09 for meaning, AI-01 for product naming): *CraftCube* (public title), *The Loom of Asterra* (internal world name), *Axis Loom*, *Great Misalignment*, *Weaver*, *Hearthwild*, *Glassroot*, *Sunken Grid*, *Ember Hollow*, *Verdant Archive*, *The Quiet Engine*, *Mira*, *Orin*, *Nox*, *The Quiet Architect*, *Vitality*, *Bloom/Collapse*, *Smart Assist*, *Cube Pulse*, *Golden Trail*.
- `grep -rni "minecraft"` across the repository returns hits only in explanatory "not a Minecraft clone" statements and the source-reference note — no proprietary creature/block/item names are used as game content. Evidence in `evidence/phase00_preflight_repo_facts.txt`.
- AI-13 does not own terminology. It records that terminology IDs (localization keys / canon term IDs) do not yet exist as stable IDs anywhere in the repository — they are an AI-09 Phase 00 deliverable per `05_PROMPTS/phase_00/ai_09.md`. Tracked as expected artifact in `PHASE00_INTEGRATION_GATE.md`.

## 8. Stable IDs already present (VERIFIED)

Example IDs quoted in policy docs (not content, not released):
`game.bloom.started`, `game.bloom.completed`, `game.collapse.warning`, `game.collapse.applied`, `companion.ability.used` (`06_CONTRACTS/CONTRACT_FIRST_RULES.md`); `biome.overworld.meadow`, `creature.pollinator.bee`, `chapter.01.meadow`, `event.bloom` (`01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md`).
Decision IDs `DD-001` … `DD-016` exist in `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` (owner: Product / AI-01).
Typed failure reasons `InvalidMove`, `LockedAxis`, `ContentNotFound`, `SaveMigrationFailed`, `ServiceUnavailable`, `BuildConfigurationError` (`06_CONTRACTS/INTERACTION_CONTRACTS.md`).

No `RISK-`, `CR-`, `OD-` or contract registry IDs existed before this phase. The `RISK-nnnn`, `CR-nnnn`, `OD-nnnn` prefixes introduced here were verified absent (`grep -rn "RISK-0\|CR-0\|OD-0"` → 0 hits on baseline).

CONFLICT (minor, VERIFIED): example IDs use two biome vocabularies — `biome.overworld.meadow` / `chapter.01.meadow` (v4-era examples) versus the v7 canon biomes *Hearthwild, Glassroot …*. The examples are explicitly illustrative. No content IDs are released. Recorded so Phase 01 ID freezing (AI-02/AI-03/AI-09) does not accidentally adopt the stale example vocabulary. Raised as `CR-0003` (documentation clarification, owner of the example docs).

## 9. Language note (VERIFIED)

`00_CONTROL/MASTER_ROADMAP.md`, `01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` and `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md` contain Persian-language sections. `PHASE_KICKOFF_PROCEDURE.md` step 2 says "هشت branch مستقل" (eight independent branches) — stale relative to the 13-account model. Not a blocker; raised in `CR-0004` for the doc owner so downstream accounts are not confused.

## 10. What AI-13 did NOT do (explicit)

- Did not build, run or test any game code (none exists).
- Did not run on any Android device.
- Did not modify any file outside `11_INTEGRATION/` and the AI-13 section of `00_CONTROL/PROGRESS.md`.
- Did not freeze or release any contract. All registry entries are `DRAFT`.
- Did not invent field names, schemas, versions, engine versions or SDK levels.
- Did not configure branch protection (requires human repository admin).
