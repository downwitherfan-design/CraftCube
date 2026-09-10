# CraftCube — Environment Art Direction Lock (Phase 00)

| Field | Value |
|---|---|
| Document ID | `AI05-DOC-ENV-DIRECTION-LOCK` |
| Owner | AI-05 — Environment Art / World / Materials / Lighting |
| Version | 1.0.0 |
| Status | PHASE-00 LOCK CANDIDATE (awaiting AI-01 product ratification) |
| Phase | 00 — Product/IP Lock |
| Source of truth consumed | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md`, `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`, `01_PREPRODUCTION/STORY_BIBLE_V7.md`, `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md`, `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md`, `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`, `09_ART_AUDIO/ASSET_PIPELINE.md` |
| Companion document | `09_ART_AUDIO/environment/BIOME_PRESENTATION_IDENTITY_MATRIX_V1.md` |

This document locks **what the world must look like, why, and how far it may go**. It does not define gameplay logic, simulation state, UI, audio or build settings. Where a fact depends on another account it is labelled `UNKNOWN`, `ASSUMED`, `INFERRED` or `PENDING <owner>` per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`.

---

## 1. Environment vision (one sentence)

**The world is a woven mechanism that has come loose; every solved puzzle visibly pulls a thread tight, and the player can always look back and see where they have been.**

Derived from the Game Master Bible core fantasy ("every time I master it, the world answers me") and World Philosophy §10 ("the world should remember meaningful events").

## 2. Environment pillars (protected)

| # | Pillar | What it means for production | Violation example |
|---|---|---|---|
| E1 | **Causality is visible** | Every world change caused by the puzzle must be readable from the default gameplay camera within ~1 s of the triggering event, without UI text. | A restored pump only shows in a menu counter. |
| E2 | **The world remembers** | Persistent world state (Tier 0–4, discovered/mastered/secret) has a persistent visual signature that survives save/load and revisits. | Restored path resets to broken on reload. |
| E3 | **Biomes are mechanics, not skins** | Each biome has a distinct silhouette language, material family, lighting mood and transition behaviour that mirrors its puzzle relationship (see Matrix). | Re-tinting Hearthwild assets purple for Glassroot. |
| E4 | **Readability over spectacle** | The puzzle object and its state are always the highest-contrast element in frame. Environment never competes for value/saturation with the cube. | Flourishing-tier particle bloom hides cube face colours. |
| E5 | **Mobile-first by construction** | Kits are authored to mobile budgets from the blockout stage; no "optimise later" pass is assumed. | Hero rock at 200 k tris with a downstream LOD promise. |
| E6 | **Original and IP-safe** | No voxel-block terrain language, no cube-grid textures, no borrowed creature/biome names, no proprietary palettes. The recurring motif is the **woven lattice**, not the block. | 16×16 pixel-art tiling textures on unit cubes. |

## 3. IP-safe visual direction

### 3.1 What CraftCube's world is
- **Motif:** the *lattice / weave*. Architecture, roots, crystals and machinery all express intersecting threads and seams that tighten or fray. The player's cube is one small expression of the same language.
- **Form language:** faceted-organic. Large soft masses with crisp, rule-based seams where the Loom's geometry shows through. Facets follow the world's "alignment axes" and are visibly straighter where the world is more restored.
- **Scale:** intimate. Spaces are read at hand-held phone distance; landmarks are medium-scale and few.
- **Surface language:** hand-authored, stylised materials with painted-value shading and restrained micro-detail. Legible at 6–7 inch screens.

### 3.2 What CraftCube's world is not (explicit rejections)
- No unit-block terrain, no block-stacked construction silhouettes, no cube-grid texture tiling as the world's surface identity.
- No pixel-art texture aesthetic as a primary read.
- No borrowed named regions, creatures, ores, tools or "dimension" terms from any existing block-building franchise or twisting-puzzle brand.
- No photoreal PBR scan-based look (cost, readability and identity all argue against it).
- No dark/grim-derelict tone as the baseline (Story Bible tone: wonder + mystery + warmth + quiet danger).

### 3.3 Terminology boundary
Player-facing world names (Hearthwild, Glassroot, Sunken Grid, Ember Hollow, Verdant Archive, The Quiet Engine, Axis Loom, Great Misalignment, Weaver) are **AI-09 canon** consumed as-is from the World Biome Bible and Story Bible. AI-05 introduces only **internal presentation vocabulary**, which must never appear in player-facing strings without an AI-09 localization key:

| Internal term | Meaning |
|---|---|
| `alignment seam` | The visible line/edge where world geometry snaps to a Loom axis when restored. |
| `fray` | Visual state of unrestored/unstable geometry: offset facets, loose threads, drift. |
| `state beacon` | A single, deliberately placed environment element per zone whose look changes with tier so the tier is readable at a glance. |
| `memory mark` | A small, persistent, non-progression-critical environment change that records a past player action. |
| `causality window` | The ~1 s post-solve moment in which the world change must be visible from the gameplay camera. |

