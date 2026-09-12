# Environmental Storytelling Vocabulary

**Owner:** AI-09 (meaning) · **Status:** DRAFT v0.1.0
**Realisation owners:** AI-05 (environment/material/lighting), AI-06 (creature/companion/VFX), AI-08 (audio). This document defines *what each recurring element means and when it may appear*; it defines no asset, shader, mesh, cue file or mix value.

Purpose: every track that places a symbol, colour shift, sound or creature behaviour in the world must be saying the same thing. A motif used inconsistently is a false clue.

## Motif register

| ID | Motif | Meaning (canon) | Channel | First appears | Must NOT appear |
|---|---|---|---|---|---|
| `nar.motif.three_notch_mark` | three parallel notches in a corner | "this part is meant to change" — the builders' note of intent (revealed Ch.07; players read it as a signature until then) | visual (environment, items, Nox) | Ch.01 first node | on anything static/decorative; on anything not Loom-made |
| `nar.motif.fourth_notch` | a fourth notch, clearly newer | interpretation added onto intent — tradition | visual (Orin's staff only) | Ch.01 (background), noticed Ch.05 | anywhere except Orin's staff |
| `nar.motif.scratched_mark` | three-notch mark scratched out | the Weavers' refusal / apology | visual | Ch.09 `fracture_seal`, Engine misalignment points | before Ch.07 |
| `nar.motif.loom_hum` | low sustained hum from dormant/near-active nodes | the Loom is present and listening | audio | Beat `nar.beat.01.cube_in_moss` | in fully dormant Tier 0 areas with no node |
| `nar.motif.alignment_chord` | the hum resolving to a consonant chord | a node recognised an arrangement | audio | Beat `nar.beat.01.cube_answers` | on any non-alignment event (rewards, UI) |
| `nar.motif.misalignment_tone` | chord bending flat, not dissonant | intentional instability (Ember Hollow onward) — *useful*, not wrong | audio | Ch.06 | Ch.01–05 (there, misalignment is simply silence) |
| `nar.motif.nox_call` | two-note chirp = fragment of the alignment chord | Nox is a fragment of the Loom's work | audio (companion) | Ch.01 | resolved to full chord before Ch.10 |
| `nar.motif.mira_phrase` | light curious woodwind phrase | mapping, curiosity | audio (character) | Ch.01 Mira arrival | after `nar.flag.mira_stops_mapping` in its original form — it should become unfinished/open |
| `nar.motif.orin_phrase` | low bowed-string phrase without resolution | certainty carried as weight | audio (character) | Ch.01 threshold | resolved before `nar.flag.orin_accepts_design` |
| `nar.motif.neat_toolline` | tools laid down in a row, undamaged | the Weavers *left*; nobody died | visual (environment, items) | Ch.02 | with any sign of violence, decay of bodies, graves |
| `nar.motif.echo_state` | translucent frozen copy of a prior arrangement | the world remembers (WR-3) | visual (Glassroot; later anywhere via `memory_lens`) | Ch.04 | before Ch.04 except as a single unexplained glimpse in Ch.03 (optional) |
| `nar.motif.growth_not_reversion` | restored areas grow *new* forms, not copies of ruins | "back" is the wrong verb | visual (all biomes) | Ch.01 | never show a restoration that reproduces a ruin's original silhouette exactly |
| `nar.motif.empty_slot` | a marked, clearly-shaped empty socket | unfinished configuration; the world waiting | visual | Ch.07 Engine | filled before Ch.10 |
| `nar.motif.creature_return` | native creatures re-enter an area only after restoration | the world is safe again here; persistent proof of player action | visual/audio (creatures) | Ch.01 Beat 6 (one creature) | creatures present in Tier 0 dormant zones |

## Colour / material grammar (intent for AI-05)

Meaning only; palettes are AI-05's.

| State | Grammar |
|---|---|
| Tier 0 dormant | desaturated, still, no specular life; the mark unlit |
| Tier 1 awakened | a single warm accent at the node; the mark lit; one moving element (water/light) |
| Tier 2 recovering | accent spreads along Loom lines; new growth forms visibly different from ruins |
| Tier 3 flourishing | biome's own identity colour dominant; creatures present |
| Tier 4 mastered/rare | one *unexpected* colour — something the biome never showed before (mirrors "compose, not restore") |
| Intentional misalignment (Ch.06+) | warm-hot, never red-alarm; it must read as *useful* |
| Echo state | translucent, slightly delayed, monochrome of the biome's Tier 3 colour |

## Before / after rule

Every restored space must keep at least one **visible remnant of its dormant state** within view of the restored element (a dry channel-bed next to the flowing one; a dark node next to the lit one). This is how world memory stays legible without text. AI-05 owns how; AI-09 owns that it must.

## Creature behaviour grammar (intent for AI-06)

| Behaviour | Meaning |
|---|---|
| creatures absent | dormant / unsafe |
| creatures return after alignment | persistent proof of the player's action |
| creatures gather at a node | a node is *near* alignment (optional soft hint; never required) |
| creatures flee from intentional misalignment (Ch.06+) then return | instability is real, and it passes |
| Nox flinch / brighten | move quality feedback — the only per-move companion reaction allowed (protects puzzle mastery: it comments, it does not solve) |
| Nox silence | fear — used exactly once (`quiet_coil`) |

## Audio motif rules (intent for AI-08)

1. The alignment chord is sacred: it plays only when a node recognises an arrangement. Never for UI, rewards or menus.
2. Character phrases evolve with flags, not with chapters — so a player who triggers `orin_accepts_design` hears the resolution at that moment.
3. `nox_call` completes to the full chord once, in Ch.10.
4. Misalignment before Ch.06 is *silence*, not a wrong-sound. The game must never scold a wrong move.

## Anti-patterns (all tracks)

- Text on walls that explains anything. Marks, not words.
- Skeletons, graves, blood, battle damage (WR-4).
- Any motif above used as decoration where its meaning does not apply.
- Holograms, voice logs, journals of the Architect (Character Arc Register, Arc 4).
- A "collapse" or "corruption" visual that reads as evil. Dormancy is sleep, not death.

## Cross-reference

Each motif ID is present in `fixtures/narrative_canon_registry.v0.1.0.json`. Mysteries that rely on a motif name it in `MYSTERY_PAYOFF_REGISTER.md`; the validator checks that every motif referenced there exists here.
