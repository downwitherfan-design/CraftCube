# CraftCube — Product Decision Register (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.DECISIONS` |
| Version | 1.2.0 |
| ID family | `PD-###` (Product Decision). Immutable once released. Never reuse a number. |
| Relationship to `DD-###` | `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` holds *starting design decisions*. `PD-###` records Product's **approve / reject / defer** verdicts on them and on the v7 bibles, with testable acceptance criteria. `PD` entries cite the `DD` they confirm; they never duplicate a `DD`. |

## Verdict vocabulary

- **APPROVED** — Product accepts; acceptance criteria below become required tests/evidence for the owning track.
- **APPROVED_WITH_LIMITS** — Accepted only inside the stated bounds.
- **REJECTED** — Not to be built; listed in the Cut List.
- **DEFERRED_TO_HUMAN** — Touches a human approval gate (`00_CONTROL/13_AI_EXECUTION_MANUAL.md` §Human approval gates). Product recommendation recorded; no track may act as if decided.
- **DEFERRED_TO_EVIDENCE** — Decision waits for a named phase gate's measured evidence.
- **HUMAN_DECIDED** — A human-gated decision that the Human Product Authority has taken; recorded verbatim by AI-01. Same force as APPROVED; superseded only by a later human decision. (Added in v1.2.0.)

Every acceptance criterion is written so AI-10 can turn it into a test, a playtest protocol item, or a validator check. Criteria that need player data are marked `[PLAYTEST]`; criteria checkable from data/content are `[VALIDATOR]`; criteria checkable from a build are `[BUILD]`.

---

## PD-001 — Core narrative premise

**Verdict:** APPROVED
**Subject:** The Axis Loom / Great Misalignment / Weaver premise and the three-layer mystery (Bible §6–§7, Story Bible §Premise).
**Confirms:** DD-003 (story is gameplay-first), DD-008 (scoped choices).

**Why approved:** The premise makes the puzzle the *literal* language of the world — solving is not a minigame gate but the causal act. The three-layer mystery (What happened? Who? What was it designed to become?) supplies a question per act without requiring branching trees. The Act III question ("should the world be restored exactly as it was?") gives the puzzle mastery a moral weight rather than a power fantasy — that is the differentiator.

**Limits:**
- The player character stays lightly defined (Story Bible §The Weaver). No voiced protagonist, no name selection screen in v1.
- Choices are **scoped persistent consequences** only (Story Bible §Narrative choice philosophy). Maximum narrative memory flags per chapter: 6 (`PRODUCT_LOCK_V1.md` §10).

**Acceptance criteria:**
- `[PLAYTEST]` After Act I Chapter 1, ≥ 70% of fresh players can state, in their own words, that twisting the cube changed the world.
- `[PLAYTEST]` After Act I, ≥ 60% of players spontaneously voice at least one "why/what" question about the world or the Loom (story curiosity, see `IGM-005`).
- `[VALIDATOR]` Every chapter definition declares exactly one *question introduced* and at least one *question advanced or resolved* (V7.1 §3). Missing either → validation failure.
- `[VALIDATOR]` No mandatory narrative text node before the first solve exceeds 40 words in the source language.
- `[VALIDATOR]` The main story path is completable with zero optional lore entries read (Story Bible §Narrative fail-safe) — expressed as: no critical-path prerequisite references a `Memory Collectible` or optional discovery.

**Open items for AI-09 (not blocking approval):** "Quiet Engine" vs "Silent Engine" naming conflict; "Verdant Archive" biome lacks a chapter mapping (see `PRODUCT_LOCK_V1.md` §6.4). **Resolved by:** PD-028 §B (Quiet Engine canonical) and PD-028 §C (Verdant Archive LATER).

---

## PD-002 — Role of equipment and item progression

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** Item families, equipment slots, effects, upgrades, resonance, acquisition (Equipment & Item Master Bible; Item & Equipment Progression; V7.1 §5).
**Confirms:** DD-002, DD-005, DD-012.

**Product definition of equipment's job:** *Equipment changes what the player can perceive, reach, or attempt. It never changes what is true about the cube.*

**Approved item families (6):** Relics, Tools, Resonators, Companion Gear, Field Modules, Memory Collectibles — as named in the Equipment Bible. `ITEM_EQUIPMENT_PROGRESSION.md` lists a slightly different set (adds "Resources", names "Story Relics"/"Resonance Equipment"/"Companion Items"/"Collectibles"). **Product ruling:** the Equipment & Item Master Bible naming is canonical; "Resources" is *not* an item family — it is the single resource governed by `PD-004` and DD-014. AI-09/AI-13 should reconcile the older document; no track may implement seven families.

**Approved effect categories:** information, access, interaction, efficiency, risk management, exploration, companion synergy, puzzle strategy (Equipment Bible §Equipment effects). No "damage", "defense", "health" or "attack" categories exist.

