# CraftCube — Hard Cut List & Complexity Budget

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.CUTLIST` |
| Version | 1.1.0 |
| ID family | `CUT-###`. Immutable once released. A cut item is never deleted from this file; if reinstated, its status changes and a new `PD-###` is cited. |
| Source requirements | Phase 00 prompt ("Maintain a hard CUT LIST"), `INVESTMENT_GATE.md` Gate D, `V7_1_WORLDCLASS_UPGRADE.md` §16 complexity budget, `13_AI_EXECUTION_MANUAL.md` human gates |

## How to use this file

1. **Before proposing any feature**, search this file. If it is `REJECT`, do not build it; open a `PD` request if you believe evidence has changed.
2. **Before any phase gate**, AI-13 compares the complexity counters in §3 against the caps. Over cap = gate fails until Product cuts something.
3. **Scope only shrinks silently; it never grows silently.** Adding to MUST requires a `PD-###`. Moving MUST → SHOULD/LATER can be done by Product alone and is logged here.

## Status vocabulary

- **REJECT** — will not be built for v1; reinstatement requires new `PD` + (where applicable) human approval.
- **LATER** — desirable, not v1; no track spends on it before Product re-approves.
- **CUT_IF_OVER_BUDGET** — in scope, but named as the *first* thing removed when capacity or complexity is exceeded, in the order listed.
- **REINSTATED** — previously cut, now approved via a cited `PD`.

---

## 1. Rejected feature classes (`REJECT`)

| ID | Feature | Why rejected | Pillar/decision violated | Reinstatement gate |
|---|---|---|---|---|
| CUT-001 | Online-required core (accounts, always-on connection, server-authoritative progress) | Core must be offline (DD-015). | P1, PD-010 | Human + new PD |
| CUT-002 | Energy / stamina / wait timers of any kind | Dark-pattern dependency; contradicts healthy retention (DD-009). | P5, Bible §11 | Human (monetization gate) |
| CUT-003 | Loot boxes, gacha, randomized paid or mandatory rewards | Progression must never depend on luck (DD-006); gambling adjacency. | P4, PD-002 | Human (monetization gate) |
| CUT-004 | Second (or more) companion in v1 | One well-authored companion beats two shallow ones (DD-011). | P5, PD-005 | PD after Gold Slice recall data (IGM-005c) |
| CUT-005 | Combat system, health, damage, enemies-as-combat, companion combat | Generic-RPG drift (Bible §12; DD-007). | P1, P4 | Human (identity change) |
| CUT-006 | Player level / XP bar / single mastery score | Progression is multi-dimensional (Progression Bible); numbers-first contradicts F10-006. | P4, PD-003 | New PD |
| CUT-007 | Block-building / sandbox construction / terrain editing | Minecraft-clone drift; IP-risk adjacency. | Bible §1, §12 | Human (identity change) |
| CUT-008 | Player-vs-player, guilds, chat, social graph | Out of audience; online dependency; moderation cost. | PD-010 | Human |
| CUT-009 | Durability that breaks or destroys items | Punitive, no decision value (Equipment Bible §Durability). | P4 | New PD |
| CUT-010 | Crafting tree / recipe system (beyond one lightweight combine) | Resource-sink bloat (V7.1 §5.5). | P5, PD-002 | New PD after Gold Slice |
| CUT-011 | Repeatable gift-giving / affection-grinding for companion bond | Bond by shared experience only (V7.1 §3.2). | P5, PD-005 | New PD |
| CUT-012 | Second player-visible currency, premium/hard currency, currency store | DD-014; monetization slot. | P4, PD-004, PD-014 | Human (monetization gate) |
| CUT-013 | Open-ended branching narrative trees / multiple full endings requiring separate content | Branch explosion (DD-008). Finale *nuance* via memory flags is allowed. | P3, P5, PD-001 | Human (canon change) |
| CUT-014 | Voiced, named, customizable protagonist with avatar creator | Story Bible keeps the Weaver lightly defined; avatar systems are collection/menu bloat. | P3, PD-001 | New PD |
| CUT-015 | Timed critical-path puzzles | Understanding before speed; accessibility. | P1, PD-011 | New PD (optional challenge variants are separate — see PD-009) |
| CUT-016 | Paid or ad-gated Smart Assist / hints | Assist protects clarity, never monetized (PD-007). | P1 | Human (monetization gate) |
| CUT-017 | Daily-login rewards, streak bonuses, FOMO events | Dark pattern (DD-009). Deterministic *daily seed challenge* without streak/loss is separately LATER. | P5 | Human |
| CUT-018 | Real-time multiplayer or co-op cube solving | Online core; input latency; out of audience. | PD-010 | Human |
| CUT-019 | Procedurally generated biomes/story | Authored coherence over quantity (DD-011, V7.1 §2.1). Deterministic *puzzle scrambles* are not affected. | P5 | New PD |
| CUT-020 | Cosmetic item shop or paid skins at v1 | Monetization direction undecided (PD-014); expression must first prove value via earned cosmetics. | P4, PD-014 | Human |

