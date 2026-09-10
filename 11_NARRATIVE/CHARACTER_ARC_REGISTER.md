# Character / Companion Arc Register

**Owner:** AI-09 · **Status:** DRAFT v0.1.0 · Consumers: AI-06 (companion/character presentation & reactions), AI-07 (dialogue/relationship UX), AI-08 (character audio identity), AI-02 (CharacterMemory / NarrativeMemoryFlag state), AI-10 (arc coverage tests)

Each arc follows the required shape from `01_PREPRODUCTION/COMPANION_BOND_BIBLE_V7.md` and `STORY_CONTENT_ARCHITECTURE.md` §3: starting belief → personal conflict → relationship with the Loom → relationship with the player → turning point → payoff, plus a **signature language** (visual/audio *intent* for AI-06/AI-08) and the **narrative memory flags** the character reads or writes.

Contract note: `CharacterMemory` and `NarrativeMemoryFlag` are AI-09-owned contract families per `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`. Their *schemas* are a Phase 01 deliverable. This register fixes the **semantic flag set** they must carry so AI-02 can design storage without waiting.

## Cast (fixed for Phase 00)

| ID | Display (EN draft) | Role | Speaks | Companion |
|---|---|---|---|---|
| `nar.character.weaver` | the Weaver | player | no (silent protagonist) | — |
| `nar.character.mira` | Mira | Cartographer; context, wonder, the *mapping* worldview | yes | no |
| `nar.character.orin` | Orin | Keeper; tradition, certainty, the *restoration* worldview | yes | no |
| `nar.character.nox` | Nox | first companion; sensing, reacting, emotional mirror | no (vocalisations only) | yes |
| `nar.character.quiet_architect` | the Quiet Architect | absent builder(s); delivered via marks and relics | no (never voiced; never shown) | — |

Additional biome-local characters: **not in Phase 00 canon.** See `OPEN_DECISIONS_AI09.md` OD-02.

---

## Arc 1 — Mira, the Cartographer (`nar.character.mira`)

| Stage | Content |
|---|---|
| Starting belief | If it can be mapped, it can be understood. Asterra is a broken system; a complete enough map will show how to fix it. |
| Personal conflict | Her maps keep being wrong — not because she is careless but because the world *changes*, and a map is a claim that it does not. |
| Relationship with the Loom | It does not answer her. She has spent years documenting a thing that ignores her. She is not bitter; she is *fascinated* that it answers the player. |
| Relationship with the player | Peer, not mentor. She never tells the player how to solve; she tells them what she observed *after* they solved. She is the voice of "look what you did". |
| Setup (Ch.01–02) | Arrives sketching before she notices the player. Ch.02: Nox leads the player to a node her map says is not there. |
| Conflict (Ch.03–05) | Reads the heart-node record as "a log of changes" against Orin's "instructions". Ch.05: the two contradictory records; she wants to keep *both*, cannot. |
| Turning point (Ch.07–08) | Ch.07: in the moving Engine she stops drawing and just watches. Ch.08: she gives the player her map — "You don't need it. I think I never did." Sets `nar.flag.mira_stops_mapping`. |
| Payoff (Ch.09–10) | Ch.09: she is the one who says the records were never contradictory — "they were written at different times, and both were true *then*." Ch.10 epilogue: she begins a new kind of record — one that expects to change (line varies with `nar.flag.final_configuration`). |
| Signature language (intent) | Visual: always has a drawing surface; ink/graphite motif; she *points* at world changes. Audio: pencil/charcoal scratch; a light, curious woodwind phrase (`nar.motif.mira_phrase`) — AI-08 owns realisation. |
| Flags read | `nar.flag.ch01_first_node_choice` (Ch.02 aside), `nar.flag.first_record_interpretation`, `nar.flag.vault_record_kept`, `nar.flag.final_configuration` |
| Flags written | `nar.flag.mira_stops_mapping` |
| Anti-pattern guard | Mira must never deliver a tutorial. If a line of hers explains controls, it is misassigned. |

## Arc 2 — Orin, the Keeper (`nar.character.orin`)

