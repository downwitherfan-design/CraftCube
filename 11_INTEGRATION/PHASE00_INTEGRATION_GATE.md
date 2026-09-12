# Phase 00 Integration Gate — Product/IP Lock

**Gate owner:** AI-13 · **Approval authority for identity/story/scope items:** Human product authority (`00_CONTROL/13_AI_EXECUTION_MANUAL.md` "Human approval gates") · **Phase mission:** lock product vision, scope, audience, platform assumptions, terminology, IP-safe direction, success criteria and measurable boundaries.

AI-13 does not author the product lock. This gate defines **what must exist, who owns it, how it is checked, and which decisions are open**, so that the combined Phase 00 output is coherent, integrable and downstream-usable.

## 1. Gate verdict (current)

**NOT PASSED — awaiting other accounts' Phase 00 artifacts and Human decisions OD-0001…OD-0007.**
AI-13's own Phase 00 contribution (this directory) is complete and validated (`python3 11_INTEGRATION/scripts/validate_registry.py` → PASS; see `evidence/`).

Gate status is re-evaluated when each account's PR reaches `integration`. Verdict values: NOT PASSED / CONDITIONAL (mitigation owner + date recorded) / PASSED.

## 2. Lock checklist (what "locked" means for integration)

Each row must be satisfied by an artifact on `integration`, not by a chat statement.

| # | Lock item | Owning account | Artifact expected (path is owner's choice unless already canonical) | Integration check performed by AI-13 |
|---|---|---|---|---|
| L1 | Product vision, one-sentence value proposition, core fantasy, pillars | AI-01 | Product truth document referencing `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` §1–§5 | Coherent with bible §3 protected hierarchy; no new pillar contradicts DD-001 |
| L2 | Scope: Must / Should / Later / Reject + hard CUT LIST | AI-01 | Feature list per `01_PREPRODUCTION/INVESTMENT_GATE.md` Gate A | Every "Must" maps to ≥1 registry contract or an explicit "no contract needed"; every Reject is absent from other tracks' plans |
| L3 | Target audience + platform assumptions (Android tiers, offline-first) | AI-01 (audience) / AI-11 (device tiers) / AI-12 (store/platform) | Audience statement; device-tier table extending `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`; platform constraints | DD-010 and DD-015 satisfied; tiers reference measurable criteria, not adjectives |
| L4 | Terminology: canon terms as stable IDs/keys | AI-09 | Term/localization key register (seed for `CC.LOCALIZATION.KEY`) | Every proper noun in the bibles has exactly one key; no key collides with an alias in `registry/contract_registry.json` |
| L5 | IP-safe direction | AI-01 (decision) / AI-09 (names) / AI-05, AI-06 (visual language) | IP statement + naming audit against `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` | `git grep -i` for source-GDD proprietary terms in content paths returns 0; OD-0005 recorded |
| L6 | Success criteria / Investment Gate metrics | AI-01 (definition) / AI-10 (measurability) | Metric list for fun, clarity, uniqueness, equipment value, story curiosity, mobile feasibility | Each metric has a measurement method (`08_QA_RELEASE/EVIDENCE_STANDARD.md`) — not "feels good" |
| L7 | Measurable boundaries: complexity ceilings | AI-01 (approve) / AI-13 (track) | `COMPLEXITY_BUDGET.md` accepted or amended by Product | Counts present for all V7_1 §16 dimensions |
| L8 | Story premise, three-act spine, ≥3 arcs, Mystery/Payoff Register, Item/Relic Lore Register | AI-09 | Story Bible revision + registers | No lore-wall dependency (DD-003); every committed mystery has a planned payoff; item lore entries reference item candidates by a stable candidate ID, not free text |
| L9 | Equipment/item philosophy + slot-count decision boundary | AI-01 (approve) / AI-02 (state semantics) / AI-07 (UX ceiling) | Approved philosophy + "exact slot count deferred to Vertical Slice" recorded (`EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`) | DD-002/DD-012 restated as testable rules; no item candidate promoted to "implementation requirement" |
| L10 | Puzzle vocabulary, objective families, anti-repetition strategy, deterministic reward conditions | AI-03 | Puzzle grammar document | DD-006 deterministic path stated for every critical-progression reward |
| L11 | Domain boundaries for a deterministic core | AI-02 | Domain-boundary audit of source GDD concepts | `Domain` has no Unity/UI/network references (`02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` dependency rule) |
| L12 | Interaction, world, creature, UX, audio, QA, performance, build feasibility notes | AI-04 … AI-08, AI-10, AI-11, AI-12 | One feasibility note each, per `01_PREPRODUCTION/13_ACCOUNT_PARALLEL_START.md` | Each note lists contracts it will consume by canonical `CC.*` ID and which mock it will build |
| L13 | Governance: registry, dependency graph, risk register, merge sequence, gate | AI-13 | This directory | `validate_registry.py` PASS |

## 3. Cross-track semantic conflict watch-list

Conflicts AI-13 will specifically check when the L-artifacts arrive (they are the places where the bibles allow two readings):

