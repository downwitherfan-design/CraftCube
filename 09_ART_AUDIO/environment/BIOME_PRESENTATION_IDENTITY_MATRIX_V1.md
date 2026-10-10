# CraftCube — Biome Presentation Identity Matrix (Phase 00)

| Field | Value |
|---|---|
| Document ID | `AI05-DOC-BIOME-PRESENTATION-MATRIX` |
| Owner | AI-05 — Environment Art / World / Materials / Lighting |
| Version | 1.0.0 |
| Status | PHASE-00 LOCK CANDIDATE |
| Parent | `09_ART_AUDIO/environment/ENVIRONMENT_ART_DIRECTION_LOCK_V1.md` |
| Gameplay identity source (consumed, not owned) | `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md` |
| Fixture | `09_ART_AUDIO/environment/fixtures/MOCK_biome_presentation_state_v0.json` |

Purpose: give every major biome a **visual identity that is the same statement as its gameplay identity**, and define **visible, tier-by-tier state-transition logic** so world causality and world memory are readable, not decorative.

Rules of this document:
- Gameplay identity columns are copied from the World Biome Bible and are **AI-03/AI-02/AI-09 territory** — listed here only so the visual mapping can be checked for coherence.
- All IDs introduced here are **presentation IDs** (`env.*`). They are DRAFT until a Phase-1 contract freeze. They must be mapped to — not replace — the canonical biome IDs that AI-02 will publish in `CC.BIOME.STATE`.
- Tier semantics (0 dormant → 4 mastered/rare) are consumed from the World Biome Bible "Biome transformation tiers". AI-05 does not define when a tier is reached; it defines what a reached tier looks like.

---

## 1. Presentation ID scheme (DRAFT, pending Phase-1 freeze)

```
env.biome.<biome_slug>                      biome presentation set
env.biome.<biome_slug>.beacon               the single state beacon of a zone in that biome
env.biome.<biome_slug>.tier.<0-4>           tier look definition
env.biome.<biome_slug>.memory.<slug>        a memory-mark presentation
env.shader.<slug>                           master shader semantic (≤ 6)
env.motif.lattice                           the shared woven-lattice motif
```

Slugs (lower-case, stable): `hearthwild`, `glassroot`, `sunken_grid`, `ember_hollow`, `verdant_archive`, `quiet_engine`.

`sunken_grid`, `ember_hollow`, `verdant_archive`, `quiet_engine` follow the World Biome Bible names. `quiet_engine` is subject to DEP-03 (AI-09 "Quiet" vs "Silent" conflict); if AI-09 renames, the slug is changed **before** freeze — after freeze it becomes immutable and only the display key changes.

Repository search performed before assigning (2025-09-10, commit `584141c`): no existing `env.` IDs, no biome slugs, no fixture files, no `Assets/` or `src/` tree. Result: ABSENT → CREATE.

---

## 2. Cross-biome visual grammar

| Channel | Tier 0 dormant | Tier 1 awakened | Tier 2 recovering | Tier 3 flourishing | Tier 4 mastered / rare |
|---|---|---|---|---|---|
| **Alignment seams** | absent / broken | first seams glow faintly along Loom axes | seams continuous on primary structures | seams continuous on all structures, subtle pulse | seams settle to steady, geometry snaps fully straight |
| **Fray (silhouette)** | facets offset, loose thread strands, drift motion | drift slows, largest offsets close | offsets closed on primary structures | no fray; secondary detail grows | rare "crystalline-clean" silhouette variant on beacon |
| **Saturation (material)** | 40 % of biome palette | 55 % | 70 % | 90 % | 100 % + biome accent in emissive |
| **Key light** | cool-neutral, low contrast | biome key colour begins to tint | biome key at 70 % intensity | biome key full, coloured bounce | key + identity emissive, still within cube-contrast band |
| **Motion** | slow drift only (reduced-motion: frozen) | one-shot "tighten" animation on transition | ambient life (foliage/water/particles at Low-tier budget) | fuller ambient life | ambient + one rare beacon idle |
| **Non-hue cue (R6)** | broken silhouette | seam appears (shape) | silhouette closes (shape) | scale/density increase (shape) | beacon mesh swap (shape) |