**Limits:**
- Active loadout: **≤ 4 slots** (Core Resonator, Tool, Companion Module, Field Module as the *candidate* structure). Exact count ≤ 4 is validated in the Gold Slice (`PD-015`).
- Meaningful equipment/relic items at v1 release: **≤ 12**. Memory Collectibles are excluded from this cap but capped separately at ≤ 30.
- Upgrades: **branches, not levels.** Each upgradable item has ≤ 3 branches; each branch has ≤ 2 steps. A branch must produce an observable behavioral difference.
- Rarity tiers: Utility / Named / Relic / Mastery (Equipment Bible). No color-coded rarity ladder beyond these four; no numeric rarity.
- Crafting: at most one lightweight combine interaction in v1 (`CUT-010`); no crafting tree.
- Durability that destroys items: REJECTED (`CUT-009`). Charges/cooldowns allowed only where they create a decision.
- Set synergy: ≤ 3 named combinations at v1.

**Acceptance criteria:**
- `[VALIDATOR]` Every equipment item declares ≥ 2 affirmative answers to the Bible §9 six-question test, recorded in its item identity card (V7.1 §5.1).
- `[VALIDATOR]` No equipment effect definition may reference or mutate puzzle truth (cube permutation state, legal-move set, solved predicate). Effects are consumed via the capability model only (`02_ARCHITECTURE/NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md` §Capability model).
- `[VALIDATOR]` Zero critical-path items are acquired via random drop (DD-006).
- `[VALIDATOR]` Count of equipment/relic items ≤ 12; count of active slots ≤ 4; upgrade steps per branch ≤ 2.
- `[BUILD]` With all equipment removed from the save, every critical-path puzzle remains solvable by legal moves alone (protected-core proof; ties to DD-001). This is a required automated regression, owner AI-10.
- `[PLAYTEST]` ≥ 60% of Gold Slice players can name, unprompted, one thing an item let them *do differently* (see `IGM-004`).
- `[PLAYTEST]` Loadout change from gameplay ≤ 2 taps, measured by UX walkthrough.

**Rejected within this subject:** stat-only items; equipment gates on the critical path ("you need item X to continue" where X is not a story-granted deterministic item); gear score; item level numbers.

---

## PD-003 — Maximum acceptable progression / menu complexity

**Verdict:** APPROVED (this decision *defines* the cap)
**Subject:** Complexity budget (V7.1 §16), inventory/loadout UX, progression layers (Progression Bible).
**Confirms:** DD-011, DD-014, DD-016.

**Product cap (v1, hard):**

| Dimension | Cap | Notes |
|---|---|---|
| Player-facing currencies/resources | 1 | A second requires a new `PD` and human approval (monetization adjacency). |
| Item families | 6 | Per `PD-002`. |
| Active equipment slots | 4 | Per `PD-002`. |
| Upgrade materials distinct from the single resource | 0 | Upgrades consume the one resource or are unlocked by mastery/story, never a second material. |
| Quest states | 6 | DISCOVERED → ACCEPTED → ACTIVE → BLOCKED(optional) → RESOLVED → CONSEQUENCE_APPLIED (V7.1 §4). No additional states. |
| World state tiers per biome | 5 | Tier 0–4 (World Biome Bible). |
| Narrative memory flags per chapter | 6 | DD-013. |
| Top-level player menus (excluding Settings) | 4 | Candidate set: Map/World, Loadout, Journal (story + discovery ledger), Companion. Any fifth requires a `PD`. |
| Taps from gameplay to any top-level menu | 1 | |
| Taps from gameplay to change a loadout item | 2 | |
| Onboarding tutorial steps before free play | 5 | Each step ≤ 1 sentence of instruction. |
| Simultaneous on-screen HUD elements during a solve | 4 | Cube, assist affordance, companion presence, one contextual prompt. |

**Progression layers approved:** Knowledge → Capability → Access → Mastery (Progression Bible). Progression is **never** expressed as a single player level or XP bar (`CUT-006`).

**Acceptance criteria:**
- `[VALIDATOR]` A complexity-budget report (owner AI-13 governance, fed by AI-02/03/07 data) counts each dimension above; any value over cap fails the phase gate.
- `[PLAYTEST]` ≥ 80% of Gold Slice players locate and change a loadout item without help on first attempt.
- `[PLAYTEST]` ≤ 10% of players describe menus as "confusing" or "too many" in exit interview.
- `[BUILD]` Every menu screen is reachable and dismissible with one-hand portrait interaction (AI-07 evidence).

---

## PD-004 — Economy and resources

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** Whether any resource/currency exists (V7.1 §6, DD-014).

**Ruling:** v1 may have **at most one** player-visible resource, and only if the Gold Slice shows it improves *preparation, discovery or choice*. If no such evidence exists by the Phase 06 gate, the resource is cut and upgrades are unlocked purely by story/mastery/discovery.

**Limits:** readable source and sink; no gating that only delays; no gambling acquisition; no irreversible loss from failure; no premium/hard currency at v1 (`PD-014` monetization is human-gated).

**Acceptance criteria:**
- `[VALIDATOR]` Resource ledger declares ≤ 1 resource type.
- `[VALIDATOR]` Every sink is reachable by a deterministic source within the same chapter it is introduced.
- `[PLAYTEST]` ≥ 70% of players can explain what the resource is for after first acquiring it.

---

## PD-005 — Companion role

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** Nox and the companion system (Companion Bond Bible; Story Bible §Nox).
**Confirms:** DD-007.

