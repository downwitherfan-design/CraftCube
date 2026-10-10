# AI-03 Phase 00 — Puzzle-to-Reward Matrix & Deterministic Discovery Conditions

**Status:** PROPOSED (Phase 00 required deliverable: "deterministic reward/discovery conditions for protected
progression"; track deliverable: "Puzzle-to-Reward Matrix"). AI-03 is the register-named owner of `RewardDefinition`
and `DiscoveryDefinition` (`06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`, VERIFIED).
**Inputs (VERIFIED):** `01_PREPRODUCTION/PROGRESSION_AND_MASTERY_BIBLE_V7.md` (reward hierarchy), `01_PREPRODUCTION/QUEST_DISCOVERY_BIBLE_V7.md`
(discovery categories, secret design test), `01_PREPRODUCTION/DISCOVERY_AND_REPLAYABILITY.md` (discovery layers, ledger),
`00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` (DD-006 no luck-gating), `08_QA_RELEASE/STORY_ITEM_TEST_MATRIX.md`
(idempotency, repeated reward claims, interruption), `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate I/J.

## 1. Determinism contract

Every reward and discovery is a **pure function of persisted state**:

```
grant(reward)      iff  reward_condition(solve_record, world_state, ledger) == true  AND  reward_id ∉ ledger.rewards_granted
unlock(discovery)  iff  trigger_condition(solve_record, world_state, ledger) == true  AND  discovery_id ∉ ledger.discoveries
```

Consequences (the QA properties AI-10 should test — Gate I/J):

1. **Idempotent:** re-evaluating after a grant changes nothing (ledger guard). Repeated claims, chapter replay and
   interruption/retry cannot duplicate a grant (`STORY_ITEM_TEST_MATRIX.md` abuse cases).
2. **Order-independent within a solve:** conditions read the *final* solve record, not intermediate events.
3. **No randomness:** no condition reads an RNG. Seeded variants use the level `seed`, which is itself persisted.
4. **No wall-clock:** `challenge.time` uses simulation ticks; no reward depends on real dates (DD-009 no artificial waiting).
5. **Save-safe:** the ledger is two append-only sets (`rewards_granted`, `discoveries`) plus per-level bests. Losing a
   later save and replaying yields the same grants — progression is reconstructible.

## 2. Reward classes (mapped to the Progression Bible hierarchy — no second taxonomy)

`PROGRESSION_AND_MASTERY_BIBLE_V7.md` §Reward hierarchy (VERIFIED) ranks: knowledge > capability > world change >
narrative payoff > collection > cosmetic; currency lowest. AI-03 reward classes are exactly those ranks:

| Class ID | Bible rank | Payload owner | Example payload reference |
|---|---|---|---|
| `reward_class.knowledge` | 1 new knowledge | AI-09 (lore/record key), AI-03 (new pattern/rule taught) | unlock a pattern glyph in the player's pattern index |
| `reward_class.capability` | 2 new capability | AI-02 (`ItemDefinition`/`EquipmentDefinition` ID) | grant an item |
| `reward_class.world_change` | 3 world change | AI-02/AI-13 (`WorldStateEvent`) | set biome node tier |
| `reward_class.narrative` | 4 narrative payoff | AI-09 (`NarrativeEvent` ID) | fire narrative event |
| `reward_class.collection` | 5 collection value | AI-02 (item), AI-09 (lore) | grant a Memory Collectible |
| `reward_class.expression` | 6 cosmetic expression | AI-05/06/07 cosmetic ID | cube skin / world ornament |
| `reward_class.resource` | lowest | AI-02 `ResourceLedger` | **not used in Phase 00** — economy is not assumed (V7.1 §6) |

A reward *definition* carries a class and a **payload reference**, never the payload itself. AI-03 does not define items,
events or cosmetics — it defines *when they are earned*.

## 3. Puzzle-to-Reward Matrix (Vertical Slice scope: chapters 01–02, plus one Act II exemplar)

Reward IDs are PROPOSED (`reward.<chapter_nn>.<slug>`). Payload refs to other owners' IDs are **placeholders marked
`PLACEHOLDER:`** because those contracts are not RELEASED; they are not invented IDs.

| Reward ID | Chapter / level | Reward condition (deterministic) | Class | Payload ref (owner) | Protected-progression role | Why it reinforces the next choice (Quest Framework rule) |
|---|---|---|---|---|---|---|
| `reward.01.first_alignment` | `level.01.awaken` | `challenge.standard` met | `world_change` | PLACEHOLDER: AI-02 WorldStateEvent "mechanism awakens" | **Main path** — the world's first answer | Teaches the loop; next level is now *reachable* (path grows) |
| `reward.01.seed_knowledge` | `level.01.seed_bed` | `challenge.standard` AND `seed` tile home at solve | `knowledge` | AI-03 pattern index entry `pattern.solid_face` | Main path | Player now *knows* seed tiles cause growth → chooses where to plant later |
| `reward.01.nox_meets` | `level.01.hollow_stone` | `challenge.standard` met | `narrative` | PLACEHOLDER: AI-09 NarrativeEvent "Nox appears" | Main path | Companion introduced through a *solve*, not a cutscene (DD-003) |
| `reward.01.clean_hands` | `level.01.hollow_stone` | `challenge.limited_assist(max_assists=0)` | `expression` | PLACEHOLDER: AI-06/07 cosmetic "first-light glow" | Optional | Visible proof of `mastery.independence`; no power |
| `reward.02.anchor_knowledge` | `level.02.first_anchor` | `challenge.standard` met | `knowledge` | AI-03 rule index entry `rule.layer_lock` | Main path | Player understands ordering → the Broken Path becomes plannable |
| `reward.02.rootweave_gauntlet` | `level.02.locked_gap` | `challenge.standard` met | `capability` | PLACEHOLDER: AI-02 ItemDefinition (candidate "Rootweave Gauntlet") | **Main path, deterministic** (DD-006) | First equipment *decision*: Tool slot now has a candidate that relaxes `relaxable` layer locks → Slice "meaningful equipment decision". (Validator-corrected: an earlier draft used a `resonant` tile here, but `tile.resonant` is chapter 03's signature — R1.) |
| `reward.02.path_restored` | `level.02.span` (chapter Test, T2) | `challenge.standard` met | `world_change` | PLACEHOLDER: AI-02 WorldStateEvent "route reconnected" | Main path | Unlocks chapter 03 threshold — world memory: the path stays |
| `reward.02.efficient_span` | `level.02.span` | `challenge.move_efficiency(par+2)` | `collection` | PLACEHOLDER: AI-02 collectible (candidate "Archive Thread") | Optional | Rewards `mastery.efficiency` with lore value, not power |
| `reward.02.echo_route` | `level.02.span` | `challenge.discovery(discovery.02.under_span)` | `world_change` | PLACEHOLDER: WorldStateEvent "hidden route opens" | Optional | Discovery changes the world → Slice "one discovery" + "world-memory consequence" |
| `reward.06.ember_dial` (exemplar) | `level.06.first_fracture` | `challenge.standard` met | `capability` | PLACEHOLDER: AI-02 ItemDefinition (candidate "Ember Dial") | Main path, deterministic | Shows the Act II pattern: the item that *manages* the chapter's new risk is earned by *facing* it once without it |

**Protected-progression audit:** every `Main path` reward uses `challenge.standard` only → completing the level with
zero equipment and zero mastery grants it. No main-path reward depends on time, efficiency, discovery, companion or
equipment (DD-006). Optional rewards are never `capability` class in chapters 01–02, so no *capability* is locked behind
optional mastery in the Slice. (Whether later chapters may put *optional* capabilities behind mastery is **DECISION
REQUEST AI03-D2** — see `08_OPEN_DECISIONS_AND_CONFLICTS.md`.)

## 4. Discovery conditions (Vertical Slice scope)

Discovery IDs PROPOSED (`discovery.<chapter_nn>.<slug>`). Categories are the Quest/Discovery Bible's seven (VERIFIED);
layers are `DISCOVERY_AND_REPLAYABILITY.md`'s four (VERIFIED). Every discovery answers the Bible's four-question
secret design test (notice / skill / reveals / worth).

| Discovery ID | Level | Category | Layer | Trigger condition (deterministic) | Breadcrumb (why the player notices) | Skill rewarded | Reveals | Persistence |
|---|---|---|---|---|---|---|---|---|
| `discovery.01.first_pulse` | `level.01.seed_bed` | puzzle-state secret | Surface | configuration reaches a state where face U has ≥ 3 matching tiles *before* the objective is satisfied (Pulse fires once) | the cube hums for the first time | observation | that proximity has a sound → teaches Pulse | ledger set |
| `discovery.01.stone_mark` | `level.01.hollow_stone` | environmental secret | Curious | objective satisfied AND world flag `PLACEHOLDER:mechanism_awakened` true (set by `reward.01.first_alignment`) | a symbol on the stone glows after the earlier reward | connecting cause→effect | first Loom symbol (AI-09 lore key) | ledger set + world flag |
| `discovery.02.under_span` | `level.02.span` | alternate world state | Mastery | objective satisfied with the `anchor` tile going home **last** (order-sensitive record check) | the path assembles in a different order and a gap shows below | decision-order mastery | a hidden route under the span → `reward.02.echo_route` | ledger set |
| `discovery.02.nox_sense` | `level.02.locked_gap` | companion secret | Systemic | `anchor` tile home at solve AND companion present (PLACEHOLDER: AI-06 presence flag) | Nox stirs when a layer unlocks | using anchors deliberately | Nox can *sense* locked structure → foreshadows Companion Gear | ledger set + companion flag |
| `discovery.04.veiled_memory` (exemplar) | `level.04.dark_facet` | item-memory secret | Systemic | all `veiled` tiles revealed by equipment (Memory-class reveal count == veiled count) AND objective satisfied | a lens shows an older colour beneath | equipment strategy, not power | a prior world state (Glassroot memory) | ledger set |

**Blocker audit (Gate J):** no discovery gates a main-path reward. Every discovery's trigger is reachable in the same
level in which it lives, in a single attempt, from a fresh save that has the preceding main-path rewards. There is no
"missable forever" discovery: levels are replayable and conditions are re-evaluable.

## 5. DRAFT contract shapes (offered for Phase 01 freeze)

AI-03 offers these as DRAFT v0.1.0 JSON fixtures in `../fixtures/phase00/` for other tracks to consume immediately. They
follow the `CONTRACT_REGISTRY_TEMPLATE.md` fields and are **not** RELEASED.

```
RewardDefinition (DRAFT 0.1.0)
  reward_id, chapter_id, level_id, reward_class, reward_condition{condition_id, params},
  payload_ref{owner, kind, ref}, protected_progression(bool), idempotent(true, constant)

DiscoveryDefinition (DRAFT 0.1.0)
  discovery_id, chapter_id, level_id, category, layer, trigger_condition{kind, params},
  breadcrumb_key(LocalizationKey ref, AI-09), reveals_ref{owner, kind, ref}, blocks_progression(false, constant)
```

The two constant fields (`idempotent: true`, `blocks_progression: false`) are deliberate: the validator rejects any
fixture that sets them otherwise, making the design rule a schema rule.

## 6. Test strategy handed to AI-10

- Idempotency: evaluate grants twice on the same record → ledger unchanged on second pass.
- Interruption: persist ledger after grant; re-load and re-evaluate → no duplicate.
- Replay: replay a solved chapter with a fresh solve record → only *new* optional grants can appear.
- Blocker scan: for every `protected_progression: true` reward, assert `condition_id == challenge.standard`.
- Determinism: same (seed, ruleset, moves, loadout) → same grant set.