Every tier step therefore changes **shape** as well as colour/light, satisfying R6 without relying on audio or UI.

---

## 3. Per-biome matrix

### 3.1 Hearthwild — `env.biome.hearthwild`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: warmth, restoration, first growth | **Woven meadow-hearth.** Rolling soft terrain, low stone hearth-rings, wooden lattice bridges, warm grasses. |
| Puzzle relationship: orientation, basic alignment | Structures are **visibly rotated off-axis** at Tier 0 and rotate onto axis as tiers rise — the environment literally performs "orientation". |
| World response: paths, water channels, plant growth, safe habitats | **State beacon:** the *Hearth Loom Post* — a lattice post at the zone centre. Tier 0 leaning + dark; Tier 1 upright + first seam; Tier 2 seam lit + first vine; Tier 3 canopy of woven vines; Tier 4 flowering rare variant. |
| Narrative function: teach that solving changes reality | The first transition (Tier 0→1) is the tutorial for causality itself, so it is the **loudest transition in the game** (largest shape change, clearest camera framing) while later ones are quieter. |

- Key light: warm amber (`ASSUMED` ~3200 K equivalent), fill: soft green-grey. Identity emissive: ember-gold along seams.
- Material family: `env.shader.opaque_stylised`, `env.shader.foliage_cut`, `env.shader.terrain_blend`, `env.shader.water_glass` (channels).
- Memory marks (≤ 3): `env.biome.hearthwild.memory.first_path` (restored path stones stay lit), `env.biome.hearthwild.memory.channel_opened` (water channel keeps flowing), `env.biome.hearthwild.memory.habitat_claimed` (creature nest remains — creature itself is AI-06).
- Vertical Slice: **this biome only**, Tiers 0–3 full, Tier 4 beacon-variant only.

### 3.2 Glassroot — `env.biome.glassroot`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: crystal growth and memory | **Root-crystal cathedral.** Translucent faceted growths sprouting from dark root beds; light passes through and refracts along seams. |
| Puzzle relationship: pattern recognition and state echoes | Crystals hold **ghost-echo silhouettes** of previous states inside them (a second, dimmer copy of the geometry offset inside the crystal). The environment shows "what this looked like before". |
| World response: crystal structures reveal previous states and hidden routes | **State beacon:** the *Echo Spire* — a tall crystal. Tier 0 opaque/clouded; Tier 1 first internal echo visible; Tier 2 echo aligns with outer shell; Tier 3 spire refracts a route-line onto the ground; Tier 4 spire becomes fully clear with all echoes stacked. |
| Narrative function: introduce world memory | Memory marks here are **more prominent** than elsewhere: past actions leave visible echoes inside crystals. |

- Key light: cool violet-white, fill: deep teal. Identity emissive: pale cyan internal refraction.
- Material family: `env.shader.water_glass` (dominant), `env.shader.emissive_lattice`, `env.shader.opaque_stylised`.
- Memory marks: `env.biome.glassroot.memory.echo_recorded`, `env.biome.glassroot.memory.route_revealed`, `env.biome.glassroot.memory.spire_cleared`.
- Cube-contrast risk: refraction can wash the cube; R3 enforced by keeping the beacon out of the cube's default framing.

### 3.3 Sunken Grid — `env.biome.sunken_grid`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: flooded ruins and lost infrastructure | **Drowned lattice-works.** Waterlogged plazas, half-submerged pump houses, bridge stubs, dormant light conduits. Water level is a tier channel. |
| Puzzle relationship: sequencing and controlled restoration | Infrastructure restores **in visible sequence** — pumps → bridges → elevators → light network — mirroring the puzzle's ordered logic. Restoring out of order is impossible by design (AI-03), so the environment never has to show invalid orders. |
| World response: pumps, bridges, elevators, light networks | **State beacon:** the *Grid Pump Tower*. Tier 0 submerged to the roofline; Tier 1 water drops one step, wheel turns once; Tier 2 water at plaza level, bridge extends; Tier 3 elevator lit, conduits carry light; Tier 4 full light network across the zone. |
| Narrative function: reveal contradictions in historical records | Environmental storytelling: **two sets of inscriptions** (lattice glyphs, AI-09 canon) that do not agree, revealed at different water levels. |

