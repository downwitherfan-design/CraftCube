# CraftCube — Product Decision Register (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.DECISIONS` |
| Version | 1.0.0 |
| ID family | `PD-###` (Product Decision). Immutable once released. Never reuse a number. |
| Relationship to `DD-###` | `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` holds *starting design decisions*. `PD-###` records Product's **approve / reject / defer** verdicts on them and on the v7 bibles, with testable acceptance criteria. `PD` entries cite the `DD` they confirm; they never duplicate a `DD`. |

## Verdict vocabulary

- **APPROVED** — Product accepts; acceptance criteria below become required tests/evidence for the owning track.
- **APPROVED_WITH_LIMITS** — Accepted only inside the stated bounds.
- **REJECTED** — Not to be built; listed in the Cut List.
- **DEFERRED_TO_HUMAN** — Touches a human approval gate (`00_CONTROL/13_AI_EXECUTION_MANUAL.md` §Human approval gates). Product recommendation recorded; no track may act as if decided.
- **DEFERRED_TO_EVIDENCE** — Decision waits for a named phase gate's measured evidence.

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

**Open items for AI-09 (not blocking approval):** "Quiet Engine" vs "Silent Engine" naming conflict; "Verdant Archive" biome lacks a chapter mapping (see `PRODUCT_LOCK_V1.md` §6.4).

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
**Product recommendation:** keep **CraftCube** as the working title through Phase 06; run a title check (trademark/store-name availability) before Phase 14. Do not spend on logo/brand assets before the human decision.

---

## PD-014 — Monetization model

**Verdict:** DEFERRED_TO_HUMAN
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

## Register integrity rules

- IDs `PD-001` … `PD-016` are released with v1.0.0 of this register. Never renumber.
- New decisions append `PD-017+`.
- A verdict change is recorded as a **new** entry that supersedes the old one (`Supersedes: PD-0xx`), never an in-place rewrite.
- `validate_product_lock.py` (same folder) checks ID uniqueness and required headings; run it before any PR touching this folder.