**Limits:** exactly **one** companion in v1 (`CUT-004`); role = sensing, reacting, hinting, discovery, emotional readability. No combat. Bond progression Meet → Trust → Shared discovery → Capability → Memory → Choice is approved as *structure*; bond must never be a gate on the critical path and must never be advanced by repeatable gifting (`CUT-011`).

**Acceptance criteria:**
- `[VALIDATOR]` Companion reaction definitions reference only: puzzle states, biome health, relics, story revelations, mastery moments, player choices (Bond Bible list). Any other trigger fails.
- `[VALIDATOR]` No critical-path prerequisite references a bond level.
- `[PLAYTEST]` ≥ 50% of Gold Slice players mention Nox unprompted when asked what they remember.

---

## PD-006 — Discovery and world memory

**Verdict:** APPROVED
**Subject:** Optional secrets, discovery ledger, world memory persistence (Quest & Discovery Bible; Discovery & Replayability; World Biome Bible §World-state model).
**Confirms:** DD-004, DD-006, DD-013.

**Limits:** secrets are optional, deterministic or controlled-seed, and never progression blockers. World memory uses explicit flags, capped per `PD-003`.

**Acceptance criteria:**
- `[VALIDATOR]` Every discovery definition answers the four Secret Design Test questions (notice / skill / reveal / worth) as non-empty fields.
- `[VALIDATOR]` Every discovery has a deterministic reproduction path recorded (seed or state sequence) so AI-10 can automate it.
- `[BUILD]` Save → kill app → reload preserves every world-memory flag and discovery ledger entry (interruption safety).
- `[PLAYTEST]` ≥ 50% of players find at least one optional discovery in the Gold Slice without being told secrets exist.

---

## PD-007 — Smart Assist

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** Player-selectable assist (from source GDD mechanics; retained as an original mechanic name).

**Ruling:** Assist exists to protect *clarity*, not to remove *mastery*. Assist levels are player-chosen, always available, never monetized, and recorded as a mastery dimension (Progression Bible §Mastery metrics: "optional assist usage"). Assist must never perform moves for the player on the critical path; it may highlight, preview, or explain.

**Acceptance criteria:**
- `[VALIDATOR]` No assist level definition performs a move on behalf of the player.
- `[BUILD]` Assist level is changeable mid-puzzle in ≤ 2 taps and persists in save.
- `[PLAYTEST]` Players who use max assist still report "I figured it out" ≥ 50% of the time (assist preserves ownership of the solve).

---

## PD-008 — Puzzle Affinity layer

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** Data-driven affinity linking equipment to puzzle states / challenge types / biomes / conditions.

**Ruling:** Affinity *unlocks interactions or information*; it never multiplies a value or alters legal moves. Affinity matrix size at v1 ≤ 12 items × 6 biomes.

**Acceptance criteria:**
- `[VALIDATOR]` Every affinity entry maps to an effect in an approved category (`PD-002`); none maps to a numeric multiplier.
- `[BUILD]` Disabling the affinity layer does not change any puzzle's solvability.

---

## PD-009 — Mastery and challenge variants

**Verdict:** DEFERRED_TO_EVIDENCE (Phase 06 Gold Slice)
**Subject:** Challenge types list (Progression Bible §Challenge types).

**Product recommendation:** ship Standard solve as MUST; Limited assistance and Move efficiency as SHOULD; the remaining five as LATER until the Gold Slice proves players revisit content. Mastery is multi-dimensional, never one score (Progression Bible).

**Acceptance criteria (to unlock SHOULD items):**
- `[PLAYTEST]` ≥ 30% of Gold Slice players voluntarily replay a solved puzzle.

---

## PD-010 — Offline core

**Verdict:** APPROVED
**Confirms:** DD-015.
**Ruling:** Analytics, leaderboards, remote content, and any account system are optional layers that fail closed. Absence of network must be indistinguishable from presence for the critical path.

**Acceptance criteria:**
- `[BUILD]` Full Gold Slice completable in airplane mode with no error dialogs.

---

## PD-011 — Accessibility and comfort as product requirements

**Verdict:** APPROVED
**Subject:** V7.1 §9 list.
**Ruling:** Reduced motion, camera comfort, haptic intensity, larger touch targets, text-speed control, color-independent cube readability, and safe-area handling are v1 MUST as *design constraints from Phase 01*. Implementation phasing is AI-07/AI-04/AI-08's, but no contract may make them impossible later (e.g., color-only tile identity is forbidden in the puzzle presentation contract).

**Acceptance criteria:**
- `[VALIDATOR]` Puzzle tile identity is encoded by at least two independent channels (e.g., color + glyph/pattern) in the presentation contract.
- `[BUILD]` Accessibility smoke test (V7.1 §15) passes in the Gold Slice.

---

## PD-012 — Localization-safe from day one

**Verdict:** APPROVED
**Ruling:** No player-facing string is hard-coded; all go through AI-09 localization keys. Text expansion (+35% length budget over English) is a UX layout requirement.

**Acceptance criteria:**
- `[VALIDATOR]` Zero hard-coded player-facing strings in runtime code (AI-10 lint/validator).
- `[BUILD]` Pseudo-localization pass at +35% length shows no clipped text in Gold Slice screens.

---

## PD-013 — Final public title