- Key light: overcast steel-blue, fill: green-grey underwater bounce. Identity emissive: conduit white-gold.
- Material family: `env.shader.water_glass`, `env.shader.opaque_stylised`, `env.shader.emissive_lattice`, `env.shader.decal` (water stains, inscriptions).
- Memory marks: `env.biome.sunken_grid.memory.water_lowered`, `env.biome.sunken_grid.memory.bridge_raised`, `env.biome.sunken_grid.memory.record_exposed`.
- Water is a **single planar water level per zone** driven by tier (no simulation) — cheap and deterministic.

### 3.4 Ember Hollow — `env.biome.ember_hollow`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: heat, unstable energy, transformation | **Forge-cavern lattice.** Dark basalt-like facets, heat channels running along seams, forge braziers, temporary bridges of cooled slag. |
| Puzzle relationship: risk/reward and controlled instability | The environment's "flourishing" state is **not calm** — it is *controlled* instability: channels pulse rhythmically rather than erupting. Visual identity teaches that instability can be useful. |
| World response: heat channels, forge-like structures, temporary routes | **State beacon:** the *Ember Forge Ring*. Tier 0 cold, cracked; Tier 1 one channel glows; Tier 2 channels form a closed loop, ring pulses; Tier 3 a slag-bridge cools into a route; Tier 4 the ring burns steady white with no flicker (mastery = control). |
| Narrative function: instability is not always failure | "Failure" states (AI-02/AI-03 define them) are shown as **over-bright + fast pulse**, never as destruction — the world is not punished, it is un-tuned. |

- Key light: low warm orange from below (channels), fill: cool cavern blue. Identity emissive: ember red-orange → white at Tier 4.
- Material family: `env.shader.emissive_lattice` (dominant), `env.shader.opaque_stylised`, `env.shader.decal`.
- Memory marks: `env.biome.ember_hollow.memory.channel_tuned`, `env.biome.ember_hollow.memory.bridge_cooled`, `env.biome.ember_hollow.memory.overheat_scar`.
- Accessibility: pulse rate capped ≤ 2 Hz; reduced-motion mode holds channels at steady glow.

### 3.5 Verdant Archive — `env.biome.verdant_archive`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: living archive, giant roots, biological memory | **Root library.** Colossal roots forming shelves and vaults; seed-pods as record capsules; bioluminescent veins as index lines. |
| Puzzle relationship: long-range pattern planning | Roots grow along **long, visible planning lines** across the zone; the player can read the "whole pattern" of a zone from a vantage point — the environment rewards looking ahead. |
| World response: organic structures encode clues and react to mastery | **State beacon:** the *Archive Heart-Root*. Tier 0 withered, closed; Tier 1 veins light along one line; Tier 2 pods open along lit lines; Tier 3 canopy vault forms overhead; Tier 4 heart-root exposes a single Loom lattice core (story clue, AI-09). |
| Narrative function: deepen the mystery of the Loom | Clues are **encoded in growth direction and pod arrangement** — shape-based, so they remain readable without colour and without text. |

- Key light: dappled green-gold, fill: deep moss. Identity emissive: bioluminescent teal veins.
- Material family: `env.shader.foliage_cut` (dominant), `env.shader.opaque_stylised`, `env.shader.emissive_lattice`, `env.shader.terrain_blend`.
- Memory marks: `env.biome.verdant_archive.memory.pod_opened`, `env.biome.verdant_archive.memory.line_traced`, `env.biome.verdant_archive.memory.vault_grown`.
- Performance: foliage is the biggest Low-tier risk; kit authored with alpha-cut cards and vertex-colour wind, no per-leaf geometry.

### 3.6 The Quiet Engine — `env.biome.quiet_engine`

