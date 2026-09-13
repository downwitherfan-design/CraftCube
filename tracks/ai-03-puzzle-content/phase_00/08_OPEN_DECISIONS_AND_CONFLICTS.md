# AI-03 Phase 00 — Open Decisions, Conflicts, Unknowns & Integration Requests

**Status:** LIVE register. Nothing here is guessed; each item names the owner who must decide and what AI-03 does in the
meantime (`00_CONTROL/AI_FAILURE_PREVENTION_PROTOCOL.md` failure classes; `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md` labels).

## A. Decision requests to Product / Human (AI-01, human product authority)

| ID | Decision needed | AI-03 interim behaviour | Why it matters |
|---|---|---|---|
| **AI03-D1** | Act I teaches by *deepening* `objective.align` across ch.01–02 and `objective.pattern` across ch.03–04 (consecutive chapters share a primary family but differ in signature). Approve the refined R2 rule "no two consecutive chapters share the same (primary family, signature) pair", or require a strict family change every chapter? | Validator implements the refined R2. | Strict R2 would force a new family in ch.02, contradicting the first-session simplicity target (V7.1 §14). |
| **AI03-D2** | May *optional* (non-main-path) rewards in Act II+ be `reward_class.capability`? Phase 00 fixtures never lock a capability behind mastery. | No optional capability rewards authored. | Determines whether mastery can ever gate *power* vs only knowledge/collection/expression (DD-006, DD-012). |
| **AI03-D3** | Gold Slice requires "one upgrade/capability decision" (V7.1 §15). Ch.01–02 content yields one capability (Rootweave Gauntlet candidate) but no upgrade. Approve AI-03's proposal that the Slice upgrade decision is the Gauntlet's *Precision vs Versatility* branch (owner AI-02 `UpgradeDefinition`), or extend the Slice into ch.03? | Slice fixture stops at `level.02.span`. | Scope of Phase 06; AI-02 needs to know whether to model an upgrade branch for the Slice. |
| **AI03-D4** | Equipment slot count/names. Equipment Bible says "exact slot count is a Product/UX decision". AI-03 matrix uses the Bible's *suggested* four (Core Resonator, Tool, Companion Module, Field Module) as ASSUMED. | Matrix loadout-tension analysis assumes 4 slots. | Loadout tension in `04_PUZZLE_EQUIPMENT_INTERACTION_MATRIX.md` §3 changes if slots differ. |
| **AI03-D5** | Vertical Slice scope = ch.01 complete + ch.02 through Test (AI-03 recommendation, `07_VERTICAL_SLICE_CAUSALITY_MAP.md` §1). | Fixtures authored to this scope. | Product owns Slice scope. |

## B. Conflicts recorded (CONTRACT_CONFLICT / documentation conflict) — owner must resolve

| ID | Conflict | Sources | Owner | AI-03 interim |
|---|---|---|---|---|
| **AI03-C1** | Chapter 7 / biome 6 name: "The Silent Engine" vs "The Quiet Engine". | `01_PREPRODUCTION/STORY_BIBLE_V7.md` (ch.7) vs `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md` (biome 6) and `ITEM_CATALOG_STARTER_SET.md` ("Quiet Engine"). | AI-09 | Neutral slug `engine` in `chapter.07.engine` / `biome_slug: engine`; fixture `story_theme` field carries the CONFLICT note verbatim. |
| **AI03-C2** | Ownership validator maps `src/Presentation/` → AI-03, but AI-03 is puzzle/content and presentation is AI-04/05/06. | `07_GITHUB/scripts/validate_ownership.py`, `07_GITHUB/CODEOWNERS_EXAMPLE.txt` vs `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md`. | AI-13 (governance) | AI-03 does **not** edit those files; requests correction (see §D). |
| **AI03-C3** | Branch naming: GitHub model says `ai-03/puzzle-content`; the real remote branch is `ai-03-puzzle`. | `07_GITHUB/GITHUB_MODEL.md` vs `git ls-remote`. | AI-13 | Uses the real branch `ai-03-puzzle`. |
| **AI03-C4** | PR target `integration` does not exist on the remote; only `main` and `ai-13-integration` exist. | `07_GITHUB/GITHUB_MODEL.md`, phase prompt ("PR to `integration`") vs `git ls-remote --heads origin` (VERIFIED at commit `584141c`). | AI-13 | Branch pushed; PR opened manually against whichever branch AI-13 designates (see handoff). `gh` CLI is not installed in the sandbox, so the PR cannot be opened from here. |

## C. Unknowns (UNKNOWN_FACT) — not derivable from the repository

