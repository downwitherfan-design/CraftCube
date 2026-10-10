# CraftCube — Competitor & Adjacent-Product Review (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.COMPETITORS` |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW — satisfies `INVESTMENT_GATE.md` Gate A "Top 5 direct/adjacent competitors are reviewed" and closes the MISSING item in `INVESTMENT_GATE_METRICS.md` `IGM-003b`. Human confirmation of the differentiation claims is still required (product taste is a human gate, V7.1 §17). |
| Evidence basis | Public Google Play / publisher store listings retrieved by web search during this Phase 00 session. Each fact below is labelled **VERIFIED (store listing)** or **INFERRED**. Prices and ratings change; they are recorded as observed, not as commitments. No sales, revenue or retention figures are claimed — none were available. |

## Purpose

`INVESTMENT_GATE.md` Gate A requires a review of the top 5 direct/adjacent competitors. This document exists so the Uniqueness dimension (`IGM-003`) has a real reference list, so the coding lists for the exit question "In one sentence, what is this game about?" are grounded, and so no feature is added "because a competitor has it" (Gate D).

Selection rule: one title per adjacent genre a player might *mistake CraftCube for*. Titles were chosen because they are the most likely primary descriptions a fresh player would reach for — which is exactly the failure mode `IGM-003` measures.

## 1. Reviewed titles

### C1 — Monument Valley series (ustwo games) — *adjacent: atmospheric mobile puzzle-adventure*
- **VERIFIED (store listing):** Google Play `com.ustwo.monumentvalley` — "a surreal exploration through fantastical architecture and impossible geometry"; the player guides a silent princess through monuments. Monument Valley 3 (`com.ustwogames.mv3`) offers the first two chapters free and unlocks the full game with a single in-app purchase. Third-party listing reports the original at $3.99 with 11 stages.
- **What it proves for CraftCube:** premium/single-unlock atmospheric puzzle games with short chapters, a silent protagonist and no economy have a proven mobile audience — this is the audience in `PRODUCT_LOCK_V1.md` §4 and the pricing shape `PD-014` recommends.
- **Where CraftCube differs:** Monument Valley's puzzle is *spatial navigation of a level*; the level is the puzzle. CraftCube's puzzle is a *held object whose mastery is a language*, and the world is the **consequence**, not the puzzle. Monument Valley has no equipment, no companion with sensing behaviour, no persistent world memory across chapters, and no moral turn about restoration.
- **Risk to watch:** if CraftCube's world presentation leans too far into "impossible architecture", players will describe it as "like Monument Valley". `IGM-003` coding list must include "Monument Valley-like" as a competitor-framed answer.

### C2 — The Room series (Fireproof Games) — *adjacent: tactile 3D object puzzle + mystery*
- **VERIFIED (store listing):** Google Play `com.FireproofStudios.TheRoom` — "a physical puzzler, wrapped in a mystery game, inside a beautifully tactile 3D world"; publisher lists The Room: Old Sins at $4.99; the series is described as "tactile exploration meets challenging puzzles and a captivating story"; the games are offline-playable and premium.
- **What it proves for CraftCube:** touch-manipulated 3D objects with hidden mechanisms, mystery told through objects and environment (not text walls), premium pricing, offline — all validate `PD-001`, `PD-010`, `PD-014` direction and the "no lore wall" rule.
- **Where CraftCube differs:** The Room's objects are one-shot puzzle boxes; solving one is done forever and the world does not change. CraftCube's cube is a **single persistent instrument** whose skill transfers across the whole game (P1), and each solve alters a persistent world (P2). The Room has no companion, no loadout choice, no replay-for-mastery layer.
- **Risk to watch:** The Room owns "tactile mystery box" in players' minds. CraftCube must lead with **world consequence** in its first 3 minutes (`F10-002`, `F10-003`), or players will file it as "a Room-like".

### C3 — Cube Solver (com.jeffprod.cubesolver) and Cube Solver for Rubik's Puzzle (pbf.rubiks.cube.solver) — *direct risk of misidentification: twisty-puzzle utility apps*
- **VERIFIED (store listing):** `com.jeffprod.cubesolver` — "Get the 3D solution in seconds… Just describe your puzzle — the app does the rest"; supports 2×2/3×3/4×4/5×5 and Skewb; free; on Google Play since December 2018; APK ~18 MB. `pbf.rubiks.cube.solver` — "solve cubes anytime… without needing your physical Rubik's Cube, with our Digital Cube".
- **What it proves for CraftCube:** there is an existing, sizeable audience that interacts with virtual twisty cubes on Android, and the category is dominated by **utilities** (solvers, timers, simulators) rather than games. This is the secondary audience in `PRODUCT_LOCK_V1.md` §4.
- **Where CraftCube differs:** these apps *do the solving for you* — the exact opposite of DD-001/`PD-007` ("assist may highlight, preview or explain; never perform moves"). They have no world, no story, no consequence. CraftCube is the first product in this list that treats the cube as a **skill to master inside a fiction**.
- **Risk to watch:** this is the `IGM-003` HARD_STOP scenario ("≥ 40% describe it primarily as a Rubik's cube app"). Mitigations already locked: the cube is never called "Rubik"/"magic cube"/"speedcube" in-game (`PRODUCT_LOCK_V1.md` §6.3); the first solve is followed within 2 s by a world reaction; the first 10 minutes never show a timer or move counter (`F10` "must NOT contain").
- **IP note:** "Rubik's" is a third-party trademark. CraftCube must never use it in product name, store listing, keywords or in-game text. Recorded for the Human IP gate (`OD-0005`).

