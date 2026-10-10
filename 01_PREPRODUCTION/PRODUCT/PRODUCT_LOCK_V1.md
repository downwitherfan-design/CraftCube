# CraftCube — Product Lock v1.0.0 (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.LOCK` |
| Version | 1.1.0 |
| Status | READY_FOR_REVIEW — Human Product Authority decisions for engine, title/namespace, monetization and canon are RECORDED (PD-025..PD-028; engine re-confirmed to Godot by PD-030). Remaining human items are listed in §11 / PD-029. Integration gate verdict is AI-13's. |
| Phase | 00 — Product/IP Lock |
| Supersedes | nothing (first product lock) |
| Canonical intent source | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` |

This document is the **product truth** for CraftCube. It does not restate the Game Master Bible; it locks the decisions the Bible leaves open, adds measurable boundaries, and names what is out of scope. Where this document and the Bible disagree, that is a defect — file a conflict, do not guess.

Companion documents (same folder):
- `PRODUCT_DECISION_REGISTER.md` — every approve/reject decision with acceptance criteria (`PD-###`).
- `FIRST_10_MINUTES_PROOF.md` — what the first session must prove (`F10-###`).
- `INVESTMENT_GATE_METRICS.md` — measurable gate thresholds (`IGM-###`).
- `CUT_LIST_AND_COMPLEXITY_BUDGET.md` — hard cut list and complexity caps (`CUT-###`).
- `PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md` — progression boundaries, anti-grind, player expression.

---

## 1. One-sentence value proposition

**CraftCube is a mobile puzzle-adventure where mastering a twisting cube is the language you use to repair a living world — and the world visibly answers every solve.**

Test: a new player must be able to repeat the gist of this sentence unprompted after the first session (see `F10-006`).

## 2. Thirty-second loop explanation (player-facing wording)

> You find a broken cube that reacts to your hands. Twisting it into the right pattern wakes up part of the world — a path grows, water flows, a machine turns. Each place you fix reveals more of a mystery about why the world broke. Along the way you find a few special tools that let you see or reach things you couldn't before, and a small creature who notices things you miss. The better you get at reading the cube, the more of the world you can bring back — and the more you learn about whether "back" is even the right answer.

## 3. Product pillars (ranked, immutable order)

The Game Master Bible §3 defines the protected hierarchy. Product converts it into five pillars with a rank that decides every trade-off:

| Rank | Pillar | One-line test | Fails if… |
|---|---|---|---|
| P1 | **Puzzle Mastery is the skill** | The game is still fun with story/items/companion disabled (DD-001). | Any system lets a player progress the critical path without improving at the cube. |
| P2 | **Every solve changes the world** | A player can point at something in the world and say "I did that." | A puzzle completes and the world does not visibly react within ~2 seconds. |
| P3 | **Mystery pulls, lore never pushes** | Each chapter ends with a stronger question than it started with. | Any mandatory text block exceeds ~40 words or any cutscene exceeds ~20 seconds before the first solve. |
| P4 | **Tools change how you think, not how big your number is** | Every equipment piece answers ≥2 Bible §9 questions. | Any item exists whose only effect is a scalar buff. |
| P5 | **Fewer, memorable, connected** | A player recalls at least one place, one character and one tool a week later. | Content count rises while recall/coherence metrics fall. |

Lower pillars never override higher ones. A change that improves P4 but weakens P1 is rejected by default.

## 4. Target audience

**Primary:** adults 18–45 who enjoy thoughtful mobile puzzle games with atmosphere and progression (reference behaviors: finishes puzzle chapters over several evenings; values "aha" over speed; plays 5–20 minute sessions; dislikes energy timers and forced ads).

**Secondary:** twisting-puzzle enthusiasts (physical cube solvers) who want a reason to apply their skill inside a world; and adventure-narrative fans who accept puzzle challenge if it is fair and readable.

**Explicitly not designed for:** players seeking competitive PvP, idle/clicker loops, gacha collection, block-building sandboxes, or sub-2-minute hyper-casual sessions.

