# CraftCube — Progression Boundaries, Anti-Grind & Player Expression Policy

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.PROGRESSION_POLICY` |
| Version | 1.0.1 |
| Status | READY_FOR_REVIEW — Story Promise section is **canon-approved by Human decision `PD-028` §A**; monetization constraints in §5 are now backed by `PD-027` (premium one-time purchase). |
| ID family | `AGP-###` (Anti-Grind / Progression rule) and `CMP-###` (Complexity-too-high criterion). Immutable once released. Verified absent from all branches before creation. |
| Source requirements | `05_PROMPTS/phase_00/ai_01.md` §v7 phase-critical requirement; `04_AI_ACCOUNTS/AI-01_Track.md` §v7 product deliverables |
| Canonical intent sources | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` §2, §5, §8, §9, §11; `01_PREPRODUCTION/PROGRESSION_AND_MASTERY_BIBLE_V7.md`; `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`; `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §2, §5–§7, §16 |

This document completes the Phase 00 product layer that `PRODUCT_LOCK_V1.md` §Companion documents promised. It approves (or bounds) the things AI-01 must approve *before large-scale content production*: the Story Promise, the emotional fantasy, the equipment philosophy, progression boundaries, the anti-grind policy, player-expression boundaries, and the criteria for declaring narrative/item complexity too high.

Nothing here is a runtime contract. Every rule is written so AI-10 can turn it into a validator, playtest item or build check, and so AI-13 can count it at a gate.

---

## 1. Story Promise — APPROVED (product level)

AI-09 proposed the following in `01_PREPRODUCTION/STORY_BIBLE_V7.md` (branch `ai-09-narrative`, §Story promise, OD-03):

> *Every time you master the cube, the world visibly answers — and the more you understand it, the less certain you become that putting it back the way it was is the right thing to do.*

**Product verdict:** APPROVED as the Story Promise, recorded as `PD-017` in `PRODUCT_DECISION_REGISTER.md`. It is a *promise*, not a tagline; player-facing wording remains AI-09's.

Why it passes the product test:
- The first clause is the value proposition of `PRODUCT_LOCK_V1.md` §1 restated as a promise (P1 + P2).
- The second clause is the differentiator: mastery gains **moral weight**, not power. No adjacent product on the competitor list (`COMPETITOR_REVIEW.md`) makes this promise.
- It commits to exactly three verifiable things (world memory, story-by-acting, an understood choice) — all already covered by `PD-001`, `PD-006`, `F10-003`, `F10-004`, `IGM-005`, `IGM-007`.

**Product-level boundaries on the promise (binding on AI-09):**
- The "less certain" turn must be *felt before it is said*: the false lead ("back") is planted in Chapter 1 through play and Orin's certainty, never through narration explaining doubt.
- The ending is a **scoped choice** (DD-008) among a closed set with no "bad" ending; see `PD-018` for the finale option set.
- Nothing in the promise may be delivered as a mandatory text block > 40 words (`PRODUCT_LOCK_V1.md` §10).

**Human gate — CLOSED (v1.0.1):** the Human Product Authority approved the Story Promise and Story Bible v0.1.0 as the Phase 00 canon baseline in `PD-028` (with the S1–S4 terminology/scope resolutions recorded there). The Story Bible is still not *frozen* as a contract — freezing is the Phase 01 step owned by AI-09/AI-13; the boundaries above remain binding.

## 2. Emotional fantasy — LOCKED

The Game Master Bible §2 gives the core fantasy. Product locks the **emotional arc of a single session** so every track designs to the same curve. Each beat maps to a Bible §5 emotional target.

| Order | Beat | Bible §5 target | The player should be able to say… | Owning experience |
|---|---|---|---|---|
| 1 | Touch | tactile satisfaction | "It feels good in my hands." | AI-04, AI-08 |
| 2 | Read | curiosity | "There's a pattern here." | AI-03 |
| 3 | Understand | "I figured it out" | "I see how this works." | AI-03, Smart Assist (`PD-007`) |
| 4 | Answer | visible consequence | "I did that to the world." | AI-05, AI-02 |
| 5 | Notice | discovery / attachment | "Something else changed — and Nox saw it too." | AI-06, AI-05 |
| 6 | Wonder | anticipation | "Why did it do that? What's over there?" | AI-09 |
| 7 | Grow | mastery | "I can read the cube better than an hour ago." | AI-03, progression layers |

Rules:
- A session that ends without beats 1–4 is a failed session (see `IGM-002`, `IGM-007`).
- Beat 3 must be **owned by the player** even with assist (`IGM-001b`; HARD_STOP if > 30% say "the game did it").
- Beat 7 is expressed through capability, access and knowledge — never a number (`CUT-006`, `F10-006`).
- No beat is allowed to be delivered by a reward screen, a chest, a level-up banner or a currency counter.