`CONFLICT` recorded for AI-09: Story Bible ch.7 says "The Silent Engine"; World Biome Bible biome 6 says "The Quiet Engine"; Item Catalog says "Quiet Engine". This document uses **The Quiet Engine** pending AI-09 resolution.

## 4. Platform assumptions

| Assumption | Source | Status |
|---|---|---|
| Engine: Unity 6 + URP, Android primary | `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` | VERIFIED (doc) — no Unity project exists in the repo yet |
| Render pipeline: URP Forward, mobile-oriented | Blueprint says URP; renderer path not specified | ASSUMED — PENDING AI-12/AI-13 bootstrap (Phase 2) |
| Device tiers Low / Mid / High / Tablet | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` | VERIFIED (template) — actual devices UNKNOWN |
| FPS targets: 60 mid-tier, 30 low-power mode | Blueprint "Performance budgets" | VERIFIED (doc, labelled hypothesis there) |
| Content addressing: Addressables or selected pipeline, ID-based | Blueprint "Asset addressing" | VERIFIED (doc) |
| Portrait orientation vs landscape | Not stated anywhere in repo | UNKNOWN — PENDING AI-01/AI-04/AI-07 decision. Environment kits will be authored for both until decided; camera framing tests in §7 assume portrait-first because the product is a mobile phone game. |

## 5. Lighting direction

- **One key, one fill, one identity light per biome.** Each biome owns one directional key colour, one ambient/fill colour and one "identity" emissive family (see Matrix). No more than one real-time shadow-casting light per scene on Low/Mid tiers; additional lights are baked or fake (emissive + vertex colour).
- **Lighting is a state channel.** Tier progression is expressed partly through light: dormant = low-contrast, desaturated fill; flourishing = warm key + coloured bounce. Lighting must *never* be the only tier cue (accessibility, §8).
- **Cube gets a guaranteed read.** A dedicated, biome-independent rim/fill contribution for the puzzle object is owned by AI-04/AI-06 at runtime; the environment agrees to keep the background behind the cube's dominant camera framing within a **mid-value band** (environment value 25–65 % where cube faces sit at 15 % / 85 %) so face colours remain distinguishable. Exact band to be measured in Phase 4 with real cube materials; the numbers here are the starting hypothesis.
- **No baked lighting dependency for state changes.** Any surface whose look changes with tier uses real-time-safe techniques (material parameter, vertex colour, emissive mask, mesh swap) rather than re-baking.

## 6. Material direction

- **Material family per biome, shared master shader set.** Target ≤ 6 master shaders for the whole world (opaque-stylised, foliage/alpha-cut, emissive-lattice, water/glass, terrain-blend, decal). Variants are material instances, never new shader graphs, unless a Phase-1 contract adds one.
- **State-driven parameters, not asset duplication.** Every "tiered" material exposes a normalised `_RestoreAmount` (0–1) parameter driving seam tightness, fray displacement, emissive intensity and saturation. Naming of the shader property is a Phase-1 contract item; the semantic is locked here.
- **Texture ceilings (art-side proposal, PENDING AI-11 budget):** 1024² for hero/landmark, 512² for kit, 256² for decals and trims; ASTC-compressed; atlased per biome. Total resident environment texture memory target per biome ≤ 64 MB on Low tier. These are hypotheses until measured.
- **Vertex colour is mandatory** on all kit meshes (R = wear/fray mask, G = restore mask, B = biome accent, A = AO). This gives per-instance state variation without extra textures.

## 7. Readability rules (measurable)

| Rule | Measure | Target | Verification method |
|---|---|---|---|
| R1 Causality window | Time from world-state event to first visible environment change in frame | ≤ 1.0 s (first change), ≤ 3.0 s (change settled) | Frame-count from screen capture in Phase 4/5 |
| R2 Tier legibility | Blind sort: reviewer shown 5 stills of one zone at Tier 0–4 in random order | ≥ 90 % correct ordering across 10 reviewers | Review session, Phase 6 Gold Slice |
| R3 Cube contrast | Luminance contrast between darkest cube face and background behind it | ≥ 3:1 at all tiers | Screenshot luminance sampling |
| R4 State beacon | Every playable zone has exactly one state beacon visible from the default camera | 100 % of zones | Content validator (Phase 7 pipeline) |
| R5 Memory mark persistence | Memory marks survive save → quit → reload → revisit | 100 % | Save/reload test (AI-10 fixture, AI-05 supplies expected visuals) |
| R6 No colour-only cue | Every tier transition and every memory mark has at least one non-hue cue (shape, motion, emissive intensity, silhouette, sound handled by AI-08) | 100 % | Fixture validator (`tools/validate_environment_fixtures.py`) — enforced now on the mock fixture |

## 8. Accessibility, localization, performance and recovery implications

- **Accessibility:** rule R6 above; motion-reduction mode must be able to freeze fray drift and slow tier-transition animations without changing final state; no environment element may flash > 3 Hz. Colour-blind safe palettes are chosen per biome so adjacent biomes differ in value, not just hue.
- **Localization:** the environment carries **no baked text**. Signs, glyphs and inscriptions use the recurring lattice symbol set only (symbols are AI-09 canon; AI-05 renders them). Any readable text goes through AI-07 UI + AI-09 keys.
- **Performance:** every biome kit ships with LOD0/LOD1/LOD2 for kit pieces > 500 tris; culling distance and LOD bias are per-tier settings owned by AI-11's budget. Environment state transitions must not spawn > 1 particle system per beacon on Low tier.
- **Recovery:** environment presentation is a **pure function of persisted world state** (WorldState / CC.BIOME.STATE — schema PENDING AI-02). If a state value is missing or unknown, the environment renders **Tier 0 with a visible `MISSING_STATE` debug marker in development builds**; it never silently guesses a higher tier. The debug marker must be mechanically stripped from release per `ASSET_PIPELINE.md` "No placeholder leakage".

## 9. Measurable boundaries and cut list

### 9.1 Scope boundaries (locked for v1)
| Boundary | Value |
|---|---|
| Biomes in product | 6 (as defined in World Biome Bible). No 7th biome without Product decision. |
| Vertical Slice (Phase 6) biome coverage | Hearthwild only, Tiers 0–3 fully presented, Tier 4 as a single rare-state beacon variant. |
| Tier states presented per biome | 5 (Tier 0–4). Tier 4 is optional-rare and may be a beacon-only visual on Low tier. |
| Modular kit pieces per biome (proposal) | ≤ 40 unique meshes incl. variants; ≤ 6 hero/landmark pieces. |
| Master shaders | ≤ 6 (see §6). |
| State beacons per zone | Exactly 1. |
| Memory marks per zone | ≤ 3 persistent marks. More requires an AI-02 save-budget discussion. |

### 9.2 Cut list (Rejected / Later)
| Item | Decision | Reason |
|---|---|---|
| Dynamic weather system | LATER (post-VS) | Cost vs. readability; conflicts with lighting-as-state-channel. |
| Day/night cycle | REJECT for v1 | Breaks R3 cube-contrast guarantee and R2 legibility. Time-of-day may be a fixed per-biome mood. |
| Real-time global illumination | REJECT | Mobile budget; baked/probe ambient only. |
| Destructible/player-built terrain | REJECT | Non-goal ("block-building clone"); world changes are authored consequences of puzzle state. |
| Procedural biome generation | REJECT | World memory and readability need authored spaces; deterministic authored layouts only. |
| Photoreal materials / scan data | REJECT | Identity + budget (§3.2). |
| Per-tier unique mesh sets | REJECT | Use `_RestoreAmount` + mesh swap only for the beacon; avoids 5× asset volume. |

## 10. Success criteria for this phase (AI-05 portion)
1. This lock document and the Biome Presentation Identity Matrix exist and are coherent with the Game Master Bible and World Biome Bible. ✔ (this commit series)
2. Every biome has a gameplay-identity-to-visual mapping and visible Tier 0→4 transition logic. → Matrix.
3. A labelled mock fixture exists so AI-02/AI-04/AI-06/AI-08/AI-10 can consume biome presentation state without waiting on AI-05 assets. → `fixtures/MOCK_biome_presentation_state_v0.json`.
4. A deterministic validator enforces ID uniqueness, tier coverage and rule R6 on the fixture. → `tools/validate_environment_fixtures.py`.
5. All UNKNOWN/CONFLICT/PENDING items are listed in the handoff for AI-01/AI-09/AI-11/AI-13.

## 11. Dependencies and open decisions (not guessed)

| ID | Type | Item | Needed from |
|---|---|---|---|
| DEP-01 | MISSING | `CC.BIOME.STATE` / WorldState schema and canonical biome IDs | AI-02 (Phase 1) |
| DEP-02 | MISSING | Performance budgets per device tier (tris, draw calls, texture MB, particles) | AI-11 (Phase 1) |
| DEP-03 | CONFLICT | "Quiet Engine" vs "Silent Engine" naming | AI-09 |
| DEP-04 | UNKNOWN | Screen orientation (portrait/landscape/both) | AI-01 / AI-04 / AI-07 |
| DEP-05 | CONFLICT | Legacy ownership mapping (AI-05 → `Assets/UI`, `src/UI`, Tablet QA row) in `07_GITHUB/CODEOWNERS_EXAMPLE.txt`, `07_GITHUB/scripts/validate_ownership.py`, `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` | AI-13 governance |
| DEP-06 | MISSING | `integration` branch does not exist on origin; PR target unavailable | AI-13 |
| DEP-07 | PENDING | Ratification of `09_ART_AUDIO/environment/` as the AI-05 owned path | AI-13 |
| DEP-08 | PENDING | Product ratification of §9 boundaries and cut list | AI-01 |