Design consequences:
- Session length target: a meaningful unit of progress (one solve + one world reaction) completes in ≤ 5 minutes; a chapter beat in ≤ 20 minutes.
- Interruption safety: any interruption (call, background, low battery) must lose at most the current unfinished solve, never world/story/item state.
- Difficulty: understanding before speed (Progression Bible §Difficulty curve). No timer on critical-path puzzles.

## 5. Platform assumptions (ASSUMED until measured — owners named)

| Assumption | Value | Owner to verify | Status |
|---|---|---|---|
| Primary platform | Android phones, portrait-first | AI-04 / AI-11 | ASSUMED |
| Engine | Godot 4.x stable + GDScript, Android-first (per `PD-030`, superseding `PD-025`); Domain/Simulation pure and engine-independent (no Node/SceneTree dependencies) | Human Project Owner (build/toolchain environment before Phase 02) / AI-02 / AI-12 | **HUMAN_DECIDED (PD-030).** Exact Godot/Android SDK/NDK/JDK versions deliberately NOT pinned until the technical freeze step. |
| Device tiers | low / mid / high defined by AI-11 device matrix | AI-11 | MISSING (no matrix in repo yet) |
| Frame targets | 60 FPS mid-tier target, 30 FPS safe mode (Blueprint hypothesis) | AI-11 | HYPOTHESIS |
| Offline | Entire critical path playable with no network (DD-015) | AI-02 / AI-12 | PRODUCT REQUIREMENT |
| Input | One-hand touch usable for the cube; two-hand allowed for camera | AI-04 / AI-07 | PRODUCT REQUIREMENT |
| Tablet / landscape | Supported later; not a Phase 00–06 requirement | AI-07 | LATER |
| iOS | Not in scope before release candidate | — | REJECT for v1 scope |

Product does not fabricate device names or performance numbers. Numbers become real only when AI-11 publishes measured evidence.

## 6. IP-safe direction and terminology policy

### 6.1 Non-negotiable IP rule
CraftCube is an **original IP**. It must not use, reference, imitate or depend on Minecraft or any other proprietary franchise's names, creatures, textures, UI, sounds, terminology or progression patterns (`10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md`). Mechanical ideas from the source GDD (twisting cube, biome causality, Vitality/Bloom/Collapse, companions, Smart Assist, Pulse/Trail) are retained; all proprietary dressing is discarded.

### 6.2 Terminology ownership
- **AI-09 owns** canon names, lore terminology and localization keys.
- **AI-01 owns** the *policy* below and the approval of the product-facing title and top-level nouns.

### 6.3 Product-approved top-level nouns (v1.0.0)
These are approved for use across all tracks as **design vocabulary**. They are not localization keys and not stable content IDs; AI-09 issues those.

| Concept | Approved term | Rejected / avoid |
|---|---|---|
| Game title | **CraftCube** (working/public working title for the current development phase — `PD-026`; trademark clearance NOT claimed; final brand lock requires human/legal check) | — |
| World | **Asterra** — **INTERNAL-ONLY until legal clearance (`PD-026` §3, `PD-028` §D)**; player-facing use only via `loc.term.asterra` | any real-world or franchise place name; any external/marketing use of "Asterra" before clearance |
| Central mechanism | **the Axis Loom** / "the Loom" | "core", "matrix", "nexus" (generic) |
| Catastrophe | **the Great Misalignment** | "the Fall", "the Cataclysm" (generic) |
| Player role | **Weaver** | "hero", "chosen one", "miner", "crafter" |
| Puzzle object | **the cube** (lowercase, player-facing) | "Rubik", "magic cube", "speedcube" |
| Solve consequence | **restoration** / "the world answers" | "loot", "drop", "XP" |
| Companion #1 | **Nox** | any franchise creature name |
| Biomes (v1) | Hearthwild, Glassroot, Sunken Grid, Ember Hollow, **The Quiet Engine** (single canonical name — `PD-028` §B) | block/ore/mob names; "Silent Engine" as a competing canonical ID |
| Biome (LATER, not v1) | Verdant Archive (`PD-028` §C, CUT-030) | treating it as a required v1 biome/chapter |
| Contract namespace | **`CC.`** — stable technical prefix, **independent of the public title** (`PD-026` §4) | any contract ID that embeds the product name |
| Item families | Relics, Tools, Resonators, Companion Gear, Field Modules, Memory Collectibles (Equipment Bible §Item families) | "weapons", "armor", "gear score" |
| Assist feature | **Smart Assist** (retained from source GDD as a mechanic name) | "auto-solve", "cheat" |