## 2. Later (`LATER`)

| ID | Feature | Condition to promote |
|---|---|---|
| CUT-021 | Tablet / landscape layouts | After Phase 11 UX polish; AI-07 capacity |
| CUT-022 | iOS build | Post-v1 release decision (human) |
| CUT-023 | Leaderboards / competitive results with trust levels | Phase 13; requires PD + `CompetitiveResult` contract; local-best only before that |
| CUT-024 | Remote content packs | Phase 13+; `RemoteContentManifest` contract; must fail closed |
| CUT-025 | Deterministic daily seed challenge (offline-capable, no streaks) | After PD-009 evidence (≥ 30% voluntary replay) |
| CUT-026 | Challenge variants: Time, World-state, Resonance, Discovery, Companion | PD-009 evidence |
| CUT-027 | Item memory (first-found location, chapter of acquisition) | Cheap if `ItemIdentity` contract carries the fields; promote once AI-02 confirms save cost |
| CUT-028 | Companion bond progression beyond first capability | After IGM-005c |
| CUT-029 | Set synergy beyond 3 named combinations | After Gold Slice equipment data |
| CUT-030 | Verdant Archive biome + chapter (AI-09 draft Ch.08 "The Unfinished Pattern") | **LATER confirmed by Human decision `PD-028` §C** — not v1 MUST scope regardless of the chapter mapping now present in the AI-09 draft. Promotion requires a new PD + Human canon/scope approval. |
| CUT-031 | Earned (non-paid) cosmetic expression: cube face patterns, companion accents, restored-area visual variants | SHOULD-tier at Phase 09 if complexity budget has headroom; see `PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md` |

## 3. Complexity budget (hard caps, v1)

Counters AI-13 reports at each gate. Sources are named so the count is reproducible, not estimated.

