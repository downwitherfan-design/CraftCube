# Complexity Budget (AI-13 tracked · AI-01 approves changes)

Required by `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §16: "Track the number of currencies, item families, equipment slots, upgrade currencies/materials, quest states, world states, branching flags, dependencies, runtime systems. The default direction is to remove complexity unless its player value is demonstrated."

**Baseline = what the v7/v7.1 bibles already propose at `584141c`.** These are design proposals, not approved implementation counts. Any increase above baseline needs an `OD-`/`DD-` decision; decreases are always allowed.

| Dimension | Baseline (VERIFIED from bibles) | Source | Ceiling proposal for Gold Slice | Status |
|---|---|---|---|---|
| Currencies | **0** — "A soft-currency, hard-currency or premium-currency layer is not assumed" | V7_1 §6; DD-014 | 0 unless OD-0006 approves | OPEN (OD-0006) |
| Item families | **6** (Relics, Tools, Resonators, Companion Gear, Field Modules, Memory Collectibles) — but three docs disagree on names | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`, `ITEM_DESIGN_BIBLE.md`, `ITEM_EQUIPMENT_PROGRESSION.md` | 6, one canonical name list | OPEN (OD-0007) |
| Item rarity tiers | **4** (two label sets) | master bible; `NARRATIVE_ITEM_INTEGRATION.md` | 4, one label set | OPEN (OD-0007) |
| Equipment slots | **4 suggested** (Core Resonator, Tool, Companion Module, Field Module); exact count deferred to Vertical Slice | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` | ≤ 4 | DEFERRED to Phase 06 evidence |
| Upgrade branches per item | **4 named directions** (Precision, Versatility, Efficiency, Discovery); `ITEM_DESIGN_BIBLE.md` says "two or three per item" | both item bibles | ≤ 3 per item | Consistent (4 global, ≤3 per item) |
| Upgrade currencies/materials | **UNKNOWN** — crafting "optional and lightweight"; no material list exists | master bible §Crafting | 0 materials in Gold Slice unless a Product decision | OPEN |
| Starter item candidates | **12** (design seed, not approved) | `ITEM_CATALOG_STARTER_SET.md` | Gold Slice needs "at least one meaningful equipment decision" and "one upgrade decision" → 2–3 items | To be cut by AI-01 |
| Quest states | **6** (DISCOVERED, ACCEPTED, ACTIVE, BLOCKED optional, RESOLVED, CONSEQUENCE APPLIED) | V7_1 §4 | 6 (fixed enum) | OK |
| Quest layers | **4** (main, companion, world, discovery) | `QUEST_DISCOVERY_BIBLE_V7.md` | 4 | OK |
| World/biome state kinds | **7** (restored, unstable, discovered, mastered, story, companion, optional secret) vs **6** in `STORY_AND_WORLD_VISION.md` | `WORLD_BIOME_BIBLE_V7.md` | one enum, ≤ 7 | CONFLICT → AI-02 (gate watch-list §3.5) |
| Biome transformation tiers | **5** (Tier 0–4) | `WORLD_BIOME_BIBLE_V7.md` | 5 | OK |
| Biomes | **6** | `WORLD_BIOME_BIBLE_V7.md` | Gold Slice: 1 (Hearthwild) | OK |
| Chapters | **10** across 3 acts | `STORY_BIBLE_V7.md` | Gold Slice: 1 | OK |
| Named characters | **5** (Weaver, Mira, Orin, Nox, Quiet Architect) | `STORY_BIBLE_V7.md` | 5; Gold Slice ≤ 3 on screen | OK |
| Companions | **1** (Nox) | `STORY_BIBLE_V7.md` | 1 | OK |
| Branching narrative flags | **UNKNOWN count** — DD-013 "controlled flag set"; four scoped consequence categories listed | `STORY_BIBLE_V7.md` §Narrative choice philosophy | AI-09 must declare a hard maximum before `CC.NARRATIVE.MEMORY_FLAG` freezes (RISK-0007) | OPEN |
| Mastery metrics | **6 possible** (completion, move efficiency, assist usage, consistency, challenge, discovery) | `PROGRESSION_AND_MASTERY_BIBLE_V7.md` | ≤ 6, not collapsed to one score | OK |
| Challenge types | **8** | `PROGRESSION_AND_MASTERY_BIBLE_V7.md` | Gold Slice: 1–2 | OK |
| Discovery categories | **7** | `QUEST_DISCOVERY_BIBLE_V7.md` | Gold Slice: 1 | OK |
| Equipment effect categories | **8** (information, access, interaction, efficiency, risk management, exploration, companion synergy, puzzle strategy) | master bible | 8 (closed list; every effect declares one or more) | OK |
| Registered contracts | **27** (all DRAFT) | `registry/contract_registry.json` | Gold Slice needs a FROZEN subset — estimate 12–15; the rest deferred | Tracked by registry |
| Cross-track dependency edges | **AI-02 → 11 consumers**, AI-09 → 8, AI-03 → 7 | `DEPENDENCY_GRAPH.md` | no new reverse edges into puzzle truth | Tracked |
| Runtime systems (domain modules) | **10** listed (PuzzleTopology, PuzzleState, MoveEngine, ScrambleGenerator, Replay, Vitality, Bloom/Collapse, Synergy, Companion rules, Difficulty model) + v7 additions not yet enumerated | `TECHNICAL_BLUEPRINT.md` | AI-02 to publish the v7 module list in Phase 01; AI-13 gate rejects duplicate managers | OPEN (CR-0007) |
| Optional online services | **5** (Save, Analytics, DailySeed, Leaderboard, RemoteConfig, IAP abstraction — Save is not online) | `TECHNICAL_BLUEPRINT.md` | 0 required for offline core (DD-015) | OK |
| Accessibility settings | **10** listed | V7_1 §9 | 10; all must persist (`CC.ACCESSIBILITY.PREFERENCE`) | OK |

## Reading the table

- **OK** — count is explicit and consistent across sources; no decision needed.
- **OPEN** — count is undefined or requires a Product decision (linked OD).
- **CONFLICT** — sources disagree; the owning account must publish one enum (linked to gate watch-list).
- **DEFERRED** — bible explicitly postpones the number to Vertical Slice evidence.

## Gate rule

At each phase gate AI-13 re-counts this table from the artifacts on `integration`. Any dimension that grew without a linked decision ID fails the gate with a `CR-` to the owner. Removing complexity never fails the gate.