Any track that needs a term not on this list uses a clearly-labeled placeholder (`TBD_<concept>`) and files a request to AI-09.

### 6.4 Terminology CONFLICTS — RESOLVED by Human decision (PD-028), v1.1.0
- **Quiet Engine / Silent Engine** — RESOLVED: one canonical name, **"Quiet Engine"**, for the biome/chapter concept (`PD-028` §B). AI-09 applies the rename to the DRAFT chapter-07 identifiers before Phase 01 freeze. *(Original v1.0.0 report: `WORLD_BIOME_BIBLE_V7.md` Biome 6 "The Quiet Engine" vs `STORY_BIBLE_V7.md` Chapter 7 "The Silent Engine".)*
- **Verdant Archive** — RESOLVED: **LATER / deferred content, not v1 MUST** (`PD-028` §C; CUT-030). AI-09's draft Chapter 08 mapping is retained as LATER design, not v1 scope. *(Original v1.0.0 report: Biome 5 had no chapter mapping on `main`.)*

## 7. Scope boundaries for v1 (release target)

### 7.1 In scope (MUST)
- One complete three-act story spine (Story Bible acts I–III), delivered through play, with **Act I fully authored and Acts II–III authored at the depth the Content Production phases can afford**. Chapter count is capped by `CUT_LIST_AND_COMPLEXITY_BUDGET.md`.
- Twisting-cube puzzle core with deterministic simulation, undo/redo, scramble, replay (Blueprint).
- World causality: every critical-path solve triggers a persistent, visible world state change.
- **One** companion (Nox) with sensing/reaction/discovery role (DD-007).
- A small equipment layer: ≤ 4 active slots, ≤ 12 meaningful equipment/relic items at release (see budget). Puzzle Affinity as a data layer.
- Upgrade branches (not level ladders) on a subset of items.
- Discovery layer: optional, deterministic secrets with a persisted discovery ledger.
- World Memory: explicit, save-safe flags for meaningful consequences (DD-004, DD-013).
- Smart Assist with player-controlled assist levels; assist usage is a mastery dimension, never a wall.
- Save/restore with versioned schema and atomic writes; interruption recovery.
- Accessibility baseline from Phase 00 as a design concern (V7.1 §9).
- Localization-safe text from the start (V7.1 §13).

### 7.2 Should (kept if the Gold Slice proves value)
- Mastery challenge variants (move efficiency, limited assist, world-state challenge).
- Companion bond progression beyond Nox's first capability.
- Item memory (first-found location, chapter of acquisition).
- Deterministic daily challenge seed (offline-capable).

### 7.3 Later (post-v1 unless Product re-approves)
- Verdant Archive biome and its chapter (`PD-028` §C, CUT-030) — v1 biomes = 5, chapter ceiling = 9.
- Second companion.
- Leaderboards / competitive results.
- Remote content packs.
- Tablet/landscape layout; iOS.
- Crafting beyond a single, lightweight "combine two knowns" interaction.

### 7.4 Reject (see `CUT_LIST_AND_COMPLEXITY_BUDGET.md` for IDs and rationale)
- Any online requirement for the core.
- Energy/stamina timers, loot boxes, gacha, randomized mandatory rewards.
- Combat system; companion combat.
- Block-building / sandbox construction.
- Player-vs-player.
- Currency stacks > 1 (a second currency requires a new Product decision).
- Durability that breaks items.
- Open-ended branching narrative trees.

## 8. Non-goals (restated as product commitments)

