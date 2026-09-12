# Narrative Item / Relic Lore Ledger

**Owner:** AI-09 (lore, provenance, narrative purpose, companion-reaction *eligibility*) · **Status:** DRAFT v0.1.0
**Not owned here:** item definitions, effects, balance, state (AI-02 `ItemDefinition` / `ItemIdentity` / `EquipmentEffect`); puzzle usage (AI-03); runtime use (AI-04); inventory UX (AI-07).

## Relationship to AI-02 item IDs

`ItemDefinition` IDs do not yet exist in the repository (VERIFIED: no item schema or catalog with IDs is present). This ledger therefore keys entries by **`nar.item_lore.<slug>`** and records a `proposed_item_slug` that AI-02 may adopt or map. The lore ID remains stable even if AI-02 chooses a different item ID; the mapping lives in the canon registry fixture (`item_ref` field, currently `PROPOSED`).

Candidates are drawn from `01_PREPRODUCTION/ITEM_CATALOG_STARTER_SET.md` (the seed set AI-01/AI-09 may rename, merge or reject). Phase 00 decision by AI-09 on the seed set: **keep 11, merge 1** — *Wayfinder Shard* is merged into Nox's sensing role (companion already "reveals direction to unresolved discovery"; a second system for the same semantic responsibility violates the anti-duplication rule). Recorded as `nar.item_lore` rejection below; AI-01 may overrule (OD-05).

## Relic philosophy (canon)

A relic is **a way of listening to the Loom that someone before you invented.** Consequences:
- Every relic carries evidence about its maker → items deliver the Architect/Weaver mysteries without narration.
- Relics change what the player can *perceive, reach or risk*; never what the puzzle *is* (DD-002).
- A relic's lore entry has an **epilogue line** that changes with `nar.flag.final_configuration` — the same object means something different depending on what the player chose. Attachment through memory, not stats (Equipment Bible "Item memory").
- Naming: plain material + function ("Memory Lens", "Ember Dial"). No invented-language words; localizable as compounds.

## Required card (from Story Bible "Item storytelling" + `V7_1` §5.1, narrative fields only)

physical identity · provenance · first discovery scene · functional use (narrative framing) · world connection · mystery served · companion reaction eligibility · epilogue variation · tier

Tiers follow `NARRATIVE_ITEM_INTEGRATION.md`: common utility / named artifact / chapter relic / mastery relic.

---

## `nar.item_lore.weaver_cube` — the cube itself
| Field | Value |
|---|---|
| proposed_item_slug | `weaver_cube` (may be a core object, not an inventory item — AI-02 decision) |
| Tier | chapter relic (unique, Ch.01) |
| Physical identity | palm-sized cube-like device; faces dim until touched; the three-notch mark on one corner |
| Provenance | Weaver-made. It is *not* the Loom; it is a tuning instrument that speaks the Loom's language locally. Left behind neatly in Ch.01 like all the other tools. |
| First discovery | Beat `nar.beat.01.cube_in_moss` |
| Functional use (framing) | the puzzle. The player's whole competence is expressed through it. |
| World connection | every node; the cube is the key that fits all locks because it speaks, rather than unlocks |
| Mysteries served | `why_the_weaver` (setup), `where_did_everyone_go` (it was left, not lost) |
| Companion reaction | eligible — Nox approaches the cube before the player (Ch.01) |
| Epilogue variation | `hold`: rests on the Hearthwild heart-node. `weave`: its faces stay lit. `open`: it goes dark — no longer needed; the world speaks without it. |

## `nar.item_lore.tuning_fork`
| Field | Value |
|---|---|
| proposed_item_slug | `tuning_fork` · Family: Tool · Tier: named artifact |
| Physical identity | two-pronged bronze-like fork; the mark on its stem; worn grip |
| Provenance | a working Weaver's daily tool; found in Ch.02 among tools laid down in order |
| First discovery | Ch.02, the abandoned tool line |
| Functional use (framing) | identifies which nearby structures are Loom-compatible — hearing resonance before seeing it |
| World connection | Hearthwild tool-line; later, marks on the Engine |
| Mysteries served | `who_built_the_loom` (reinforcement), `where_did_everyone_go` (setup) |
| Companion reaction | eligible — Nox hums with it when it resonates |
| Epilogue | `hold`: "it still hums at the old nodes." `weave`/`open`: "it hums at new places no Weaver ever walked." |