1. **Slot count.** `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` suggests four slots but defers the number. AI-07 UX and AI-02 state must not each fix a different number. Resolution owner: AI-01 via Vertical Slice evidence.
2. **Reward vs. acquisition.** `RewardDefinition` (AI-03) and `ItemAcquisition` (AI-02 inferred) both describe how an item enters ownership. See CR-0006.
3. **Item families.** Three documents list six families with different names (`Resources` vs `Field Modules`; `Collectibles` vs `Memory Collectibles`): `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`, `ITEM_DESIGN_BIBLE.md`, `ITEM_EQUIPMENT_PROGRESSION.md`. One canonical family list must be chosen by AI-01/AI-09 before `CC.ITEM.DEFINITION` freezes. Recorded in `COMPLEXITY_BUDGET.md`.
4. **Rarity tiers.** `Utility / Named / Relic / Mastery` (master bible) vs `Common utility / Named artifact / Chapter relic / Mastery relic` (`NARRATIVE_ITEM_INTEGRATION.md`). Same four-tier idea, different labels — one label set must be canonical.
5. **Biome state model.** Seven state kinds + five tiers (`WORLD_BIOME_BIBLE_V7.md`) vs six named states (`STORY_AND_WORLD_VISION.md`: restored, altered, discovered, corrupted, mastered, unresolved). AI-02 must define one state enum.
6. **Companion role.** DD-007 "no combat bloat" is consistent across bibles; watch for AI-06 VFX or AI-04 interaction notes introducing combat verbs.
7. **Currency.** V7_1 §6 says no currency layer is assumed; `TECHNICAL_BLUEPRINT.md` save design lists `economy`. OD-0006.
8. **Engine.** Unity 6 + URP stated; AI-13 sandbox is Flutter. OD-0002.

## 4. Open Product / Human decisions

`OD-nnnn` IDs are stable. AI-13 cannot approve any of these. Each lists what is blocked until decided.

### OD-0001 — Apply branch protection to `integration` and `main`
- **Decision needed from:** repository admin (Human).
- **Content:** apply `07_GITHUB/BRANCH_PROTECTION_CHECKLIST.md`: PR review, CI (once it exists), AI-13 approval for `integration`; release gates for `main`.
- **Blocked until decided:** enforceable "merge is a gate" (RISK-0002). Interim: manual AI-13 gate.

### OD-0002 — Confirm engine lock (Unity 6 + URP) and account toolchain access
- **Decision needed from:** Human + AI-01.
- **Content:** confirm `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` engine choice; state which accounts are expected to have Unity available, and how accounts without it deliver (data/contracts/fixtures/docs only). Record Unity/URP version and Android minSdk/targetSdk as `CC.BUILD.*` inputs for AI-12 (currently UNKNOWN).
- **Blocked until decided:** Phase 02 Bootstrap; any build claim by any account (RISK-0001).

### OD-0003 — Confirm `CC.WORLD.STATE_EVENT` single owner = AI-02
- **Decision needed from:** AI-01 (product) with AI-02 acknowledgement; AI-13 records.
- **Content:** `V7_MASTER_CONTRACT_REGISTER.md` says "AI-13 governance + AI-02 domain". Registry records owner AI-02 / governance AI-13 to satisfy the single-owner rule.
- **Blocked until decided:** freezing `CC.WORLD.STATE_EVENT` in Phase 01.

### OD-0004 — Asset manifest / asset-ID contract owner
- **Decision needed from:** AI-01.
- **Content:** `09_ART_AUDIO/ASSET_PIPELINE.md` defines asset metadata but no single owner for the manifest format (AI-05 environment, AI-06 characters, AI-08 audio each produce assets; AI-12 packages them).
- **Blocked until decided:** registration of the asset-manifest contract (CR-0007 remainder).

### OD-0005 — IP-safe direction record
- **Decision needed from:** Human (legal/IP) with AI-01.
- **Content:** confirm the direction in `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` — keep mechanical ideas, no licensed path, no proprietary names/creatures/visual language; confirm public title "CraftCube" and internal world name "The Loom of Asterra" are cleared for use (trademark check is outside AI scope and is UNKNOWN).
- **Blocked until decided:** L5; final naming in `CC.LOCALIZATION.KEY`.

### OD-0006 — Does a resource/currency layer exist in the Gold Slice?
- **Decision needed from:** AI-01 (+ Human if monetization-adjacent).
- **Content:** DD-014 and V7_1 §6 require a validated product decision before any currency exists. `TECHNICAL_BLUEPRINT.md` save design lists `economy`.
- **Blocked until decided:** `CC.RESOURCE.LEDGER` freeze; save-schema `economy` field; `COMPLEXITY_BUDGET.md` currency count (currently 0).

### OD-0007 — Canonical item family list and rarity labels
- **Decision needed from:** AI-01 with AI-09.
- **Content:** choose one of the three family lists and one of the two rarity label sets (§3 items 3–4).
- **Blocked until decided:** `CC.ITEM.DEFINITION` freeze; AI-07 inventory UX categories; `COMPLEXITY_BUDGET.md` item-family count.

## 5. How an account gets through this gate

1. Open PR from `ai-XX-<name>` → `integration` using `07_GITHUB/PR_TEMPLATE.md`.
2. Handoff (per `05_PROMPTS/HANDOFF_TEMPLATE.md`) names the L-rows it satisfies and the `CC.*` IDs it consumes.
3. AI-13 runs `validate_registry.py` on the merged tree, checks ownership (files only under the account's paths), checks §3 watch-list, and either approves or files a `CR-nnnn`.
4. Merge order per `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`.

## 6. Rollback

Phase 00 produces only documents and registers. Rollback of any account's Phase 00 merge = `git revert <merge-commit>` on `integration`; `main` stays at `584141c` until the Phase 00 gate is PASSED and a Human approves promotion.