| Stage | Content |
|---|---|
| Starting belief | Stability is safety. The old order was good because it held. Restoration means putting everything *back*. |
| Personal conflict | He is the last person who remembers the traditions — and the traditions are incomplete. He fears that if the old order is not restored exactly, what he remembers dies with him. |
| Relationship with the Loom | Reverent. He speaks of it as one speaks of a lost home. He has never touched a cube; he believes touching it without training is dangerous (WR-6: nobody alive knows). |
| Relationship with the player | Hopeful elder who assumes the player shares his goal. He is *right* that the world should be healed and *wrong* about what healed means. He is never a villain and never lies. |
| Setup (Ch.01) | "We can put the world back the way it was." The word *back* is the seed of the whole game's question. |
| Conflict (Ch.03–06) | Ch.03: reads the record as instructions. Ch.04: Glassroot shows many pasts — *which* back? Ch.05: keeps/loses a record. Ch.06: Ember Hollow rewards deliberate misalignment; his traditions do not mention this biome. He admits it. |
| Turning point (Ch.07) | Stands inside the turning Engine and, for the first time, does not speak. When he does: "This was never still." Sets `nar.flag.orin_accepts_design`. |
| Payoff (Ch.09–10) | Ch.09: repeats the player's own Ch.03 interpretation back to them (flag-dependent line) and says the world "was never meant to be *back*". Ch.10: if `final_configuration = hold`, he is at peace but says "hold it lightly"; otherwise he is the one who asks Nox to show him how to listen. |
| Signature language (intent) | Visual: carries a keeper's staff with a *fourth* notch he added himself (visual foreshadowing that tradition is already an interpretation). Audio: low bowed-string motif (`nar.motif.orin_phrase`) that gains a resolving note only after Ch.07. |
| Flags read | `nar.flag.first_record_interpretation`, `nar.flag.vault_record_kept`, `nar.flag.nox_ember_awakening`, `nar.flag.final_configuration` |
| Flags written | `nar.flag.orin_accepts_design` |
| Anti-pattern guard | Orin is never proven *stupid*. Every belief he holds is reasonable on the evidence he has. The player disagrees with him by *seeing more*, not by being smarter. |

## Arc 3 — Nox, first companion (`nar.character.nox`)

| Stage | Content |
|---|---|
| Starting belief (behavioural) | Alignment is good; misalignment hurts. Nox flinches at wrong turns, brightens at right ones. |
| Personal conflict | Nox is *made of* residual alignment (WR-5). In Ember Hollow, where controlled misalignment is the tool, Nox's instinct is wrong — and it has to learn that from the player. |
| Relationship with the Loom | Nox is a fragment of the Loom's own work. It cannot align anything; it can only *hear* alignment. It is the game's living proof that hearing and doing are different (mirrors Mira). |
| Relationship with the player | Trust earned through shared discovery, never through gifts (§3.2 world-class rules). Nox approaches the *cube* first, the player second; by Ch.02 it approaches the player first. |
| Gameplay role (narrative framing) | Sensing (points toward dormant nodes), reacting (puzzle-state feedback), discovery (leads to off-map nodes). Never combat, never auto-solve (DD-007, DD-002). |
| Setup (Ch.01) | Forms out of the first lit channel. Flinch/brighten reaction to moves. |
| Trust (Ch.02) | Leads the player to a node not on Mira's map. Sets `nar.flag.nox_trust_earned`. |
| Conflict (Ch.04, Ch.06) | Ch.04: reacts to a crystal echo of a Weaver-shaped figure — it *recognises* something. Ch.06: instinct says "no" to deliberate misalignment; player does it anyway; the world helps; Nox changes — it brightens at *intentional* misalignment thereafter. Sets `nar.flag.nox_ember_awakening`. |
| Turning point (Ch.08) | The Verdant Archive shows Nox's kind as what remained of the Weavers' *work*. Nox memory beat: it leads the player to the specific root where its pattern began. Sets `nar.flag.nox_memory_unlocked`. |
| Payoff (Ch.09–10) | Ch.09: reacts to the final Engine configuration with the *same* flinch/brighten as Beat 3 — the language never changed. Ch.10: chooses to stay as a companion or to disperse into the new pattern (depends on `final_configuration`; both are warm — dispersal is joining, not dying, WR-4). |
| Signature language (intent) | Visual: small, light-bodied, carries the three-notch mark faintly on its back (payoff: it is *signed* by the builders). Audio: two-note chirp that is a fragment of `nar.motif.alignment_chord`; the chirp resolves to the full chord only in Ch.10 (`nar.motif.nox_call`). |
| Flags read | `nar.flag.nox_trust_earned`, `nar.flag.nox_ember_awakening`, `nar.flag.nox_memory_unlocked`, `nar.flag.final_configuration` |
| Flags written | `nar.flag.nox_trust_earned`, `nar.flag.nox_ember_awakening`, `nar.flag.nox_memory_unlocked` |
| Anti-pattern guard | No bond meter shown as a number (Companion Bond Bible: "avoid spreadsheet"). Bond stages are the flags above; presentation is AI-06/AI-07. |