**Verdict:** DEFERRED_TO_HUMAN
**Superseded by:** PD-026 (HUMAN_DECIDED, v1.2.0) — working title kept; trademark clearance still required; `CC.` namespace declared title-independent.
**Product recommendation:** keep **CraftCube** as the working title through Phase 06; run a title check (trademark/store-name availability) before Phase 14. Do not spend on logo/brand assets before the human decision.

---

## PD-014 — Monetization model

**Verdict:** DEFERRED_TO_HUMAN
**Superseded by:** PD-027 (HUMAN_DECIDED, v1.2.0) — premium one-time purchase.
**Product recommendation:** design v1 as if **premium (one-time purchase) or free-with-single-unlock**, with no in-game currency store. This keeps all systems honest to DD-009/DD-014 and avoids designing economy hooks that a later premium decision would have to rip out. Any ads, IAP or subscription requires human approval and a new `PD`.

**Design constraint enforced now regardless of outcome:** no system may be designed with a "monetization slot" (e.g., a second currency, a timer, a paid assist).

---

## PD-015 — Release chapter count and slot count

**Verdict:** DEFERRED_TO_EVIDENCE (Phase 06 Gold Slice)
**Product recommendation:** Story Bible outlines 10 chapters. Product's default position is **Act I (3 chapters) at full authored quality is the minimum shippable core**; Acts II–III chapter count (up to 7) is decided after measuring Gold Slice production cost per chapter. Exact equipment slot count (≤ 4) is confirmed at the same gate.

**Acceptance criteria to make the decision:**
- `[EVIDENCE]` Measured production cost (person/AI-hours, asset count, validator time) for the Gold Slice chapter, published by AI-13.

---

## PD-016 — Rejected feature classes (summary pointer)

**Verdict:** REJECTED
All items in `CUT_LIST_AND_COMPLEXITY_BUDGET.md` marked `REJECT` are rejected by this decision. Reintroducing any requires a new `PD-###` with evidence and, where it touches scope/identity/monetization, human approval.

---

## PD-017 — Story Promise (AI-09 OD-03)

**Verdict:** APPROVED (product level; canon text remains a Human gate)
**Canon gate closed by:** PD-028 §A (HUMAN_DECIDED, v1.2.0) — Story Promise approved as canon baseline.
**Subject:** AI-09's proposed Story Promise in `01_PREPRODUCTION/STORY_BIBLE_V7.md` (branch `ai-09-narrative`): *"Every time you master the cube, the world visibly answers — and the more you understand it, the less certain you become that putting it back the way it was is the right thing to do."*
**Confirms:** PD-001, DD-003, DD-008.

**Why approved:** see `PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md` §1. Product boundaries on the promise are listed there and are binding on AI-09.

**Acceptance criteria:**
- `[VALIDATOR]` The false lead ("back / the way it was") is planted in Chapter 1 content by an action or a character line ≤ 25 words, not by narration.
- `[PLAYTEST]` After Act I, ≥ 40% of players, asked "do you think you should put the world back the way it was?", give a non-certain answer ("not sure", "maybe not", "depends") — evidence that the second clause is felt, not told.

---

## PD-018 — Finale option set (AI-09 OD-04)

**Verdict:** APPROVED_WITH_LIMITS
**Subject:** `nar.flag.final_configuration` = {hold, weave, open}; three closed options, no "bad" ending, all warm.
**Confirms:** DD-008, CUT-013.

**Limits:**
- Exactly **3** options; adding a fourth requires a new PD and Human canon approval.
- The three finales differ in **presentation, epilogue lines and world-visual state only**. No option may require a separately authored chapter, biome or puzzle set (that would be CUT-013 branch explosion).
- The choice is made through a **real cube configuration the player performs** (§7 rule 4 of the policy: the cube is never a cutscene prop), not through a dialogue menu.
- Option names are English placeholders owned by AI-09; player-facing text via `loc.*` keys only.

**Acceptance criteria:**
- `[VALIDATOR]` Finale content declares one `nar.flag.final_configuration` write and ≤ 3 flag-dependent presentation variants (`CMP-008`).
- `[VALIDATOR]` Finale authored-asset count for the three variants ≤ 1.5× the count of a single variant (measured by AI-13 at Phase 06+ when assets exist).
- `[PLAYTEST]` ≥ 70% of Gold Slice players (when the finale exists) can explain what their chosen option meant in one sentence.

---

## PD-019 — Wayfinder Shard merged into Nox (AI-09 OD-05)

**Verdict:** APPROVED (merge)
**Subject:** AI-09's anti-duplication decision to fold the seed item *Wayfinder Shard* ("reveal direction to unresolved discovery") into Nox's sensing role.
**Confirms:** DD-007, DD-011, `CMP-003`.

**Ruling:** Nox is the single owner of the player question "where is something I haven't found?". No item, UI marker or menu may duplicate this. A **Companion Gear** item may *sharpen* Nox's sensing (e.g., the seed candidate *Nox Harness*) because it acts through the companion, not beside it.

**Acceptance criteria:**
- `[VALIDATOR]` No `CC.ITEM.DEFINITION`/`CC.EQUIPMENT.EFFECT` entry declares a "reveal direction to discovery" effect outside the Companion Gear family.
- Seed set count becomes 11 candidates (Product cap for release remains ≤ 12 equipment/relic items, `PD-002`).

