# AI-03 Phase 00 — Vertical Slice Puzzle/World/Story Causality Map

**Status:** PROPOSED (Phase 00 required deliverable: "identify where puzzle/world/story causality must be demonstrated
in the Vertical Slice").
**Inputs (VERIFIED):** `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §14 (first-session target) and §15 (Gold Slice minimum
contents), `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md` §Investment Gate extension, `01_PREPRODUCTION/INVESTMENT_GATE.md`
Gate C, `01_PREPRODUCTION/STORY_BIBLE_V7.md` Act I, `00_CONTROL/MASTER_ROADMAP.md` Phase 6 gate.

## 1. Slice scope recommendation (AI-03 view; Product decides)

The Slice is **chapter 01 (First Light) complete + chapter 02 (The Broken Path) through its Test level**. Reasons:

- Chapter 01 alone cannot show a *meaningful equipment decision* (no equipment exists yet by design — DD-001 the
  puzzle must be fun bare).
- Chapter 02 introduces `anchor`/`rule.layer_lock` (first *decision* pressure), grants the first Tool candidate and
  contains the first Mastery-layer discovery — enough to prove every Gold Slice bullet without touching Act II.
- Two chapters exercise anti-repetition rules R1–R4 for real (signature change between chapters).

## 2. Causality beats — where the loop must be *demonstrated*, not described

Protected loop (`START_HERE.md`, VERIFIED):
`PUZZLE MASTERY -> WORLD REACTION -> STORY/DISCOVERY -> REWARD -> ITEM/EQUIPMENT CHOICE -> NEW CAPABILITY -> NEW PUZZLE`

| Beat | Level | Puzzle cause (AI-03 owns) | World effect (AI-02 state / AI-05 presentation) | Story/discovery effect (AI-09 / AI-03) | Reward (AI-03) | Gold Slice bullet proven (V7.1 §15) |
|---|---|---|---|---|---|---|
| B1 — The world answers | `level.01.awaken` (T0, `cube.2`, `align` U face) | objective satisfied | mechanism awakens; first path segment grows | question posed: "why does it react to me?" (no dialogue needed) | `reward.01.first_alignment` | one polished core puzzle interaction; puzzle→world causality; first-session §14 items 1–3 |
| B2 — Proximity has a voice | `level.01.seed_bed` (T1, `seed` tile) | Pulse fires at ≥3 matching tiles; `seed` home on solve | biome node grows where the seed tile was | `discovery.01.first_pulse` | `reward.01.seed_knowledge` | one discovery (Surface layer); reactive biome |
| B3 — Someone notices | `level.01.hollow_stone` (T2, twist: align two faces) | objective satisfied; optional assist-free | stone symbol glows if B1 flag set | Nox appears through the solve; `discovery.01.stone_mark` | `reward.01.nox_meets`, optional `reward.01.clean_hands` | one companion interaction; one story arc segment; world-memory consequence (B1 flag read here) |
| B4 — Order matters | `level.02.first_anchor` (T0 of ch.02) | anchor home unlocks layer | path segment assembles in solve order | Mira/Orin beat optional (AI-09) | `reward.02.anchor_knowledge` | understanding→decision pressure transition; anti-repetition R1 (new signature) |
| B5 — A tool, and a choice | `level.02.resonant_gap` (T1, `resonant` tile) | resonant tile home; Pulse | gap bridges | `discovery.02.nox_sense` if companion present | `reward.02.tuning_fork` (capability, main path, deterministic) | one meaningful equipment decision (equip Tuning Fork → Tool slot; or not); DD-006 deterministic acquisition |
| B6 — The path stays | `level.02.span` (T2 Test, `protected_mastery: true`) | objective satisfied; Legality/Cost effects inert; Information (Tuning Fork Pulse range) allowed | route reconnected — **persists** across save/reload | `discovery.02.under_span` (anchor-last order) → hidden route | `reward.02.path_restored`, optional `reward.02.efficient_span`, `reward.02.echo_route` | protected mastery demonstrated; world-memory consequence; save/reload cycle; discovery→world change |
| B7 — Upgrade/capability decision | post-`level.02.span` | — | — | — | **UNKNOWN**: the Gold Slice requires "one upgrade/capability decision". No upgrade path exists in ch.01–02 content. AI-03 proposes the Tuning Fork's *Precision vs Discovery* branch (Equipment Bible §Upgrade system) as the Slice's upgrade decision; owner AI-02 (`UpgradeDefinition`) + AI-01. Recorded as **DECISION REQUEST AI03-D3**. | one upgrade/capability decision |

## 3. First-session (10-minute) check — V7.1 §14

| §14 requirement | Where proven | AI-03 mechanism |
|---|---|---|
| 1. what the player controls | B1 | `cube.2`, single legal axis in the first attempt (`rule.axis_lock` on two axes, marked `relaxable: false` — a teaching lock, not a gate) |
| 2. why the cube matters | B1 | world hook on first solve |
| 3. actions alter the world | B1, B2 | seed tile growth |
| 4. the world has a mystery | B3 | stone mark only glows because of B1 — the player *sees* cause→effect they did not expect |
| 5. meaningful choices | B5 | equip or not; which Tool later |
| 6. progression is more than numbers | B2, B3 | rewards are knowledge, narrative, world change — no number appears in ch.01 |

## 4. Cross-track dependencies for the Slice (mock-able, not blocking)

| Need | Owner | AI-03 fixture/mocked stand-in until RELEASED |
|---|---|---|
| `WorldStateEvent` "mechanism awakens", "route reconnected", "hidden route opens" | AI-02/AI-13 | `PLACEHOLDER:` refs in `fixtures/phase00/rewards.draft.json`; validator accepts `PLACEHOLDER:` only while `status == DRAFT` |
| `NarrativeEvent` "Nox appears" | AI-09 | same |
| `ItemDefinition` Tuning Fork | AI-02 (definition), AI-01/AI-09 (approval/name) | same |
| companion presence flag | AI-06 | same |
| `LocalizationKey` for breadcrumbs/titles | AI-09 | `*_key` fields hold key *names* proposed by AI-03 in `loc.` namespace; AI-09 may rename — AI-03 fixtures treat them as opaque |
| solver for `par_moves`/reachability | AI-02 (Phase 03) | `par_source: "authored_unverified"`, `reachability_verified: false` |

## 5. Evidence the Slice must produce for the AI-03 domain (Phase 06 acceptance, stated now)

1. Replay log of B1–B6 from a fresh profile with `assist_count = 0`, no equipment → all main-path rewards granted.
2. Same replay with Tuning Fork equipped → identical `move_count`, identical `is_satisfied` outcomes, additional
   `pulse_range_bonus` recorded (P-1 evidence).
3. Save after B6 → kill process → reload → route still reconnected; `discovery.02.under_span` still in ledger.
4. Replay `level.02.span` after reload → no duplicate `reward.02.path_restored` (idempotency).
5. Anti-repetition validator passes on the two-chapter fixture.

None of these are claimed as done in Phase 00. They are the acceptance the Slice must meet.