### C4 — Cube Escape / Rusty Lake series (Rusty Lake) — *adjacent: story-driven mystery puzzle with a "cube" in the name*
- **VERIFIED (store listing):** Google Play `air.com.RustyLake.CubeEscapeCollection` — nine chapters (Seasons, The Lake, Arles, Harvey's Box, Case 23, The Mill, Birthday, Theatre, The Cave); episodic point-and-click room-escape; the Cube Escape entries are free, with premium Rusty Lake titles alongside; offline.
- **What it proves for CraftCube:** a mystery told across chapters through environment and objects, with almost no expository text, retains players across a long series. Confirms `PD-001` (three-layer mystery, one question per chapter) and DD-003.
- **Where CraftCube differs:** Cube Escape's "cube" is a room; puzzles are inventory/point-and-click logic with no transferable manual skill. CraftCube's mastery is **motor + pattern skill on one object**. Cube Escape's tone is unsettling/horror-adjacent; CraftCube's Story Bible tone is "wonder + warmth + quiet danger — never horror".
- **Risk to watch:** **name collision.** "Cube" + "mystery" is already associated with Rusty Lake in the puzzle audience. This strengthens the case for the title check in `PD-013` before Phase 14, and for never using "escape" in CraftCube copy.

### C5 — Minecraft (Mojang) — *adjacent by heritage only: block-building sandbox*
- **VERIFIED (store listing):** Google Play `com.mojang.minecraftpe` — "Explore and craft your way through a completely open world… Build a city, start a farm, mine deep"; a separate time-limited free Trial exists (`com.mojang.minecrafttrialpe`) built around survival mode with crafting weapons and armour.
- **Why it is on this list:** `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` records that the source GDD used Minecraft presentation. The Game Master Bible §1 says CraftCube "may evoke the freedom and wonder of a block-building sandbox" but is **not** a clone. Minecraft is therefore the product CraftCube must actively *not* be mistaken for.
- **Where CraftCube differs (all already locked):** no block building or terrain editing (`CUT-007`), no combat/weapons/armour (`CUT-005`), no open-ended crafting tree (`CUT-010`), no survival/hunger/durability (`CUT-009`), no multiplayer (`CUT-008`, `CUT-018`), no procedural world (`CUT-019`). The world is **authored** and changes only as a consequence of puzzle mastery.
- **Risk to watch:** visual language. If AI-05/AI-06 art direction uses cubic voxel terrain, blocky creatures or a hotbar-style inventory, players and store reviewers will say "Minecraft clone" regardless of mechanics — `IGM-003` HARD_STOP and an IP-adjacency risk. Product requirement to AI-05/AI-06/AI-07: the *cube* is the only cubic thing the player masters; the world's visual grammar must not read as voxel blocks; inventory must not read as a hotbar. Recorded for `OD-0005`.

## 2. Differentiation summary (the claim Product is making)

| Dimension | C1 Monument Valley | C2 The Room | C3 Cube solvers | C4 Cube Escape | C5 Minecraft | **CraftCube** |
|---|---|---|---|---|---|---|
| Core skill transfers across the whole game | no (per-level) | partly (observation) | n/a (app solves) | no | yes (building) | **yes — one cube language** |
| Solve changes a persistent world | no | no | no | no | player-built | **yes, authored, ≤ 2 s** |
| Story through environment, no lore wall | yes | yes | no story | yes | none | **yes + moral turn** |
| Equipment that changes perception/access | no | no | no | inventory items | tools/weapons | **yes, ≤ 4 slots, no stats** |
| Companion that senses/reacts | no | no | no | no | pets/mobs | **yes, one (Nox)** |
| Offline, no timers, no gacha | yes | yes | yes | yes | yes | **yes (locked)** |

**Claim:** no reviewed product combines *transferable manual puzzle mastery* with *authored persistent world consequence* and *story-with-a-moral-turn*. That combination is the CraftCube-distinct concept set used in `IGM-003` coding.

## 3. Consequences fed back into product artifacts

1. `IGM-003` coding lists — **distinct concepts:** "cube changes the world", "restoring/repairing a world", "mystery of why it broke / whether to put it back", "creature that notices things", "tools that let me see/reach". **Competitor-framed concepts:** "Rubik's cube app / cube solver", "Minecraft-like / blocky building", "like Monument Valley", "like The Room / puzzle box", "escape room / Cube Escape", "match-3", "RPG".
2. Title risk: two of five adjacent products have "Cube" in the title or app class (C3, C4). `PD-013` recommendation strengthened: run the title/trademark check **before** any logo or store-asset spend.
3. Visual-language requirement to AI-05/AI-06/AI-07 (from C5): non-voxel world grammar; non-hotbar inventory. Recorded as a product requirement, to be reflected in the art/UX direction locks of those tracks.
4. No feature was added as a result of this review. Two rejections were re-confirmed (`CUT-005`, `CUT-007`).

## 4. What this review does NOT claim

- No download, revenue, retention or rating figures are asserted; where a third-party site reported a price, it is labelled as such.
- The list is not exhaustive; it is the five most likely *misidentifications*. Additional adjacent titles (e.g., other atmospheric puzzle-adventures) may be added in a patch version without changing the differentiation claim.
- Human Product Authority should confirm the differentiation claim in §2 before Phase 00 is promoted (`V7_1_WORLDCLASS_UPGRADE.md` §17 product taste).