## 3. Equipment philosophy — APPROVED WITH PRODUCT CLARIFICATIONS

The Equipment & Item Master Bible §Design target and Game Master Bible §9 are approved as written (`PD-002`). Product adds the following clarifications, which are **decision rules**, not new features:

**3.1 One sentence definition (binding):** *Equipment changes what the player can perceive, reach, risk or attempt; it never changes what is true about the cube* (restates DD-002, `PD-002`).

**3.2 The "would a puzzle master still want it?" test.** Every approved item must be useful to a player who never needs help. If an item's only value is to a struggling player, it is an assist level, not an item — route it to Smart Assist (`PD-007`) instead of the inventory.

**3.3 Sidegrade first.** Upgrades create branches with observable behavioral differences (`PD-002` limits: ≤ 3 branches × ≤ 2 steps). A branch that is "the same but more" is rejected at item-card review.

**3.4 Loadout tension is a design goal, not a punishment.** ≤ 4 active slots exist so that *choosing* is meaningful (V7.1 §5.4). Switching must be ≤ 2 taps from gameplay and free of any cost, cooldown or currency (`PD-003`).

**3.5 No item may be a critical-path key unless it is story-granted deterministically** (`PD-002` rejected list; DD-006). Items that unlock optional secrets are encouraged.

**3.6 Item memory is narrative, not stats.** Where an item remembers (first-found location, chapter — `CUT-027`), it remembers *story*, never kill counts, usage counts or efficiency scores.

## 4. Progression boundaries

Progression is the four-layer model of the Progression Bible — **Knowledge → Capability → Access → Mastery** — and nothing else. Product boundaries:

| ID | Boundary | Measurable form | Check type |
|---|---|---|---|
| AGP-001 | No single player level, XP bar or aggregate score exists anywhere in the product. | Zero `level`, `xp`, `score` progression indicators rendered in any player-facing screen; mastery displayed only as per-dimension facts. | `[BUILD]` AI-07 screen inventory; `[VALIDATOR]` no progression contract field named as an aggregate player level |
| AGP-002 | Critical-path progression is gated by **understanding** (solving) only — never by time, resource totals, bond level, collection count or discovery count. | Every critical-path prerequisite references a solved puzzle state or a story-granted deterministic item. | `[VALIDATOR]` on chapter/quest prerequisite data |
| AGP-003 | Difficulty rises through pattern complexity and decision quality before speed. No timer on the critical path (`CUT-015`). | Zero timed critical-path puzzles. | `[VALIDATOR]` |
| AGP-004 | Every Capability (item, companion ability) must open ≥ 1 new interaction or discovery within the same chapter it is acquired. | For each capability, a same-chapter use site exists in content data. | `[VALIDATOR]` AI-03 content |
| AGP-005 | Access (a new biome/route) is always earned by a visible world change the player caused, never by a menu unlock. | Every biome/route unlock references a `CC.WORLD.STATE_EVENT` produced by a solve. | `[VALIDATOR]` once contract is FROZEN |
| AGP-006 | Mastery is multi-dimensional and optional. Standard solve is MUST; other challenge types are `PD-009` DEFERRED_TO_EVIDENCE. | Challenge type count in the Gold Slice ≤ 2. | `[VALIDATOR]` complexity budget |
| AGP-007 | Progression is fully recoverable: any interruption loses at most the in-progress twist. | 100% state recovery in `IGM-006c`. | `[BUILD]` |

## 5. Anti-grind policy

"Grind" is defined for CraftCube as: **any repetition the player performs for a progression reason without gaining new understanding, new capability, new access or new story.**

| ID | Rule | Measurable form | Check type |
|---|---|---|---|
| AGP-010 | No repeatable activity may award progression-relevant value more than once for the same understanding. Replaying a solved puzzle is allowed for mastery/challenge value only (`PD-009`). | Reward definitions for re-solves contain only mastery-dimension records, never items, resources or story flags. | `[VALIDATOR]` `CC.REWARD.DEFINITION` |
| AGP-011 | No wait timers, energy, stamina, cooldown-to-progress, daily-login or streak mechanics (`CUT-002`, `CUT-017`). | Zero time-based gates in content or runtime configuration. | `[VALIDATOR]`, `[BUILD]` airplane-mode + clock-change test |
| AGP-012 | If the single resource exists (`PD-004`), its full chapter supply is reachable by completing that chapter's authored content once. No farming loop may exist. | Per chapter: deterministic source total ≥ sum of all sinks introduced in that chapter. | `[VALIDATOR]` `CC.RESOURCE.LEDGER` |
| AGP-013 | Companion bond advances only through authored shared moments; never by repeatable gifting, petting, feeding or proximity time (`CUT-011`). | Bond triggers reference only authored story/puzzle/discovery events. | `[VALIDATOR]` `CC.COMPANION.REACTION` |
| AGP-014 | Collection (Memory Collectibles) is optional and finite (≤ 30) and is never a prerequisite for anything on the critical path. | No critical-path prerequisite references a collectible count. | `[VALIDATOR]` |
| AGP-015 | Forced revisiting is forbidden. A revisit is legitimate only when a new capability creates a genuinely different interaction or reveals a secret (Progression Bible §Revisit design). | Every authored revisit names the new capability or secret it exposes. | `[VALIDATOR]` AI-03 content notes |
| AGP-016 | Failure never destroys progress, items or resources (V7.1 §6 "no irreversible economic damage"; `CUT-009`). | Zero failure handlers that remove owned items/resources or regress world state. | `[VALIDATOR]`, `[BUILD]` |
| AGP-017 | Playtest signal: in exit interviews, 0% of "why would you come back" answers may cite a timer, streak, reward schedule or fear of missing out (`IGM-008`). | Coded exit answers. | `[PLAYTEST]` |