---

## PD-020 — Canonical item family list and rarity labels (AI-13 OD-0007)

**Verdict:** APPROVED
**Subject:** Three documents list item families with different names; two documents list rarity tiers with different labels (`11_INTEGRATION/PHASE00_INTEGRATION_GATE.md` §3 items 3–4).

**Ruling (canonical, for `CC.ITEM.DEFINITION` freeze):**
- **Families (6):** `Relics`, `Tools`, `Resonators`, `Companion Gear`, `Field Modules`, `Memory Collectibles` — exactly as in `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` §Item families. Already ruled in PD-002; restated here so OD-0007 has a single citation. "Resources" (from `ITEM_EQUIPMENT_PROGRESSION.md`) is **not** a family — it is the single resource of PD-004, if it exists at all.
- **Rarity labels (4):** `Utility`, `Named`, `Relic`, `Mastery` — as in `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` §Item rarity philosophy. The `NARRATIVE_ITEM_INTEGRATION.md` set (Common utility / Named artifact / Chapter relic / Mastery relic) is treated as **descriptive prose for the same four tiers**, not a second enum. Note the word "Relic" is both a family and a tier; the enum identifiers must therefore be namespaced (e.g., family vs rarity) by AI-02 so the two never share one field.

**Acceptance criteria:**
- `[VALIDATOR]` `family` enum has exactly the 6 canonical values; `rarity` enum has exactly the 4 canonical values; no free-text family/rarity anywhere.
- AI-09/AI-13: older documents (`ITEM_EQUIPMENT_PROGRESSION.md`, `ITEM_DESIGN_BIBLE.md`, `NARRATIVE_ITEM_INTEGRATION.md`) are to be annotated "superseded by PD-020 for family/rarity names" — Product does not edit them (ownership).

---

## PD-021 — Resource / currency layer in the Gold Slice (AI-13 OD-0006)

**Verdict:** APPROVED_WITH_LIMITS (refines PD-004)
**Subject:** Whether a resource exists in the Phase 06 Gold Slice; `TECHNICAL_BLUEPRINT.md` save design lists `economy`.

**Ruling:**
- The Gold Slice ships with **zero** player-visible resources. Upgrade decisions in the slice are unlocked by story/mastery/discovery only.
- `CC.RESOURCE.LEDGER` may be **defined and frozen** (so save schema is stable) but must be **empty/unused** in the slice. The save-schema `economy` field, if kept, must be optional, versioned and default-empty; it may not be a migration risk if the resource is later cut for good (PD-004 fallback).
- The single resource (≤ 1) may be introduced **only after** Phase 06 evidence shows a preparation/discovery/choice decision that story/mastery unlocks cannot express. The burden of proof is on adding it.

**Acceptance criteria:**
- `[VALIDATOR]` `11_INTEGRATION/COMPLEXITY_BUDGET.md` currency count = 0 at the Phase 06 gate.
- `[BUILD]` Gold Slice renders no resource counter (`F10-006` "no numeric progression indicator" extended to the whole slice).
- `[EVIDENCE]` Any later PD introducing the resource must cite a specific Gold Slice decision point it improves.

---

## PD-022 — Single owner for `CC.WORLD.STATE_EVENT` (AI-13 OD-0003)

**Verdict:** APPROVED
**Ruling:** Owner = **AI-02** (domain semantics). AI-13 holds versioning/registry governance, not content ownership. This matches `NARRATIVE_ITEM_CONTRACTS.md` ("AI-13 versioning and integration governance") and the single-owner rule of `ACCOUNT_MATRIX.md`. AI-02 acknowledgement is expected in its Phase 01 handoff.

**Acceptance criteria:** `[VALIDATOR]` registry entry `owner: AI-02`, `governance: AI-13`, `owner_evidence: VERIFIED` once AI-02 acknowledges.

---

## PD-023 — Asset-manifest contract owner (AI-13 OD-0004)

**Verdict:** APPROVED
**Ruling:** The asset **manifest format** (schema, required metadata per `09_ART_AUDIO/ASSET_PIPELINE.md`, versioning, integrity fields) is owned by **AI-12 (Build/Release)**, because the manifest's consumers are packaging, size budgets, placeholder-leak detection and remote-content integrity (all AI-12 concerns). Asset **IDs and entries** are produced by the asset owners (AI-05 environment, AI-06 characters/VFX, AI-08 audio) inside their own namespaces (`<type>_<system>_…` per the pipeline naming rule). AI-11 consumes memory estimates.

Rationale: the alternative (one art account owning a format the others must follow) creates a cross-art dependency and leaves audio unrepresented; packaging is the only track that reads every asset.

**Acceptance criteria:** `[VALIDATOR]` a `CC.ASSET.MANIFEST` (or AI-12-chosen `CC.BUILD.*`) registry row exists with owner AI-12, consumers {AI-05, AI-06, AI-08, AI-11, AI-13}; no second manifest format is registered.

---

## PD-024 — Speaking cast size and voice-over (AI-09 OD-02, OD-08)