## `nar.item_lore.archive_thread`
| Field | Value |
|---|---|
| proposed_item_slug | `archive_thread` · Family: Memory Collectible · Tier: common utility (collectible series) |
| Physical identity | short lengths of fibre-like Loom residue holding a fragment of pattern |
| Provenance | shed by the Loom at moments of change; the Weavers collected them as records |
| First discovery | Ch.03, heart-node chamber |
| Functional use (framing) | optional; reconstructs a historical fragment when read — always *partial*, so lore stays inference (WR-6) |
| World connection | every biome has threads; their content is biome-specific |
| Mysteries served | optional depth for all seven; never main-path evidence |
| Companion reaction | not eligible (collectible; keep Nox reactions scarce and meaningful) |
| Epilogue | collection page gains one closing thread whose content depends on `final_configuration` |

## `nar.item_lore.memory_lens`
| Field | Value |
|---|---|
| proposed_item_slug | `memory_lens` · Family: Resonator · Tier: chapter relic (Ch.04) |
| Physical identity | a disc of Glassroot crystal in a wire cradle; shows echoes when held to a structure |
| Provenance | Weaver-cut from a crystal that had *already* recorded many states — it was made to compare pasts, not to find "the" past |
| First discovery | Ch.04, inside a crystal that reveals it only after the player reads a remembered arrangement |
| Functional use (framing) | reveals echoes of previous world states — information, not solution |
| World connection | Glassroot memory; later shows the player their *own* prior solutions anywhere |
| Mysteries served | `loom_true_purpose` (false lead: which past?), `why_the_weaver` (false lead: Weaver echo) |
| Companion reaction | eligible — Nox reacts to the Weaver-figure echo (Ch.04) |
| Epilogue | `hold`: shows only the resting state. `weave`: shows the sequence of every state. `open`: shows nothing — "there is no past to compare against yet." |

## `nar.item_lore.echo_compass`
| Field | Value |
|---|---|
| proposed_item_slug | `echo_compass` · Family: Tool · Tier: named artifact |
| Physical identity | flat compass whose needle points to *difference*, not north |
| Provenance | Sunken Grid engineers' tool for checking a pump sequence against its recorded sequence |
| First discovery | Ch.05, on the first drained platform |
| Functional use (framing) | compares present state with a remembered state; sequencing aid |
| World connection | Sunken Grid light-network |
| Mysteries served | `who_caused_misalignment` (the two records differ — the compass literally shows the disagreement) |
| Companion reaction | not eligible |
| Epilogue | needle rests still under `hold`; spins slowly under `open` |

## `nar.item_lore.ember_dial`
| Field | Value |
|---|---|
| proposed_item_slug | `ember_dial` · Family: Field Module · Tier: chapter relic (Ch.06) |
| Physical identity | heat-darkened dial with a *deliberately* offset scale |
| Provenance | the only Weaver tool built to *mis*-align on purpose — proof the Weavers knew instability was useful |
| First discovery | Ch.06, at the first controlled forge |
| Functional use (framing) | temporarily redirects or stabilises unstable heat channels; risk/reward |
| World connection | Ember Hollow temporary routes |
| Mysteries served | `loom_true_purpose` (reinforcement 2) |
| Companion reaction | eligible — Nox's polarity change (`nar.flag.nox_ember_awakening`) is triggered around first use |
| Epilogue | `hold`: cools. `weave`: warm. `open`: "still warm, still turning." |

## `nar.item_lore.quiet_coil`
| Field | Value |
|---|---|
| proposed_item_slug | `quiet_coil` · Family: Resonator · Tier: chapter relic (Ch.07) |
| Physical identity | a coil of Engine wire that hums when an anomaly is near |
| Provenance | cut from the Engine by the Weavers when they stopped it — a *piece of the thing they feared*, kept |
| First discovery | Ch.07, at the empty final-configuration slot |
| Functional use (framing) | stabilises a temporary anomaly; timing/precision |
| World connection | Quiet Engine |
| Mysteries served | `who_caused_misalignment` (partial: tool-marks match Weaver tools), `what_happens_if_completed` (setup) |
| Companion reaction | eligible — Nox goes silent near it (its only fear reaction in the game) |
| Epilogue | returned to the Engine under `hold`/`weave`; carried out under `open` |

## `nar.item_lore.rootweave_gauntlet`
| Field | Value |
|---|---|
| proposed_item_slug | `rootweave_gauntlet` · Family: Tool · Tier: chapter relic (Ch.08) |
| Physical identity | glove grown, not made — living Archive root shaped to a hand |
| Provenance | the Archive *grows one* for whoever reads its pattern; the Weavers' were left on the roots like shed skins |
| First discovery | Ch.08, grows onto the player's hand at the end of the long-range pattern |
| Functional use (framing) | controlled interaction with living structures |
| World connection | Verdant Archive |
| Mysteries served | `why_the_weaver` (partial: the Archive fits *anyone who listens*) |
| Companion reaction | eligible — Nox recognises the roots (`nar.flag.nox_memory_unlocked` beat) |
| Epilogue | `hold`: hardens to wood. `weave`: keeps growing. `open`: takes root somewhere new. |