Product will treat any `AGP-01x` violation found at a gate as a **cut**, not as a balancing task.

**Monetization backing (v1.0.1):** `PD-027` fixes the model as premium one-time purchase with no ads, subscription, second/premium currency, loot boxes, timers, paid assists or dark-pattern retention. AGP-011, AGP-012, AGP-016, AGP-017 and AGP-021 are therefore not only design rules but consequences of the monetization decision; reopening any of them requires a Human decision superseding `PD-027`.

## 6. Player-expression boundaries

Expression is Bible §3 layer 6 — the second-lowest protected layer. It is welcome only where it costs no clarity, no capacity and no identity.

**Approved for v1 (SHOULD-tier, `CUT-031`, promotion only with complexity headroom at Phase 09):**
- Earned cube face patterns / materials (visual only; tile identity must remain readable through ≥ 2 channels — `PD-011`).
- Companion accents (colour/pattern on Nox; no behavior change).
- Restored-area visual variants tied to *how* an area was restored (this is world memory, already approved via `PD-006`; the expression value is a by-product).
- The **order** in which the player restores the world (the `F10-005` choice) is the primary form of expression at v1 and requires no cosmetic system at all.

**Boundaries (binding):**
| ID | Boundary |
|---|---|
| AGP-020 | Expression never changes puzzle rules, readability, solvability, hints or difficulty. |
| AGP-021 | Expression is **earned by mastery, discovery or story only** — never bought, never randomized, never time-limited (`CUT-003`, `CUT-017`, `CUT-020`). |
| AGP-022 | No avatar creator, protagonist customization, name entry or voice selection in v1 (`CUT-014`). |
| AGP-023 | Expression adds **zero** new top-level menus (`PD-003` cap of 4). Cosmetic selection, if it ships, lives inside Loadout or Journal. |
| AGP-024 | Expression content is the first thing cut when capacity is exceeded (`CUT_LIST_AND_COMPLEXITY_BUDGET.md` §4 step 1). |
| AGP-025 | Expression must be localization- and accessibility-neutral: no text-bearing cosmetics; every cosmetic passes the colour-independence rule. |

## 7. Narrative / gameplay balance rules

These rules decide conflicts between AI-09 (meaning) and AI-03 / AI-04 (play) before they reach AI-13:

1. **Play first, words second.** If a beat can be delivered by a world change, it is not delivered by dialogue. If it needs dialogue, one line (≤ 25 words) precedes any second line.
2. **Story never pauses the hands.** No narrative moment interrupts an in-progress twist. Beats trigger on solve completion, arrival, or discovery — never mid-manipulation.
3. **Characters react to what the player *did*, not what the player *is*.** Memory flags (≤ 6 per chapter) record actions and orders, not personality choices (DD-013).
4. **The cube is never a cutscene prop.** Every on-screen cube interaction is real player input into the real simulation.
5. **Optional depth is opt-in.** Memory Collectibles, journal entries and lore are reachable ≤ 1 tap from where they are found and never open automatically (`F10` "no forced menu").
6. **Budget arbitration:** when AI-09 and AI-03 disagree on pacing, the tiebreaker is the mandatory-text budget (≤ 40 words pre-first-solve; ≤ 120 words in minutes 0–10) and the causality latency (≤ 2 s). Whichever proposal respects both wins; if both do, the one with fewer words wins.

## 8. Criteria for "narrative / item complexity is too high"

Product declares complexity too high — and cuts, merges or simplifies **without re-litigation** — when any criterion below is met. Each has a measurable trigger and a default action. AI-13 re-counts the numeric ones at every gate (`11_INTEGRATION/COMPLEXITY_BUDGET.md`).