**Verdict:** APPROVED_WITH_LIMITS
**Ruling:**
- **Cast:** speaking characters in Phases 00–06 are exactly Mira, Orin and Nox (non-verbal, captioned). The Weaver is silent; the Quiet Architect is a title, not a speaker. Any additional speaking character requires `IGM-005c` attachment evidence and a new PD (`CMP-012`).
- **Voice-over:** v1 is designed **unvoiced** (text + non-verbal companion audio). Full or partial VO is LATER; it must not become a Phase 06 dependency. Rationale: localization cost (`PD-012`), text-speed accessibility control (`PD-011`), and the "≤ 25 words per line" rule make written lines the safer product bet.

**Acceptance criteria:** `[VALIDATOR]` named speaking cast count ≤ 3 in narrative canon registry through Phase 06; `[VALIDATOR]` no audio contract lists VO cue families before a PD reinstates VO.

---

---

# Human Product Authority decisions — Phase 00 closure (v1.2.0)

The entries below record decisions **made by the Human Product Authority** after reviewing the Phase 00 Human Decision Brief. AI-01 is the recorder, not the decider. Wording of each decision is taken from the human instruction; AI-01 adds only the register fields (supersedes, scope, downstream impact, acceptance criteria). Verdict vocabulary extension: **HUMAN_DECIDED** — a human-gated decision that has been taken; it carries the same force as APPROVED and can only be superseded by a later human decision.

## PD-025 — Engine / technology lock (resolves AI-13 OD-0002)

**Verdict:** HUMAN_DECIDED
**Previous decision:** none in this register. `PRODUCT_LOCK_V1.md` §5 listed the engine as "STATED IN BLUEPRINT, not yet instantiated in repo"; AI-13 raised OD-0002; RISK-0001 (H/H).
**Superseding decision:** **Unity 6 + URP + Android is CONFIRMED** as the locked engine/technology direction (`02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` §Engine). The Domain/Simulation layer remains **pure C# and engine-independent** exactly as the existing architecture defines (Blueprint §Dependency rule). The Human Project Owner **provides and owns Unity licensing and the required CI/build environment before Phase 02 Bootstrap**.
**Reason:** the repository documents exactly one engine candidate across the Technical Blueprint, Account Matrix, Roadmap and all Phase 00 track notes; no alternative was proposed; code sunk cost is zero, so confirming now removes RISK-0001 ambiguity before Phase 01 contracts name runtime DTOs.
**Effective scope:** all tracks; Phase 01 onward.
**Explicitly NOT decided here:** exact Unity, URP, Android SDK/NDK/JDK versions. These are **pinned at the later technical freeze step based on verified compatibility** (AI-12 RD-004 / AI-02 project bootstrap) — no number is to be written before then.
**Downstream impact:** AI-13 closes OD-0002 and re-rates RISK-0001 (toolchain gap moves from "engine unknown" to "environment provisioning pending, owner Human"); AI-12 RD-004 remains UNKNOWN by design until pinning, RD-005 owner = Human Project Owner; AI-04 PA-04 (input package) and AI-06 particle choice and AI-08 AUD-OD-02 may proceed as Unity-scoped decisions; `PRODUCT_LOCK_V1.md` §5 engine row status becomes HUMAN_DECIDED.

**Acceptance criteria:**
- `[VALIDATOR]` No document in `01_PREPRODUCTION/PRODUCT/` states a numeric Unity/URP/SDK/NDK/JDK version (AI-01 self-check; AI-13 gate check on other tracks).
- `[VALIDATOR]` Phase 02 bootstrap PR contains a Domain assembly with zero `UnityEngine` references (Blueprint rule; owner AI-02, test owner AI-10).
- `[EVIDENCE]` Before Phase 02 kickoff, a human-provided record exists naming the Unity licence custody and CI build environment (AI-12 RD-005 closed by Human).

---

## PD-026 — Product title and `CC.` namespace independence (supersedes PD-013; resolves AI-13 OD-0005 product part; resolves AI-09 OD-01)

**Verdict:** HUMAN_DECIDED
**Supersedes:** PD-013 (DEFERRED_TO_HUMAN).
**Previous decision:** PD-013 recommended keeping "CraftCube" as working title through Phase 06 and running a title check before Phase 14, with no brand-asset spend.
**Superseding decision:**
1. **"CraftCube" is KEPT as the working/public working title for the current development phase.**
2. **No trademark clearance is claimed.** Final trademark/legal clearance **remains a required human/legal check before final commercial brand lock**.
3. **"Asterra" is INTERNAL-ONLY until legal clearance.** It must not be used as an externally committed public brand or world name. Player-facing use stays behind `loc.term.asterra` so the string can change without ID changes (AI-09 OD-01 proposal confirmed).
4. **The `CC.` contract/registry prefix is INDEPENDENT of the public product title.** No future dependency may be created in which changing the public title requires renaming the `CC.*` contract namespace. `CC.` is a stable technical namespace, not a brand reference.
**Reason:** two adjacent products already own "Cube" associations and trademark status is UNKNOWN (`COMPETITOR_REVIEW.md` §1 C3/C4, §3.2); decoupling the namespace now prevents a Phase 01 registry freeze from binding contract IDs to an uncleared name.
**Effective scope:** all tracks; immediately.
**Downstream impact:** AI-13 records `CC.` as title-independent in `11_INTEGRATION/CONTRACT_REGISTRY.md` id-format notes and closes OD-0005 (product part; legal part remains a Human/legal action); AI-09 closes OD-01 (Asterra internal); AI-12 RD-006 keeps `TBD_applicationId` until the brand lock; no logo/brand assets are commissioned before legal clearance (PD-013 recommendation carried forward).