| Dimension | Cap | Counting source (once contracts exist) | Over-cap action |
|---|---|---|---|
| Player-visible currencies/resources | 1 | `ResourceLedger` definitions | Cut resource (PD-004 fallback) |
| Item families | 6 | `ItemDefinition.family` enum | Merge families |
| Equipment/relic items (non-collectible) | 12 | `EquipmentDefinition` + Relic `ItemDefinition` count | Cut lowest-scoring item by Bible §9 test |
| Memory Collectibles | 30 | `ItemDefinition.family == MemoryCollectible` | Cut |
| Active equipment slots | 4 | loadout schema | Cut slot |
| Upgrade branches per item | 3 | `UpgradeDefinition` | Cut branch |
| Upgrade steps per branch | 2 | `UpgradeDefinition` | Cut step |
| Upgrade materials beyond the single resource | 0 | `UpgradeDefinition` cost refs | Reject |
| Named set synergies | 3 | affinity/synergy table | Cut |
| Affinity matrix | 12 items × 6 biomes | `CC.PUZZLE.AFFINITY` | Cut rows |
| Quest states | 6 | `QuestState` enum | Reject new state |
| Active quests visible at once | 3 | quest UX | Hide/serialize |
| World-state tiers per biome | 5 | `WorldState`/`BiomeState` | Reject |
| Narrative memory flags per chapter | 6 | `NarrativeMemoryFlag` per chapter | Cut flag |
| Total narrative memory flags at v1 | 60 | same | Cut |
| Companions | 1 | `CompanionReaction` owners | Reject |
| Biomes at v1 | **5** (Verdant Archive LATER — `PD-028` §C) | `BiomeState` definitions | Cut biome |
| Chapters at v1 | **≤ 9** (min 3 = Act I; Ch.08 LATER — `PD-028` §C); exact via PD-015 | `CC.NARRATIVE.CHAPTER` | Cut from Act III backward |
| Monetization surfaces (ads, IAP SKUs beyond the store purchase, subscriptions, premium currency, timers, paid assists) | **0** (`PD-027` premium one-time purchase) | AI-12 build flags / dependency list; `CC.*` fixtures | Reject |
| Top-level player menus (excl. Settings) | 4 | AI-07 screen inventory | Merge |
| Onboarding steps before free play | 5 | AI-07 onboarding spec | Cut |
| Mandatory pre-first-solve text | 40 words | AI-09 narrative nodes | Cut text |
| Mandatory text, minutes 0–10 | 120 words | AI-09 narrative nodes | Cut text |
| Runtime systems requiring network | 0 | AI-12/AI-13 dependency graph | Reject |

## 4. Cut order when capacity is exceeded (`CUT_IF_OVER_BUDGET`)

If Phase 06–10 production cannot deliver the MUST scope at the quality bar, Product cuts in **this order**, without re-litigation:

1. `CUT-031` earned cosmetics (if promoted) → back to LATER.
2. `CUT-029` set synergies → reduce to 1.
3. `CUT-027` item memory fields.
4. `CUT-026`/`CUT-025` challenge variants and daily seed.
5. The single resource (`PD-004`) → unlock upgrades by story/mastery only.
6. Upgrade branches → reduce to 1 branch × 1 step per item.
7. Equipment items → from 12 down to **6** minimum (one per family that remains meaningful).
8. Act III chapters → from 3 down to 1 (finale must remain).
9. Act II chapters → from 4 down to 2 (one must be Glassroot, which teaches world memory).
10. **Never cut:** Act I (3 chapters), Nox, world causality, save/recovery, offline core, accessibility baseline, Smart Assist.

The "never cut" line is the minimum viable CraftCube. If even that cannot be reached at quality, the correct action is to **expand the phase, not lower the bar** (`QUALITY_INVESTMENT_RULES.md` §10) — and escalate to the Human Product Authority.

## 5. Scope growth log

Any change to §1–§4 is appended here with date, `PD` reference and direction (grow/shrink).

| Date | Change | Direction | PD ref |
|---|---|---|---|
| Phase 00 | Initial cut list v1.0.0 | — | PD-016 |
| Phase 00 closure | CUT-030 Verdant Archive: LATER **confirmed by Human**; v1 biomes 6→5, chapter ceiling 10→9 | shrink | PD-028 §C |
| Phase 00 closure | Monetization model fixed: premium one-time purchase; CUT-002/003/012/016/017/020 reinstatement now requires a Human decision **superseding PD-027**, not merely "Human (monetization gate)" | no growth (hardened) | PD-027 |
| Phase 00 closure | Engine confirmed Unity 6 + URP + Android; no scope change | — | PD-025 |
| Phase 00 closure (v1.3.0) | Engine **re-confirmed to Godot 4.x stable + GDScript + Android-first**, superseding PD-025 per the owner directive (CR-0013); no scope change | — | PD-030 |
