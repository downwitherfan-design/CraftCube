# Mystery / Foreshadowing / Payoff Register

**Owner:** AI-09 · **Status:** DRAFT v0.1.0 · Consumers: AI-03 (which chapter must contain which clue), AI-05 (environmental clue placement intent), AI-08 (audio foreshadowing intent), AI-10 (coverage test)

Rule (Story Bible, `V7_1_WORLDCLASS_UPGRADE.md` §3.3): a mystery may not appear in final content until its row has **setup, reinforcement, false lead / uncertainty, partial payoff, final reinterpretation** — or is explicitly `INTENTIONALLY_UNRESOLVED`. Every clue names its **channel** (gameplay / environment / dialogue / item / companion / audio) so that critical information is carried by >= 2 channels (`STORY_CONTENT_ARCHITECTURE.md` §7).

Chapter IDs: `CHAPTER_BEAT_MAP.md`. Motif IDs: `ENVIRONMENTAL_STORYTELLING_VOCABULARY.md`. Item lore IDs: `NARRATIVE_ITEM_LEDGER.md`.

## Mystery ladder

The Game Master Bible §7 defines a three-layer mystery: *What happened? Who caused it? What was the Loom designed to become?* The register decomposes these into seven trackable mysteries. Layer mapping is given per row.

| ID | Question (player-facing phrasing) | Layer | Status |
|---|---|---|---|
| `nar.mystery.why_the_weaver` | Why does the Loom answer me and almost nobody else? | personal | COMPLETE |
| `nar.mystery.who_built_the_loom` | Who left the three-notch mark? | who | INTENTIONALLY_UNRESOLVED (identity) / COMPLETE (intent) |
| `nar.mystery.where_did_everyone_go` | Where are the Weavers? Why tools but no people? | what | COMPLETE |
| `nar.mystery.loom_true_purpose` | Was the Loom built to hold the world still? | designed-to-become | COMPLETE (spine mystery) |
| `nar.mystery.who_caused_misalignment` | Was the Great Misalignment an accident? Who did it? | who / what | COMPLETE |
| `nar.mystery.what_nox_is` | What is Nox, and why does it recognise things? | personal | COMPLETE |
| `nar.mystery.what_happens_if_completed` | What happens if the Engine's unfinished configuration is finished? | designed-to-become | COMPLETE |

"COMPLETE" means the *plan* is complete (all five stages designed), not that content exists.

---

## `nar.mystery.why_the_weaver` — Why me?

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 01 | The cube lights at the player's touch; Mira: "It doesn't answer me. It doesn't answer anyone." | gameplay, dialogue |
| Reinforcement | 02 | Mira tries the cube on-screen; it stays dark. Nox approaches the player, not Mira. | gameplay, companion |
| False lead / uncertainty | 03–05 | Orin assumes bloodline ("You must be of the old Weaver lines"). Crystal echo in Ch.04 shows a Weaver-shaped figure — *looks* like heritage. | dialogue, environment |
| Partial payoff | 08 | Verdant Archive shows the player's whole journey as one root-pattern; Mira gives up her map: "You don't need it. I think I never did." Implication: the difference is *how one listens*, not who one is. | environment, dialogue, item (`nar.item_lore.rootweave_gauntlet`) |
| Final reinterpretation | 10 | Orin (if `nar.flag.orin_accepts_design`) asks Nox to teach him to listen; epilogue shows a second dim node lighting far away for someone else. Ability is practice, not blood. Nobody is chosen. | environment, dialogue, companion |
| Fail-safe | Main path carries setup (01), reinforcement (02) and partial (08) without optional content. |

## `nar.mystery.who_built_the_loom` — The three-notch mark

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 01 | `nar.motif.three_notch_mark` lights on the first node at the moment of alignment. Nobody comments. | environment, audio (mark lights on `nar.motif.alignment_chord`) |
| Reinforcement | 02–03 | Mark appears on abandoned Weaver tools (`nar.item_lore.tuning_fork`); Ch.03 heart-node wall shows marks in an *authored sequence*. Orin: "The builders' sign." | item, environment, dialogue |
| False lead / uncertainty | 05 | Vault records disagree: one attributes the marks to "the Architect", singular; the other to "those who wove", plural. Orin's own staff carries a *fourth* notch he added — tradition is already interpretation. | item, environment |
| Partial payoff | 07 | In the Engine the mark appears only on components that *move*. Mira: "It's not a name. It's a note — 'this part is meant to change'." | environment, dialogue |
| Final (intent) | 10 | Every mark in the world lights in sequence as the final configuration settles. The builders intended change; Nox carries the mark faintly on its back — it is *signed* work. | environment, companion, audio |
| INTENTIONALLY_UNRESOLVED (identity) | — | Who the builders were is never stated. Reserved for potential post-launch content. Design choice (WR-7), recorded here so it is not mistaken for a missing payoff. |

## `nar.mystery.where_did_everyone_go` — Tools but no people

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 02 | Abandoned Weaver tools laid down *neatly* along the route — not dropped. No bodies, no graves, no damage to dwellings (WR-4). | environment, item |
| Reinforcement | 03 | Heart-node record ends mid-sequence, cleanly, as if paused. | environment |
| False lead / uncertainty | 04 | Glassroot echo of a Weaver figure *walking away* from a node — flight or decision? Nox reacts strongly (seeds `what_nox_is`). | environment, companion |
| Partial payoff | 05 | Vault: the Weavers left in an *order*, biome by biome, after deliberately misaligning each region. They chose to go. Records disagree on *why*. | item, dialogue (Mira/Orin read aloud) |
| Final reinterpretation | 09 | They left because they feared what the completed Engine would do (see `who_caused_misalignment`). Their leaving was an act of care, not abandonment. `nar.item_lore.fracture_seal` provenance. | environment, item, dialogue |
| Fail-safe | Setup (02) and partial (05) are main-path. |