## `nar.item_lore.lumen_seed`
| Field | Value |
|---|---|
| proposed_item_slug | `lumen_seed` · Family: Relic · Tier: mastery relic (optional, Ch.08) |
| Physical identity | a seed of light; warm; heavier than it looks |
| Provenance | the Loom's own output — what it produces when a configuration is *complete*. The Weavers never saw one. |
| First discovery | Ch.08, optional mastery challenge reward |
| Functional use (framing) | restores a small world node of the player's choosing — visible, persistent growth |
| World connection | any dormant node the player picks (one scoped, persistent world-memory consequence) |
| Mysteries served | `what_happens_if_completed` (reinforcement — proof the Loom *makes*) |
| Companion reaction | eligible — Nox's brightest reaction |
| Epilogue | the node it restored is mentioned by Mira in the epilogue regardless of `final_configuration` |

## `nar.item_lore.prism_key`
| Field | Value |
|---|---|
| proposed_item_slug | `prism_key` · Family: Relic · Tier: mastery relic (optional, Ch.09) |
| Physical identity | a many-faced crystal key that only fits a gate in a specific *state* |
| Provenance | Glassroot-cut; made by the Weavers to lock away the one record they agreed on |
| First discovery | Ch.09 optional mastery challenge; opens the sealed Glassroot chamber (revisit) |
| Functional use (framing) | state-dependent access to an optional chamber holding the Weavers' shared record |
| World connection | Glassroot (revisit), Engine core |
| Mysteries served | `who_built_the_loom` optional depth — the sealed record is the closest the game comes to identity, and it *still* names no one |
| Companion reaction | not eligible |
| Epilogue | none (optional relic; its lore entry is complete on acquisition) |

## `nar.item_lore.fracture_seal`
| Field | Value |
|---|---|
| proposed_item_slug | `fracture_seal` · Family: Field Module · Tier: chapter relic (Ch.09) |
| Physical identity | a disc that seals instability; the mark on it is *scratched out* |
| Provenance | the Weavers' last tool — used to hold each region's misalignment in place as they left. The scratched-out mark is their apology. |
| First discovery | Ch.09, Engine core |
| Functional use (framing) | contains temporary instability; failure recovery |
| World connection | every biome's original misalignment point |
| Mysteries served | `where_did_everyone_go` (final), `who_caused_misalignment` (final) |
| Companion reaction | eligible — Nox touches the scratched mark |
| Epilogue | `hold`: kept. `weave`/`open`: the player is offered to *re-scratch* the mark back in — restoring the builders' intent. Pure presentation; no state beyond `final_configuration`. |

## `nar.item_lore.nox_harness`
| Field | Value |
|---|---|
| proposed_item_slug | `nox_harness` · Family: Companion Gear · Tier: named artifact |
| Physical identity | a light woven band Nox can wear; Mira makes it from Archive Thread |
| Provenance | the only item *made in the present* — by Mira, from collected threads. It is the cast's first act of building rather than restoring. |
| First discovery | given by Mira after `nar.flag.nox_trust_earned` (Ch.02–03 window) |
| Functional use (framing) | improves Nox's sensing / clue interpretation |
| World connection | none direct; strengthens the companion channel |
| Mysteries served | none directly; enables companion-channel clues |
| Companion reaction | eligible by definition |
| Epilogue | Nox keeps it under `hold`/`weave`; leaves it with the player under `open` |

## Rejected / merged from the seed set
| Candidate | Decision | Reason |
|---|---|---|
| Wayfinder Shard | MERGED into Nox's sensing role | duplicate semantic responsibility with companion discovery; anti-duplication rule. Reversible: if AI-01 wants a non-companion hint item, re-open as OD-05. |

## Ledger checks (for AI-10 / AI-13)
1. Every entry has a `proposed_item_slug` and is present in the canon registry fixture with `item_ref: PROPOSED`.
2. Every non-optional relic serves >= 1 mystery stage in `MYSTERY_PAYOFF_REGISTER.md`.
3. Every entry with companion eligibility names the chapter/flag context so AI-06 can scope reactions.
4. No entry describes a stat, number or multiplier.