| ID | Unknown | Impact | AI-03 handling |
|---|---|---|---|
| **AI03-U1** | Biome assignment for chapters 8–10; chapter assignment for Verdant Archive (biome 5). | Act III signature matrix cannot be authored. | `05_CHAPTER_ANTI_REPETITION_STRATEGY.md` §3 lists candidates only; no IDs, no fixtures. |
| **AI03-U2** | Exact "special pieces/tiles" from the source GDD (ZIP not in repo). | AI-03 tile-type set may diverge from source intent. | Six IP-safe tile types proposed with explicit purpose; AI-01 may map/rename. |
| **AI03-U3** | Whether `LockedAxis` error reason covers layer locks or AI-02 will add `LockedLayer`; whether `EffectNotApplicable` can be added to the error contract. | Affects `rule.layer_lock` and equipment Legality tests. | Proposed reuse; flagged in `03` §1.3 and `04` §6. |
| **AI03-U4** | Whether Collapse becomes a first-class AI-02 domain state or stays a challenge/rule. | Could require a Collapse-native objective family later. | Modelled as rule/challenge (no duplicate system); mapping promised if AI-02 decides otherwise. |
| **AI03-U5** | Reachability and `par_moves` for every fixture level — no solver exists. | Fixture pars are authored claims. | Fields `reachability_verified:false`, `par_source:"authored_unverified"`; validator *rejects* any attempt to set them otherwise in Phase 00. |
| **AI03-U6** | Final `QuestState` shape (AI-03 is the register-named owner). | Not needed for Phase 00 deliverables. | Deferred to Phase 01 with the other AI-03 schema freezes; noted so it is not lost. |

## D. Integration requests to other tracks (actionable, no cross-ownership edits made)

| To | Request | File/contract | Acceptance |
|---|---|---|---|
| AI-13 | Register `tracks/ai-03-puzzle-content/` as AI-03-owned; correct `src/Presentation/ → AI-03` mapping (AI03-C2); confirm PR target branch (AI03-C4). | `07_GITHUB/scripts/validate_ownership.py`, `07_GITHUB/CODEOWNERS_EXAMPLE.txt`, `07_GITHUB/GITHUB_MODEL.md` | Ownership validator lists AI-03 path; PR target documented. |
| AI-02 | Adopt/critique DRAFT shapes: `CC.CONTENT.LEVEL 0.1.0`, `CC.REWARD.DEFINITION 0.1.0`, `CC.DISCOVERY.DEFINITION 0.1.0`; confirm Invariant P-1 (`is_satisfied` ignores loadout) and P-2 as domain properties; decide AI03-U3/U4; own `topology.cube.2` / `topology.cube.3`. | `fixtures/phase00/*.json`, `03_LEVEL_GRAMMAR_AND_DIFFICULTY.md` §1.3 | AI-02 Phase 01 contract references or supersedes these shapes with a versioned note. |
| AI-09 | Decide AI03-C1; confirm/rename fiction terms in `01_PUZZLE_VOCABULARY.md` §6; reserve `loc.level.*`, `loc.discovery.*` key namespaces or provide the canonical namespace. | `01_PUZZLE_VOCABULARY.md`, fixtures `*_key` fields | Terminology decision recorded; key namespace confirmed. |
| AI-10 | Adopt validator + 33-case test suite as the seed of content validation; implement the P-1/P-2, idempotency, interruption and DD-006 tests listed in docs `04` §6 and `06` §6 when the engine exists. | `validators/` | Tests run in CI once AI-12 wires Python or ports to the Unity test runner. |
| AI-07 | Present the six mastery dimensions separately (never one score); keep puzzle-assists distinct from accessibility assists and from equipment reveals. | `02_OBJECTIVE_FAMILIES_AND_MASTERY.md` §4 | UX spec references dimension IDs. |
| AI-04 | Level rules `rule.axis_lock`/`rule.layer_lock` must surface `LockedAxis` feedback without hiding the lock reason; `rule.fog` needs a shape-based veiled state. | `03_LEVEL_GRAMMAR_AND_DIFFICULTY.md` §1.3, §5 | Interaction spec acknowledges. |
| AI-05 / AI-06 / AI-08 | Every tile type requires a non-colour identity (glyph/shape/sound) — accessibility requirement, not a style request. | `01_PUZZLE_VOCABULARY.md` §5, `03` §5 | Asset/audio IDs per tile type planned. |
| AI-01 | Decide AI03-D1…D5. | this file §A | Decision IDs recorded in `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md` process. |

## E. Self-detected and corrected defects (evidence of validator value)

| Defect | How found | Fix | Commit |
|---|---|---|---|
| Slice level 02.2 placed a `tile.resonant`, but `tile.resonant` is chapter 03's signature (R1 violation at level scope). | First run of `validate_phase00_content.py` → `ERROR level.02.resonant_gap: uses tile.resonant before any chapter <= chapter.02.broken_path introduces it`. | Level redesigned as `level.02.locked_gap` with two `anchor` tiles (chapter-02 signature); reward re-targeted to Rootweave Gauntlet candidate (the Tool that relaxes layer locks — a better fit for the chapter's teaching than Tuning Fork, which is now free to be ch.03's `resonant` reward). Docs `06`/`07` synced. | `8ed9ddf`, `226caa4`, `adbb947`, `04e7adc`, `caa6ab5` |
