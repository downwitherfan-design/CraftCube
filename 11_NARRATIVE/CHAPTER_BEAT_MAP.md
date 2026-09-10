# Chapter Beat Map

**Owner:** AI-09 · **Status:** DRAFT v0.1.0 · Consumers: AI-03 (puzzle objectives per chapter), AI-05 (visual transformation), AI-08 (audio arc), AI-10 (fail-safe test)

This is a **purpose map**, not a content tree. Per `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §3 every chapter declares: emotional objective, gameplay objective (narrative framing only — puzzle mechanics are AI-03), visual transformation (intent only — AI-05), question introduced, question resolved/advanced, one memorable scene. Beat-level dialogue is written in later phases against these rows.

Biome names/IDs follow `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`. Mystery IDs are defined in `MYSTERY_PAYOFF_REGISTER.md`. Flags are in `CHARACTER_ARC_REGISTER.md`.

## Act I — Awakening (`nar.act.1`) — "Why does the world react to my hands?"

### Ch.01 First Light — `nar.chapter.01_first_light`
| Field | Value |
|---|---|
| Biome | Hearthwild (Tier 0 → 1) |
| Emotional objective | wonder; "it answered me" |
| Gameplay objective (framing) | wake two nodes; restore the walkway; reach the old road |
| Visual transformation | grey-green dormancy → first water, first growth, walkway rises |
| Question introduced | `nar.mystery.why_the_weaver` (why me?), `nar.mystery.who_built_the_loom` (the three-notch mark, planted silently) |
| Question advanced | — |
| Memorable scene | Nox forming out of the first lit channel |
| Character beats | Mira arrives; Orin's "put it back the way it was" |
| Scoped flag | `nar.flag.ch01_first_node_choice` {near, far} |
| Items (lore) | none acquired; the cube itself is `nar.item_lore.weaver_cube` |
| Fail-safe sentence | "I twisted a cube and the water came back; I don't know why it works for me." |

### Ch.02 The Broken Path — `nar.chapter.02_broken_path`
| Field | Value |
|---|---|
| Biome | Hearthwild (Tier 1 → 2) |
| Emotional objective | trust (Nox), competence |
| Gameplay objective (framing) | re-open the route to the Hearthwild heart-node; Nox learns to point at dormant nodes |
| Visual transformation | route segments re-align one by one; creatures return to restored pockets |
| Question introduced | `nar.mystery.where_did_everyone_go` (abandoned Weaver tools, no bodies, no graves — WR-4) |
| Question advanced | `nar.mystery.why_the_weaver`: Mira tries the cube, it stays dark |
| Memorable scene | Nox leading the player to a node Mira's map says doesn't exist |
| Character beats | Mira's map is wrong for the first time; Nox trust beat (`nar.flag.nox_trust_earned`) |
| Items (lore) | `nar.item_lore.tuning_fork` (found among abandoned tools — first *made* thing; provenance seed) |
| Fail-safe sentence | "I opened the path; Nox helps me find sleeping nodes; someone used to do this and they're gone." |

### Ch.03 Echoes in Stone — `nar.chapter.03_echoes_in_stone`
| Field | Value |
|---|---|
| Biome | Hearthwild heart (Tier 2 → 3), first Glassroot boundary visible |
| Emotional objective | curiosity turns to unease |
| Gameplay objective (framing) | align the heart-node; the alignment reveals a carved record |
| Visual transformation | Hearthwild flourishes; the heart-node's chamber wall reveals a *sequence* of three-notch marks in a pattern the player has just solved |
| Question introduced | `nar.mystery.loom_true_purpose` (the record shows the Loom *changing* configuration deliberately, not holding still) |
| Question advanced | `nar.mystery.who_built_the_loom`: marks are authored, not natural |
| Memorable scene | the carved pattern on the wall matches the player's own solved state |
| Character beats | Orin reads the record as "instructions for restoration"; Mira reads it as "a log of changes". First disagreement, mild. |
| Scoped flag | `nar.flag.first_record_interpretation` {orin, mira} — which reading the player endorses (dialogue-only consequence) |
| Items (lore) | `nar.item_lore.archive_thread` (first Memory Collectible) |
| Fail-safe sentence | "I fixed the Hearthwild; the builders left a record; Orin and Mira read it differently." |

## Act II — Fracture (`nar.act.2`) — "Was the Great Misalignment an accident?"

### Ch.04 Glassroot — `nar.chapter.04_glassroot`
| Field | Value |
|---|---|
| Biome | Glassroot (Tier 0 → 2) |
| Emotional objective | awe at memory; "the world remembers what I did" |
| Gameplay objective (framing) | crystals show echoes of prior states; the player must read a *remembered* arrangement to find the current one |
| Visual transformation | opaque crystal → translucent, showing frozen prior configurations |
| Question introduced | `nar.mystery.what_nox_is` (Nox reacts to an echo of a Weaver-shaped figure) |
| Question advanced | `nar.mystery.loom_true_purpose`: echoes show the Loom in *several* stable configurations over time — there was never one "right" state |
| Memorable scene | the player sees an echo of their own Ch.01 solution frozen in crystal |
| Character beats | Mira exhilarated (memory = mappable); Orin disturbed (which past should we restore?) |
| Items (lore) | `nar.item_lore.memory_lens` (chapter relic, first equipment with story function) |
| Fail-safe sentence | "The crystals remember every arrangement; there was more than one 'before'." |

### Ch.05 The Sunken Grid — `nar.chapter.05_sunken_grid`
| Field | Value |
|---|---|
| Biome | Sunken Grid (Tier 0 → 2) |
| Emotional objective | doubt; loyalty tested |
| Gameplay objective (framing) | sequence pumps/bridges to drain and reach the archive vault; order matters |
| Visual transformation | flooded dark → drained, lit grid; light networks re-thread |
| Question introduced | `nar.mystery.who_caused_misalignment` (the vault holds two records that contradict each other) |
| Question advanced | `nar.mystery.where_did_everyone_go`: the Weavers *left*, in order, deliberately |
| Memorable scene | Mira and Orin each pick up a different record and read aloud, and the records disagree |
| Character beats | Mira/Orin split becomes explicit. Player is asked nothing; but `nar.flag.vault_record_kept` {mira, orin} records which record the player carries out (both cannot be carried — a physical, not moral, constraint) |
| Items (lore) | `nar.item_lore.echo_compass` |
| Fail-safe sentence | "I drained the grid; the records contradict each other; the Weavers left on purpose." |

### Ch.06 Ember Hollow — `nar.chapter.06_ember_hollow`
| Field | Value |
|---|---|
| Biome | Ember Hollow (Tier 0 → 2) |
| Emotional objective | reframing; instability as tool |
| Gameplay objective (framing) | redirect heat channels; deliberately *mis*-align a node to open a temporary route |
| Visual transformation | choked ash → controlled forges, glowing temporary bridges |
| Question introduced | — (consolidation chapter) |
| Question advanced | `nar.mystery.loom_true_purpose`: the Loom *rewards* controlled misalignment here; the Misalignment may have been a use, not a break |
| Memorable scene | the first time the player intentionally breaks alignment and the world *helps* |
| Character beats | Orin, shaken, admits the old traditions never mentioned this biome. Nox thrives in instability (`nar.flag.nox_ember_awakening`) |
| Items (lore) | `nar.item_lore.ember_dial` |
| Fail-safe sentence | "Sometimes breaking the pattern on purpose is the right move; Orin's traditions don't cover this." |

### Ch.07 The Silent Engine — `nar.chapter.07_silent_engine`
| Field | Value |
|---|---|
| Biome | Quiet Engine outer ring (Tier 0 → 1) |
| Emotional objective | vertigo; the scale of the design |
| Gameplay objective (framing) | multi-state alignment; architecture rearranges as the player solves |
| Visual transformation | a city-sized mechanism turns for the first time in living memory |
| Question introduced | `nar.mystery.what_happens_if_completed` (the Engine has an unfinished final configuration) |
| Question advanced | `nar.mystery.who_built_the_loom` partial payoff: the three-notch mark is the builders' *signature for "intentional change"*, not decoration. `nar.mystery.who_caused_misalignment` partial payoff: the Weavers triggered it. |
| Memorable scene | Orin stands in the moving Engine and says nothing — his first silence |
| Character beats | Orin turning point (`nar.flag.orin_accepts_design`); Mira stops mapping and starts *listening* |
| Items (lore) | `nar.item_lore.quiet_coil` |
| Fail-safe sentence | "The Loom was built to change; the Weavers set the Misalignment off themselves; something is unfinished." |

## Act III — Reconciliation (`nar.act.3`) — "Should the world be restored exactly as it was?"

### Ch.08 The Unfinished Pattern — `nar.chapter.08_unfinished_pattern`
| Field | Value |
|---|---|
| Biome | Verdant Archive (Tier 0 → 3) |
| Emotional objective | mastery without certainty |
| Gameplay objective (framing) | long-range planning; roots encode a pattern that spans the biome |
| Visual transformation | dead roots → living archive that grows *toward* the player's solutions |
| Question introduced | — |
| Question advanced | `nar.mystery.what_nox_is` partial payoff: Nox's kind are what remained of the Weavers' *work*, not the Weavers. `nar.mystery.why_the_weaver` partial payoff: the Loom answers whoever plays *with* it rather than *at* it — ability is practice, not blood. |
| Memorable scene | the Archive shows the player their whole journey as one root-pattern |
| Character beats | Mira's turning point (`nar.flag.mira_stops_mapping`): she gives the player her map. Nox memory beat (`nar.flag.nox_memory_unlocked`) |
| Items (lore) | `nar.item_lore.rootweave_gauntlet`, `nar.item_lore.lumen_seed` |
| Fail-safe sentence | "I can read the whole pattern now; Nox is what the Weavers made; anyone who listens could do this." |

### Ch.09 The Last Alignment — `nar.chapter.09_last_alignment`
| Field | Value |
|---|---|
| Biome | Quiet Engine core (Tier 1 → 3) |
| Emotional objective | consequence; everything the player did is present |
| Gameplay objective (framing) | the Engine core reflects the player's *scoped flags* in its starting configuration (which records kept, which biomes flourished) |
| Visual transformation | the Engine re-assembles using pieces of every restored biome |
| Question introduced | — |
| Question advanced | `nar.mystery.who_caused_misalignment` final: the Weavers misaligned the Loom to *stop* it completing a configuration they did not understand — fear, not malice. `nar.mystery.what_happens_if_completed`: completing it lets the Loom compose new regions — the world is not finished. |
| Memorable scene | Orin, using the player's own words from Ch.03 (flag-dependent line), says the world "was never meant to be *back*" |
| Character beats | Orin payoff; Mira payoff; Nox reacts to the final configuration with the same flinch/brighten from Beat 3 — the language has not changed, only the scale |
| Items (lore) | `nar.item_lore.prism_key` (mastery relic, optional), `nar.item_lore.fracture_seal` |
| Fail-safe sentence | "The Weavers broke it because they were afraid; finishing it means the world keeps changing." |

### Ch.10 A World Rewritten — `nar.chapter.10_world_rewritten`
| Field | Value |
|---|---|
| Biome | all; epilogue states per biome tier |
| Emotional objective | authorship; peace with uncertainty |
| Gameplay objective (framing) | the final alignment is a *composition*, not a restoration: the player decides the Loom's resting configuration from a closed set |
| Visual transformation | epilogue world reflects the choice + biome tiers reached |
| Question resolved | `nar.mystery.loom_true_purpose` final reinterpretation: the Loom is an instrument, not a machine; "restore" was always the wrong verb |
| Scoped flag | `nar.flag.final_configuration` {hold, weave, open} — see `OPEN_DECISIONS_AI09.md` OD-04 for approval status of the three options |
| Memorable scene | Nox chooses to stay or to disperse into the new pattern (flag-dependent, never sad — WR-4) |
| Items (lore) | none new; every relic's lore entry gains its epilogue line |
| Fail-safe sentence | "I chose what shape the world settles into; I understand why the last Weavers couldn't." |
| Intentionally unresolved | `nar.mystery.who_built_the_loom` — *who* remains unknown by design; only *what they intended* is answered. Flagged `INTENTIONALLY_UNRESOLVED` in the register for potential post-launch content. |

## Cross-chapter checks (for AI-10)

1. Every `nar.mystery.*` introduced in a chapter above appears with ≥ 1 "advanced" row later and exactly one "final" row, or is marked `INTENTIONALLY_UNRESOLVED`.
2. Every `nar.flag.*` set in a chapter is *read* in at least one later chapter (no orphan consequence).
3. No chapter's fail-safe sentence depends on an optional item or optional dialogue.
4. Total flag count ≤ 12 (current: 10; see `CHARACTER_ARC_REGISTER.md`).