## Arc 4 — The Quiet Architect (`nar.character.quiet_architect`) — absence arc

| Stage | Content |
|---|---|
| Nature | Not a character who appears. A *title the cast invent* (WR-7) for whoever left the three-notch mark. Delivered entirely through environment and relics. |
| Setup | Ch.01: the mark on the first node. Ch.03: the marks are in an authored sequence. |
| Uncertainty | Ch.05: was it one builder, a guild, the Weavers themselves? Records disagree. |
| Partial payoff | Ch.07: the mark means "intentional change" — it is a signature of *purpose*, not identity. |
| Final | Ch.10: *what they intended* is answered (an instrument, not a machine). *Who* they were is `INTENTIONALLY_UNRESOLVED`. |
| Flags | none — the Architect has no memory; the world does. |
| Anti-pattern guard | Never give the Architect a voice log, a hologram, a diary or a name. The moment they speak, the mystery collapses into exposition. |

## The Weaver (`nar.character.weaver`) — player

No arc in the authored sense; the player's arc *is* their mastery. Canon constraints: silent; unnamed; no fixed pronoun in source text (write around it — the loc bible carries a rule); never described as "chosen". The one authored beat: Ch.08 partial payoff of `nar.mystery.why_the_weaver` — the Loom answers whoever plays *with* it. This is a statement about the player's practice, so it must arrive *after* they have demonstrably mastered the language.

---

## Narrative memory flag set (DRAFT v0.1.0) — semantic definition for the CharacterMemory / NarrativeMemoryFlag contracts

Budget: ≤ 12 (Story Bible). Current: **10**. All flags are save-persistent, deterministic, written at most once (idempotent set), never unset. Default value is the first listed. Enum flags are closed sets.

| Flag ID | Type | Values | Written in | Read in | Consequence class |
|---|---|---|---|---|---|
| `nar.flag.ch01_first_node_choice` | enum | `unset` / `near` / `far` | Ch.01 | Ch.01–02 | dialogue, restoration order presentation |
| `nar.flag.nox_trust_earned` | bool | `false` / `true` | Ch.02 | Ch.04+, Ch.10 | companion behaviour stage |
| `nar.flag.first_record_interpretation` | enum | `unset` / `orin` / `mira` | Ch.03 | Ch.05, Ch.09 | dialogue |
| `nar.flag.vault_record_kept` | enum | `unset` / `mira` / `orin` | Ch.05 | Ch.09 | dialogue, one collectible record, Engine core starting presentation |
| `nar.flag.nox_ember_awakening` | bool | `false` / `true` | Ch.06 | Ch.07+, Ch.10 | companion reaction polarity to intentional misalignment |
| `nar.flag.orin_accepts_design` | bool | `false` / `true` | Ch.07 | Ch.09–10 | dialogue |
| `nar.flag.mira_stops_mapping` | bool | `false` / `true` | Ch.08 | Ch.09–10 | dialogue, optional map collectible |
| `nar.flag.nox_memory_unlocked` | bool | `false` / `true` | Ch.08 | Ch.10 | companion epilogue, one optional scene |
| `nar.flag.final_configuration` | enum | `unset` / `hold` / `weave` / `open` | Ch.10 | Ch.10 epilogue | epilogue world presentation, all epilogue dialogue, relic epilogue lines |
| `nar.flag.epilogue_seen` | bool | `false` / `true` | Ch.10 | post-game | unlock of any post-game revisit dialogue; prevents duplicate epilogue |

Rules (for AI-02 storage design, AI-10 tests):
1. A flag transitions from its default at most once. Re-applying the same write is a no-op (idempotent). Applying a *different* value after it has been set is a defect, not a branch.
2. No flag may be required for main-path progression. Flags change *how* content presents, never *whether* it is reachable (DD-008).
3. Flags are the only narrative state that content may branch on. Dialogue variants are keyed `loc.dlg.<chapter>.<speaker>.<beat>.<variant>` where variant is a flag value, so the branch set is enumerable and testable.
4. Save migration: adding a flag is additive (default applies). Removing/renaming a released flag requires the `06_CONTRACTS/SAVE_MIGRATION_POLICY.md` process.

## Coverage self-check (Phase 00 acceptance)

Requirement: ≥ 3 major arcs with setup, conflict, turning point, payoff. Delivered: Mira, Orin, Nox (full), Quiet Architect (absence arc), Weaver (player, by design minimal). Every flag written is read at least once (verified by `tools/validate_narrative_registry.py` against the canon registry fixture).