| Gameplay identity (consumed) | Visual identity (owned) |
|---|---|
| Theme: ancient machine environment | **The loom itself.** Colossal interlocking frames, sliding gantries, threads of light strung between anchors — the woven-lattice motif at architectural scale, finally undisguised. |
| Puzzle relationship: advanced multi-state interaction | Environment holds **multiple stable configurations**; whole rooms slide and re-seat as the puzzle changes. This is the only biome where large geometry moves (pre-authored transforms, deterministic, no physics). |
| World response: architecture literally rearranges around solved configurations | **State beacon:** the *Engine Axis*. Tier 0 frozen, misaligned frames; Tier 1 one frame re-seats; Tier 2 gantry track lights; Tier 3 room reconfigures into a coherent chamber; Tier 4 the axis reveals its intended (evolving) form — the Story Bible's late-game reveal. |
| Narrative function: expose the Loom's intended purpose | Restraint: the identity here is **quiet** — minimal ambient motion, precise seams, near-monochrome palette with a single accent — so the mechanical reveal reads clearly. |

- Key light: neutral white, fill: cool grey. Identity emissive: single accent (pale gold) along thread-lines.
- Material family: `env.shader.opaque_stylised`, `env.shader.emissive_lattice`, `env.shader.decal`.
- Memory marks: `env.biome.quiet_engine.memory.frame_seated`, `env.biome.quiet_engine.memory.chamber_formed`, `env.biome.quiet_engine.memory.axis_revealed`.
- `CONFLICT DEP-03`: name pending AI-09.

---

## 4. Master shader semantics (≤ 6, IDs DRAFT)

| ID | Purpose | State parameter |
|---|---|---|
| `env.shader.opaque_stylised` | rock, stone, wood, metal kit pieces | `_RestoreAmount` → seam emissive, fray displacement, saturation |
| `env.shader.foliage_cut` | grass cards, leaves, vines | `_RestoreAmount` → density mask, wind amplitude |
| `env.shader.emissive_lattice` | seams, conduits, veins, threads | `_RestoreAmount` → intensity, pulse rate cap |
| `env.shader.water_glass` | water planes, crystal, glass | `_RestoreAmount` → clarity, echo-ghost visibility |
| `env.shader.terrain_blend` | ground blends | `_RestoreAmount` → path reveal |
| `env.shader.decal` | inscriptions, stains, scars, memory marks | per-mark visibility flag |

`_RestoreAmount` is a semantic name; the concrete Unity property name is fixed in Phase 1.

---

## 5. World-memory presentation contract (what AI-05 promises to consumers)

Given a persisted biome state (schema PENDING AI-02, mocked in the fixture), AI-05 presentation guarantees:
1. Tier N look is a pure function of `(biome_id, tier)` — same input, same visual, every load.
2. Each memory mark is a pure function of one boolean flag; marks are additive and never hide the tier read or the cube.
3. Missing/unknown state → Tier 0 + development-only `MISSING_STATE` marker (never a guessed tier).
4. Tier transitions animate forward only through authored one-shots; tier regression (if AI-02 allows it) uses the same one-shot reversed — no new asset.
5. No presentation state is stored by AI-05; everything derives from AI-02 state. This keeps saves small (V7.1 §2.4 "memory with restraint").

---

## 6. Coherence check against canon (self-audit)

| Canon requirement | Where satisfied |
|---|---|
| "Biomes are not skins" (World Biome Bible) | §3: each biome's silhouette behaviour mirrors its puzzle relationship (rotation, echo, sequence, controlled pulse, planning lines, reconfiguration). |
| "Every major biome must have a gameplay identity and visible state transition logic" (phase prompt) | §2 grammar + §3 per-biome beacon Tier 0→4 descriptions. |
| "Do not make every consequence huge" (World Memory principle) | Memory marks are small (≤ 3 per zone); only Hearthwild 0→1 is intentionally loud. |
| "Do not force every biome to reach Tier 4" | Tier 4 is beacon-only rare variant; no zone requires it to read as complete. |
| Story tone "wonder + mystery + warmth + quiet danger" | Warm Hearthwild start, mystery in Glassroot/Verdant, danger in Ember (controlled), quiet in Engine. |
| Not a block-building clone | Woven-lattice motif, faceted-organic form language, no unit-block terrain (Direction Lock §3.2). |
| Save-safe, deterministic | §5 — presentation stores nothing; pure function of persisted state. |