| ID | Criterion | Trigger | Default action |
|---|---|---|---|
| CMP-001 | **Explanation test fails.** A feature cannot be explained to a new player in one sentence of ≤ 20 words without naming another system. | Written one-sentence explanation exceeds 20 words or references ≥ 2 other systems. | Merge into the referenced system or cut. |
| CMP-002 | **Recall test fails.** In a Gold Slice exit interview, < 30% of players can recall the feature existed. | `IGM` playtest coding. | Cut or fold into a remembered feature (V7.1 §18). |
| CMP-003 | **Duplicate semantic responsibility.** Two items, systems or characters answer the same player question ("how do I find secrets?", "how do I see the past?"). | Anti-duplication search finds ≥ 2 owners for one player-facing purpose. | Merge (precedent: Wayfinder Shard → Nox, `PD-019`). |
| CMP-004 | **Menu depth exceeded.** Any player action requires > 2 taps from gameplay, or a fifth top-level menu is proposed. | `PD-003` caps. | Reject the screen; redesign in-world. |
| CMP-005 | **Text budget exceeded.** Mandatory text > 40 words pre-first-solve, > 120 words in minutes 0–10, or any single node > 40 words. | AI-09 node data. | Cut words; move content to optional Journal. |
| CMP-006 | **Item card cannot be completed honestly.** An item's identity card (V7.1 §5.1) has an empty or tautological "puzzle/world interaction" or fails the Bible §9 two-answer test. | `[VALIDATOR]` on item cards. | Reject item. |
| CMP-007 | **Flag budget exceeded.** > 6 narrative memory flags in a chapter, or > 60 at v1, or any flag read by zero downstream consumers. | `CC.NARRATIVE.MEMORY_FLAG` count and consumer map. | Cut unread flags first, then merge. |
| CMP-008 | **Branch explosion.** Any narrative node has > 3 flag-dependent variants, or any chapter has > 1 flag-dependent structural difference (as opposed to presentation differences). | AI-09 beat map. | Reduce to presentation variance (DD-008). |
| CMP-009 | **Contract fan-out.** A single new feature requires changes to > 3 `CC.*` contracts or introduces a new reverse dependency into puzzle truth. | `11_INTEGRATION/DEPENDENCY_GRAPH.md`. | Defer to LATER; re-scope. |
| CMP-010 | **Spreadsheet economy.** Any resource, upgrade or synergy decision requires the player to compare > 2 numbers, or the team needs a balance sheet to explain it. | Design review. | Convert to a binary/behavioral choice or cut (V7.1 §6). |
| CMP-011 | **Onboarding inflation.** A feature needs its own tutorial step, pushing onboarding above 5 steps before free play. | AI-07 onboarding spec. | Introduce after minute 10 or cut. |
| CMP-012 | **Cast inflation.** A speaking character is proposed beyond Mira, Orin and Nox before Gold Slice attachment evidence exists (AI-09 OD-02). | Named speaking cast > 3 (Weaver is silent; Quiet Architect is a title, not a speaker). | Reject until `IGM-005c` evidence. |

**Escalation rule:** a `CMP` trigger met on a MUST-scope feature is not a reason to lower the bar — it is a reason to redesign the feature simpler (`QUALITY_INVESTMENT_RULES.md` §10). Only Human Product Authority may accept a met `CMP` trigger as a known risk.

## 9. Consumption notes for downstream tracks

- **AI-02:** `AGP-002`, `AGP-005`, `AGP-012`, `AGP-016` become invariants on state/reward/ledger contracts; `AGP-001` forbids any aggregate-level field in `CC.SAVE.SCHEMA` player progression.
- **AI-03:** `AGP-004`, `AGP-010`, `AGP-015` are content-authoring rules; `CMP-006` is the item-card gate; `AGP-006` caps Gold Slice challenge types at 2.
- **AI-06:** `AGP-013` bounds companion bond triggers; `CMP-003` precedent (Nox owns "sensing direction to secrets").
- **AI-07:** `AGP-001`, `AGP-023`, `CMP-004`, `CMP-011` are UX acceptance criteria; expression lives inside existing menus.
- **AI-09:** §1 boundaries, §7 rules 1–5, `CMP-005`, `CMP-007`, `CMP-008`, `CMP-012`.
- **AI-10:** every `AGP-###`/`CMP-###` row names its check type; add them to the traceability register alongside `F10`/`IGM`/`PD`.
- **AI-13:** `AGP-###` and `CMP-###` are new stable ID families owned by AI-01; please register alongside `PD/F10/IGM/CUT`. `CMP-001..012` are the "too complex" test the complexity budget should cite for its over-cap action column.

## 10. Change control

Adding a rule → append a new `AGP-`/`CMP-` ID, patch version. Weakening any rule → new `PD-###` with evidence and minor version. Removing §1 approval or §2 arc → Human Product Authority gate.