## `nar.mystery.loom_true_purpose` — Was it built to hold the world still? (SPINE)

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 01 | Orin: "We can put the world *back* the way it was." The word *back* is planted; the world's response to the player is *growth*, not reversion (new plants, not old plants). | dialogue, environment |
| Reinforcement | 03 | Heart-node record shows the Loom *changing* configuration over time, deliberately. Orin: "instructions for restoration." Mira: "a log of changes." Player endorses one (`nar.flag.first_record_interpretation`). | environment, dialogue |
| False lead / uncertainty | 04 | Glassroot remembers *several* stable pasts. Which one is "back"? The false lead is that the *right past* merely needs to be identified. | environment, item (`nar.item_lore.memory_lens`), dialogue |
| Reinforcement 2 | 06 | Ember Hollow rewards deliberate misalignment. A machine built to hold still would not do this. Orin admits the traditions do not cover it. | gameplay, dialogue, companion (`nar.flag.nox_ember_awakening`) |
| Partial payoff | 07 | The Engine turns. The mark means "meant to change". Orin: "This was never still." (`nar.flag.orin_accepts_design`) | environment, dialogue, audio (`nar.motif.orin_phrase` gains its resolving note) |
| Final reinterpretation | 10 | The final alignment is a *composition* from a closed set, not a restoration. The Loom is an instrument, not a machine; "restore" was the wrong verb from the first line of the game. | gameplay, environment, dialogue |
| Fail-safe | Every stage is main-path. This is the one mystery the player cannot miss. |

## `nar.mystery.who_caused_misalignment` — Accident or act?

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 03 | The record ends cleanly — no sign of catastrophe in the stone. | environment |
| Reinforcement | 05 | Two vault records: one calls the Misalignment "the Failing"; the other "the Unweaving" — a verb someone *did*. | item, dialogue |
| False lead / uncertainty | 05–06 | Orin's reading: sabotage by outsiders. Mira's reading: an accident during a change. Both wrong. Player carries one record out (`nar.flag.vault_record_kept`). | dialogue |
| Partial payoff | 07 | Engine outer ring: the misalignment pattern in each biome matches the *Weavers' own* tool-marks, not damage. They did it. | environment, item (`nar.item_lore.quiet_coil`) |
| Final reinterpretation | 09 | They did it out of *fear*: the Engine approached a configuration none of them could read, and they stopped it the only way they knew — by unweaving every region and leaving. Not malice, not accident: caution. Orin uses the player's own Ch.03 words back to them. | environment, dialogue, item (`nar.item_lore.fracture_seal`) |
| Fail-safe | Setup (03), partial (07), final (09) are main-path. |

## `nar.mystery.what_nox_is`

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 01 | Nox forms *out of* the first lit channel — it is made of alignment. | environment, companion |
| Reinforcement | 02 | Nox can find dormant nodes Mira cannot map. It hears what she cannot see. | gameplay, companion |
| False lead / uncertainty | 04 | Nox reacts to the echo of a Weaver figure — recognition? memory? Is Nox *a* Weaver, transformed? (Orin suggests as much.) | environment, companion, dialogue |
| Partial payoff | 08 | Verdant Archive: Nox's kind are what remained of the Weavers' *work* — living fragments of the patterns they wove, not the people. Nox leads the player to the root where its own pattern began (`nar.flag.nox_memory_unlocked`). | environment, companion |
| Final reinterpretation | 10 | Nox carries the three-notch mark. It is *signed* — made deliberately, by the same intent that made the Loom. In the epilogue it stays or joins the new pattern; either way it was never lost property, it was a message. | companion, environment, audio (`nar.motif.nox_call` resolves to the full chord) |
| Fail-safe | Setup (01), reinforcement (02), partial (08) main-path. |

## `nar.mystery.what_happens_if_completed`

| Stage | Chapter | Clue | Channels |
|---|---|---|---|
| Setup | 07 | The Engine has an unfinished final configuration; its slot is empty, marked. | environment |
| Reinforcement | 08 | The Archive's root-pattern grows *toward* the empty configuration — the world is waiting for it. | environment |
| False lead / uncertainty | 08–09 | Orin's fear (inherited from the Weavers): completion = the end of the world as it is. Which is *true*, but not in the way he fears. | dialogue |
| Partial payoff | 09 | Core: completion lets the Loom *compose* — new regions, new rules. The Weavers stopped it because they could not read it. The player can. | gameplay, environment |
| Final reinterpretation | 10 | The player chooses the resting configuration (`nar.flag.final_configuration`). Completion is not an ending; it is a beginning the player authors. | gameplay, environment, dialogue |
| Fail-safe | All stages main-path (Act III). |

---

## Coverage checks (for AI-10)

1. Every mystery has all five stages or an explicit `INTENTIONALLY_UNRESOLVED` component. (7/7 by inspection of this document.)
2. Every stage lists >= 1 channel; every setup/partial/final stage lists >= 2 channels.
3. Every chapter 01–10 carries at least one stage of at least one mystery (no "dead" chapter) — cross-check `CHAPTER_BEAT_MAP.md`.
4. No mystery's final reinterpretation is delivered solely by dialogue.
5. The spine mystery (`loom_true_purpose`) has every stage on the main path.

These are design-review checks. Machine-checked facts (ID uniqueness, cross-reference integrity) are covered by `tools/validate_narrative_registry.py`.