**Acceptance criteria:**
- `[VALIDATOR]` Registry id-format documentation states the `CC.` prefix is title-independent; no contract ID embeds the word "CraftCube".
- `[VALIDATOR]` No player-facing string fixture (`loc.*`) references "Asterra" outside the `loc.term.asterra` key and its dependents; no store/marketing text in the repository uses "Asterra" (there is none today — VERIFIED).
- `[EVIDENCE]` A human/legal clearance record for the final title exists before Phase 14 store package (AI-12 Gate F precondition).

---

## PD-027 — Monetization model (supersedes PD-014)

**Verdict:** HUMAN_DECIDED
**Supersedes:** PD-014 (DEFERRED_TO_HUMAN).
**Previous decision:** PD-014 recommended designing "as if premium or free-with-single-unlock" with no monetization slots; any ads/IAP/subscription would require human approval and a new PD.
**Superseding decision:** **OPTION 1 — PREMIUM ONE-TIME PURCHASE.** Product direction, binding:
- paid upfront;
- no advertising;
- no subscription;
- no second/premium currency;
- no loot boxes / gacha;
- no energy timers;
- no paid gameplay assists;
- no dark-pattern retention monetization.
**Exact final price is NOT frozen** by this decision; it may be finalized later as a commercial/store decision. The existing anti-grind and player-respect constraints (`PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md` §5, AGP-010..017, AGP-021) **remain binding**. The rejected monetization classes (CUT-002, CUT-003, CUT-012, CUT-016, CUT-017, CUT-020) **are not reopened** unless a future Human Product Decision explicitly supersedes this one.
**Reason:** matches the audience statement (`PRODUCT_LOCK_V1.md` §4: "dislikes energy timers and forced ads"), the premium positioning of V7.1 §1, DD-009/DD-014, and requires no change to the Product Lock or to any Phase 01–06 system.
**Effective scope:** v1 release; all tracks.
**Downstream impact:** `TECHNICAL_BLUEPRINT.md` "IAP/Entitlement abstraction" is **not required for v1 gameplay** (store licence validation only; AI-02/AI-12 may keep the abstraction as a no-op seam — Product has no objection but does not require it); AI-12 RD-007 store declarations: no ads SDK, no in-app products, telemetry stance unchanged (opt-in, minimal, PD-010); PD-004/PD-021 unchanged (zero visible resources in the Gold Slice; any single resource remains gameplay-only and never purchasable); `INVESTMENT_GATE.md` Gate D "monetization hypothesis documented" is satisfied by this entry.

**Acceptance criteria:**
- `[VALIDATOR]` No contract, fixture or content definition declares a purchasable SKU, ad placement, subscription, premium currency, timer or paid assist (AI-10 lint over `CC.*` fixtures; AI-13 gate).
- `[BUILD]` Release build manifest/dependency list contains no advertising or billing SDK beyond what the store requires for a paid app (AI-12 provenance record `feature_flags` shows no IAP/ads flag).
- `[PLAYTEST]` `IGM-008`: 0% of "why come back" reasons cite a timer, reward schedule or fear of missing out (unchanged; now also enforced by monetization model).

---

## PD-028 — Story canon baseline v0.1.0 and terminology resolutions (confirms PD-017; refines PD-018; resolves AI-09 OD-01/03/04 and Product Lock §6.4 conflicts)

**Verdict:** HUMAN_DECIDED
**Previous decisions:** PD-017 approved the Story Promise at product level with canon text pending Human; PD-018 approved the finale option *set* with placeholder names; `PRODUCT_LOCK_V1.md` §6.4 reported two terminology CONFLICTS; CUT-030 held Verdant Archive as LATER pending chapter mapping.
**Superseding / resolving decision:** **Story Bible v0.1.0** (`01_PREPRODUCTION/STORY_BIBLE_V7.md` on branch `ai-09-narrative`, with its `11_NARRATIVE/` registers and fixtures) **is APPROVED as the Phase 00 canon baseline**, subject to the following explicit resolutions:

