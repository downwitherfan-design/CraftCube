# First Ten Minutes — Narrative Experience (Chapter 01 opening)

**Owner:** AI-09 · **Status:** DRAFT v0.1.0 · **Chapter:** `nar.chapter.01_first_light`
**Scope:** narrative meaning, beat order, dialogue budget and what the player must *understand*. Puzzle difficulty (AI-03), touch/camera (AI-04), world presentation (AI-05), Nox animation (AI-06), UI (AI-07) and audio (AI-08) are referenced by intent only.

## Target

`00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §14 requires the first 10 minutes to communicate six things without a lore introduction. This document maps each beat to those six requirements (R1–R6):

| # | Requirement |
|---|---|
| R1 | what the player controls |
| R2 | why the cube matters |
| R3 | that actions alter the world |
| R4 | that the world has a mystery |
| R5 | that the player has meaningful choices |
| R6 | that progression is more than numbers |

## Hard budgets (Phase 00 proposal)

- Total on-screen narrative text before the first puzzle interaction: **0 lines**.
- Total dialogue lines in the first ten minutes: **≤ 14** (Mira ≤ 8, Orin ≤ 4, system/world ≤ 2). Nox has no text.
- No line may exceed ~90 characters in English source (mobile portrait, localization expansion ≈ +35%).
- No cutscene longer than the time it takes the world to visibly change (target ≤ 6 s per transformation).
- Zero mandatory reading. Every R1–R6 requirement is also carried by a non-text channel (`STORY_CONTENT_ARCHITECTURE.md` §7).

## Beat sequence

Time marks are targets for the whole session, not per-beat hard limits. Beats are stable IDs so AI-03/AI-08/AI-10 can reference them.

### Beat 1 — Cold open: the cube in the moss (`nar.beat.01.cube_in_moss`) — 0:00–0:30
- **What the player sees:** Hearthwild at Tier 0 (dormant): grey-green, still water, no birdsong. A small cube-like device half-buried, one face faintly lit.
- **What the player does:** touches it. Nothing else is interactable. The first touch rotates one layer.
- **Meaning delivered:** R1 (I control the cube by touching/twisting). R2 seeded (it is the only living thing here).
- **Text:** none.
- **Non-text channel:** the lit face pulses in the same rhythm as a faint hum (audio motif `nar.motif.loom_hum`, AI-08 intent).

### Beat 2 — The cube answers (`nar.beat.01.cube_answers`) — 0:30–2:30
- **What the player does:** completes a trivially-scoped first alignment (AI-03 owns the exact puzzle; narrative requirement is only that it be *completable by observation* and take under two minutes for a first-time player).
- **What the world does:** the node beneath the cube lights; a single water channel a few metres away begins to flow; one plant unfurls. Small, close, visible.
- **Meaning delivered:** R2, R3. "The cube *did* that."
- **Text:** none. Player must not be told; they must see.
- **Non-text channel:** the hum resolves to a consonant chord (`nar.motif.alignment_chord`); the *three-notch mark* on the node (`nar.motif.three_notch_mark`) lights — its first appearance, planted for the Architect mystery (`nar.mystery.who_built_the_loom` setup clue).

### Beat 3 — Something small is watching (`nar.beat.01.nox_appears`) — 2:30–3:30
- **What happens:** Nox (`nar.character.nox`) forms from the light of the newly-lit channel — it is *made of* residual alignment (WR-5). It approaches the cube, not the player.
- **What the player does:** nothing required. If they touch the cube, Nox flinches at a wrong turn and brightens at a right one (first companion reaction; AI-06 owns presentation, AI-02 owns the state that triggers it).
- **Meaning delivered:** R6 (something in this world responds to *how well* I play, not to a score). Attachment seed.
- **Text:** none. Nox never speaks.

### Beat 4 — Mira arrives, already writing (`nar.beat.01.mira_arrives`) — 3:30–5:00
- **What happens:** Mira (`nar.character.mira`) enters, sketching the flowing channel before she looks at the player. She is not surprised the channel flows; she is surprised *who* did it.
- **Dialogue (DRAFT, ≤ 4 lines, keys `loc.dlg.ch01.mira.arrive.*`):**
  1. "That channel's been dry since before I was born. Did you—?"
  2. "You *touched* it and it answered? It doesn't answer me. It doesn't answer anyone."
  3. "I'm Mira. I map what changes. Lately nothing does. Until now, apparently."
  4. (looking at Nox) "…and *that* is new."
- **Meaning delivered:** R4 (why does it answer *me*? — `nar.mystery.why_the_weaver` setup clue). Mira's function (context, not tutorial) established.
- **Rule check:** none of these lines explains a mechanic the player has not already performed.

### Beat 5 — The broken path (`nar.beat.01.broken_path_shown`) — 5:00–6:30
- **What the player sees:** the route out of the clearing is a collapsed stone walkway. Two dormant nodes flank it, each with the three-notch mark, one faint, one dark.
- **What Mira says (≤ 2 lines, `loc.dlg.ch01.mira.path.*`):**
  1. "Two nodes. I've only ever seen one wake at a time — if they wake at all."
  2. "Try the near one. I'll watch what happens to the far one."
- **Meaning delivered:** R5 seeded — the player will pick *which* node first (this is the first scoped choice, `nar.flag.ch01_first_node_choice`, enum {near, far}). Both are solvable; the choice only changes which part of the walkway restores first and one later Mira line. It is deliberately low-stakes so the player learns choices exist without fear.
- **Non-text channel:** the faint node pulses in time with the hum; the dark one is silent. Audio tells the player which is "closer to alive".

### Beat 6 — Second alignment, larger consequence (`nar.beat.01.walkway_restores`) — 6:30–8:30
- **What the player does:** solves the chosen node's puzzle (AI-03: slightly larger scope than Beat 2, still observation-solvable).
- **What the world does:** half the walkway rises and re-aligns. The *other* node brightens by itself (WR-2: restoration radiates). Nox runs onto the restored section and looks back.
- **Meaning delivered:** R3 reinforced with persistence — if the player turns around, the first channel is still flowing (world memory, `WORLD_BIOME_BIBLE_V7.md`). R6: the reward is a *place*, not a number.
- **Text:** none during the transformation. Afterwards, Mira, one line (`loc.dlg.ch01.mira.radiate`): "It woke the other one. They're… connected. I never had that on a map."

### Beat 7 — Orin at the threshold (`nar.beat.01.orin_threshold`) — 8:30–10:00
- **What happens:** Orin (`nar.character.orin`) is waiting where the walkway meets the old road. He has heard the chord from far off. He is not hostile; he is moved, and certain.
- **Dialogue (DRAFT, ≤ 4 lines, `loc.dlg.ch01.orin.threshold.*`):**
  1. "I have waited a long time to hear that sound again."
  2. "The Loom is waking. We can put the world back the way it was."
  3. "Everything in its place. Every path where it belonged."
  4. "Come. There is a great deal to restore."
- **Meaning delivered:** R4 deepened — Orin's certainty ("the way it was") is the *false interpretation* the whole game will examine (`nar.mystery.loom_true_purpose`, setup of the false lead). The player is not told he is wrong; the word "back" is simply planted.
- **Chapter hand-off:** the player is now on the road with Nox and a stated goal. Chapter 01 continues; the first ten minutes end here.

## Verification checklist (for AI-10 / playtest)

A first-time player, after 10 minutes and with all optional text skipped, should be able to answer:

| Question | Expected answer (paraphrase) | Requirement |
|---|---|---|
| What do you control? | The cube — I twist it. | R1 |
| Why does the cube matter? | When I get it right the world fixes itself around it. | R2/R3 |
| Did anything you did stay changed? | Yes — the water is still running / the path is still up. | R3 |
| Is there something you don't understand yet? | Why it answers me and not Mira. / What the mark means. / Who Orin means by "back". | R4 |
| Did you make any choice? | Which node I did first. | R5 |
| Did you get a score/points/level? | No — I got a path and a little creature. | R6 |

Any "no / don't know" on R1–R4 is a design failure of this document or its downstream implementation, not of the player.

## Explicit non-decisions

- Exact puzzle sizes in Beats 2 and 6: AI-03.
- Whether Nox is visible on the HUD or only in-world: AI-07 with AI-06.
- Whether Beat 4 dialogue is a modal, a speech bubble or subtitles: AI-07. Narrative constraint only: non-blocking where possible, skippable always.
- Whether any line is voiced: Product decision; text is written to work unvoiced.