CraftCube will **not** become: a generic RPG, a bare Rubik simulator, a block-building clone, a loot-grind, a stat treadmill, a menu-heavy collection game, or an online-required experience (Bible §12). Every phase gate re-checks these.

## 9. Success criteria (product level)

Product success is measured, not asserted. Thresholds live in `INVESTMENT_GATE_METRICS.md`. The categories are:

1. **Fun** — players want to do "one more solve" without external reward.
2. **Clarity** — players understand control, purpose and consequence within the first session.
3. **Uniqueness** — players describe the game in terms no existing puzzle app owns.
4. **Equipment value** — players can name what a tool let them do differently.
5. **Story curiosity** — players state a question they want answered.
6. **Mobile feasibility** — measured performance, input reliability and interruption safety on the AI-11 device matrix.

## 10. Measurable boundaries (hard numbers Product will hold)

These are product boundaries, not engineering budgets. Engineering budgets are owned by AI-11 and may be stricter.

| Boundary | Limit | Why |
|---|---|---|
| Mandatory reading before first solve | ≤ 40 words total | P3; "no lore walls" |
| Time to first solve on a fresh install | ≤ 3 minutes (median, playtest) | F10 clarity |
| Time from solve completion to visible world reaction | ≤ 2 s | P2 causality |
| Active equipment slots | ≤ 4 | Equipment Bible §Equipment slots; mobile clarity |
| Simultaneous currencies/resources visible to the player | ≤ 1 at v1 | DD-014 |
| Menu depth to change a loadout | ≤ 2 taps from gameplay | V7.1 §5.4 friction-light switching |
| Distinct persistent narrative memory flags per chapter | ≤ 6 | DD-013 scoped memory |
| Critical-path items dependent on random drops | 0 | DD-006 |
| Cutscene length before first solve | ≤ 20 s | P3 |

## 11. Unresolved Product/Human decisions (explicitly deferred — do not guess)

| Item | Status (v1.1.0) | Decision owner |
|---|---|---|
| Engine / technology lock | **DECIDED** — Godot 4.x stable + GDScript, Android-first (`PD-030`, supersedes `PD-025`); versions pinned later | Human Project Owner provides build/toolchain environment before Phase 02 |
| Public title | **DECIDED for current phase** — "CraftCube" working title (`PD-026`); **trademark/legal clearance still REQUIRED before final brand lock** | Human / legal |
| "Asterra" public use | **DECIDED** — internal-only until legal clearance (`PD-026`, `PD-028` §D) | Human / legal |
| Monetization model | **DECIDED** — premium one-time purchase (`PD-027`); **exact price NOT frozen** | Human (price: commercial/store decision) |
| Story canon baseline | **DECIDED** — Story Bible v0.1.0 approved with S1–S4 resolutions (`PD-028`) | — |
| Total chapter count at release (≤ 9 after `PD-028` §C) | Scope — depends on Phase 06 evidence | AI-01 after Gold Slice (`PD-015`) |
| Remaining human-gated items | see `PD-029` | Human |

## 12. Consumption notes for downstream tracks

- **AI-02 / AI-03:** the boundaries in §10 become acceptance tests in Phase 01 contracts (e.g., causality latency, zero random critical rewards).
- **AI-07:** slot count (≤4), tap-depth (≤2), pre-solve text (≤40 words) are UX acceptance criteria.
- **AI-09:** §6.3 vocabulary is approved; §6.4 conflicts need resolution before Story Bible freeze.
- **AI-10:** `F10-###` and `IGM-###` IDs are the product-validation test targets.
- **AI-11:** platform rows marked ASSUMED/HYPOTHESIS need measured replacement.
- **AI-13:** `PD-###`, `F10-###`, `IGM-###`, `CUT-###` are new stable ID families owned by AI-01; please register them in the governance ID registry once it exists.

## 13. Change control

Changes to this document follow `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`. Additive clarification → patch version. Changing a pillar rank, an audience statement, a scope MUST, or a §10 boundary → minor version and a new `PD-###` entry. Changing the value proposition or the protected core → Human approval gate.