| Item | Resolution |
|---|---|
| A) Story Promise | **APPROVED as canon baseline** (text as quoted in PD-017). |
| B) S1 — Engine terminology | **ONE canonical name: "Quiet Engine."** Used consistently for the biome/chapter concept. "Quiet Engine" and "Silent Engine" are **not** retained as two competing canonical IDs for the same concept. Downstream: AI-09 renames `nar.chapter.07_silent_engine` / `loc.chapter.07.title` (currently DRAFT, not frozen — no migration needed) to the Quiet Engine form before Phase 01 freeze. |
| C) S2 — Verdant Archive | **NOT part of v1 MUST scope. LATER / deferred content.** Verdant Archive and Chapter 08 ("The Unfinished Pattern") are not required v1 biome/chapter. CUT-030 status confirmed as LATER by human decision (see `CUT_LIST_AND_COMPLEXITY_BUDGET.md` §5 log). Complexity budget: v1 biomes = **5**, v1 chapter ceiling = **9** (Act III shrinks from 3 to 2 authored chapters unless a future PD reinstates). Existing `nar.*`/`loc.*` keys for the biome/chapter may remain in the DRAFT registry marked LATER; they must not appear in any v1 critical-path prerequisite. |
| D) S3 — Asterra | **Internal-only until legal clearance** (cross-reference PD-026 §3). |
| E) S4 — Finale options | **Three-option set {Hold, Weave, Open} APPROVED as WORKING NAMES.** Final localized/public wording may be refined later **without changing the three-option structure** (PD-018 limits unchanged). |
| F) Canon boundaries approved as baseline | Story Promise; **WR-1 through WR-8**; approved cast structure (Weaver, Mira, Orin, Nox, Quiet Architect as title — PD-024); **Weaver silence / non-naming rule** (CUT-014); **memory-flag ceiling** (≤ 6 per chapter, ≤ 60 total — PD-003, CMP-007); existing approved finale structure (PD-018); **Wayfinder Shard merged into Nox** (PD-019); **v1 unvoiced cast direction** (PD-024). |

**Canon scope is NOT expanded** beyond what is already documented. Any addition is a new PD + Human canon gate.
**Reason:** removes RISK-0008 (terminology drift, H) and the phantom-biome count before `nar.*`/`loc.*` IDs become immutable in Phase 01; commits the Act III turn (WR-8) that every mystery payoff depends on.
**Effective scope:** all content tracks (AI-03, AI-05, AI-06, AI-07, AI-08, AI-09); Phase 01 freeze.
**Downstream impact:** AI-09 — set Story Bible status DRAFT → APPROVED BASELINE v0.1.0 (patch version for the S1 rename allowed), close OD-01/OD-03/OD-04, apply S1 rename, mark Verdant Archive/Ch.08 IDs LATER; AI-13 — close OD-0005 (product part) and OD-0007 already closed by PD-020; update complexity budget biomes 6→5, chapters ≤ 9; re-rate RISK-0008; AI-05 — Biome 5 presentation work is LATER (no v1 spend); AI-03 — no v1 puzzle content for Verdant Archive; AI-02 — `CC.NARRATIVE.MEMORY_FLAG` ceiling values are now human-approved and may be frozen.

**Acceptance criteria:**
- `[VALIDATOR]` Narrative canon registry contains exactly one term ID for the engine concept and no `*silent_engine*` identifier at Phase 01 freeze (owner AI-09; check AI-10).
- `[VALIDATOR]` No v1 critical-path prerequisite references Verdant Archive or `nar.chapter.08_*`; complexity budget reports biomes = 5, chapters ≤ 9.
- `[VALIDATOR]` `nar.flag.final_configuration` enum has exactly three values; display strings are behind `loc.term.hold/weave/open` keys (rename-safe).
- `[VALIDATOR]` Memory-flag counts ≤ 6 per chapter and ≤ 60 total at every gate.
- `[EVIDENCE]` Story Bible header on `integration` shows human-approved baseline status with the PD-028 reference.

---

## PD-029 — Register of decisions that remain human-gated after Phase 00 closure (informational)

**Verdict:** DEFERRED_TO_HUMAN
**Subject:** Items that PD-025..028 explicitly leave open so no track treats them as decided.
1. Final trademark/legal clearance of the public title (PD-026 §2) — before final commercial brand lock / Phase 14.
2. Legal clearance for public use of "Asterra" (PD-026 §3).
3. Exact retail price (PD-027) — commercial/store decision.
4. Exact Unity / URP / SDK / NDK / JDK versions (PD-025) — technical freeze step, not a product decision, but human-owned licensing gates it.
5. Unity licence custody and CI build environment provisioning (PD-025; AI-12 RD-005) — Human Project Owner, before Phase 02.
6. Branch protection on `integration`/`main` (AI-13 OD-0001) — repository admin.
7. Signing key custody and store-managed signing confirmation (AI-12 §7 item 3) — Phase 14.
8. Release chapter count within the new ceiling of 9 (PD-015) — Product after Gold Slice evidence, not human unless scope grows.

**Acceptance criteria:**
- `[VALIDATOR]` Each item above is either still listed here or closed by a later `PD-###`/`OD-####` record; none is silently assumed by any track.

---

## Register integrity rules

- IDs `PD-001` … `PD-016` are released with v1.0.0 of this register. `PD-017` … `PD-024` are released with v1.1.0 (Phase 00, second pass — resolving open decisions routed to AI-01 by AI-13 and AI-09). `PD-025` … `PD-029` are released with v1.2.0 (Phase 00 closure — Human Product Authority decisions recorded by AI-01). Never renumber.
- New decisions append `PD-030+`.
- Superseded entries (PD-013, PD-014, PD-017-canon-pending) keep their original text; their status is read together with the superseding entry. A `Superseded by:` line is the only in-place addition permitted.
- A verdict change is recorded as a **new** entry that supersedes the old one (`Supersedes: PD-0xx`), never an in-place rewrite.
- `validate_product_lock.py` (same folder) checks ID uniqueness and required headings; run it before any PR touching this folder.
