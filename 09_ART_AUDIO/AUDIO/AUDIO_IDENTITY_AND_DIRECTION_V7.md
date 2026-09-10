# CraftCube v7 — Audio Identity & Direction (Phase 00 Lock)

- Owner: AI-08 (Audio / Music / Adaptive Sound)
- Phase: 00 — Product/IP Lock
- Document status: PHASE-00 LOCK CANDIDATE (design intent). Technical truth is defined by contracts frozen in Phase 01.
- Source-of-truth precedence: `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` > `01_PREPRODUCTION/STORY_BIBLE_V7.md` > this document. If this document contradicts a bible, the bible wins and this document must be corrected through a change request.

This document locks **what CraftCube must sound like, what audio is for, what audio must never do, and how audio quality will be measured**. It does not define gameplay rules, UI layout, narrative canon or release pipeline (out of AI-08 scope).

---

## 1. Audio product statement

**"The world answers you in sound before it answers you in sight."**

Audio in CraftCube is the fastest confirmation channel of the protected loop `PUZZLE MASTERY -> WORLD REACTION -> STORY/DISCOVERY -> REWARD -> ITEM/EQUIPMENT CHOICE -> NEW CAPABILITY -> NEW PUZZLE`. Every twist, every alignment and every world change must be *heard* as consequence, so the player learns the "language of the living cube" (Game Master Bible §2) partly by ear.

## 2. Audio pillars (locked)

| # | Pillar | What it means in practice | Protects (Bible §3 hierarchy) |
|---|---|---|---|
| A1 | **Puzzle feedback is sacred** | Move/commit/lock/solve cues are the highest-priority sounds in the game. They are never masked, delayed by music logic or ducked below audibility. | 1. Puzzle mastery |
| A2 | **Causality is audible** | World reaction to a solved pattern is heard as a *musical/tonal consequence* of the puzzle cue (same key/motif family), not as an unrelated stinger. | 2. Puzzle/world causality |
| A3 | **A living, ancient, warm world** | Tone = wonder + mystery + warmth + quiet danger (Story Bible). Organic and mechanical timbres blended; never grim, never childish. | 3–4. Exploration, story attachment |
| A4 | **Motifs carry story, not exposition** | Recurring sound motifs (§5) are an environmental-storytelling channel (Story Bible: "sound motifs"). They foreshadow, echo and pay off mysteries without text. | 4. Story |
| A5 | **Items have voices** | Each important item/equipment piece has a recognisable sonic identity tied to its behaviour (what it does), never a generic "power-up" sound. | 5. Equipment choice |
| A6 | **Non-fatiguing by design** | A mobile puzzle game is played in long, repetitive sessions. Music is adaptive and sparse; repeated SFX use controlled variation; no cue may become irritating within a 30-minute session. | 13. Quality definition |
| A7 | **Accessible and redundant** | Critical information is never audio-only; audio is never required, and every critical audio cue has a defined non-audio equivalent (owned by AI-07/AI-04 via contract). | 13. Quality definition |
| A8 | **Original and IP-safe** | No sound-alike of Minecraft (or any other title's) music, creature vocalisations, block sounds or UI sounds. No licensed samples/music without explicit license metadata. | Non-goals §12 |

## 3. IP-safe direction (locked)

VERIFIED constraint: `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` states the source material uses Minecraft-specific presentation and that mechanical ideas must be separated from proprietary branding/assets.

Audio rules derived from this:
1. **No sound-alikes.** Do not reference, imitate or "homage" the Minecraft soundtrack (ambient piano/synth style associated with it), block placement/break sounds, creature vocalisations or UI clicks. Audio references used for cue design must be documented and must not be commercial game soundtracks.
2. **No unlicensed assets.** Every audio asset entering the repository carries the `ASSET_PIPELINE.md` metadata (`assetId, type, owner, source, license, version, target platform, memory estimate, dependencies`). Assets without license metadata are rejected at validation.
3. **Original palette.** CraftCube's palette (§4) is defined by *its own* world: the Axis Loom (geometric/mechanical), the Weaver's touch (tactile/physical), and biome life (organic).
4. **Terminology.** Audio documentation uses CraftCube canon terms owned by AI-09 (Axis Loom, Weaver, Great Misalignment, Hearthwild, Glassroot, Sunken Grid, Ember Hollow, Verdant Archive, Quiet Engine, Nox, Mira, Orin). AI-08 does not create narrative terms; audio-internal terms are listed in §12 and are clearly *audio* terms.

## 4. Sonic palette

Three blended layers give CraftCube a recognisable, original sound:

| Layer | Character | Used for |
|---|---|---|
| **Loom** (geometric/mechanical) | Tuned metallic and glass resonances, precise clicks, harmonic "locking" tones, deep slow machine breath. Pitch-quantised to the current musical key so puzzle sounds are always *musical*. | Cube moves, alignment, mechanism awakening, Quiet Engine |
| **Weaver** (tactile/human) | Close, dry, physical: fabric, wood, stone under fingers, breath-length swells. Communicates "my hands did this". | Touch confirmation, grab/rotate feel, item handling |
| **Life** (organic/biome) | Living textures per biome: growth, water, crystal, heat, roots. Responds to biome tier (dormant→mastered). | Ambience, world reaction, companion, restoration |

Rule: a **world-reaction cue = Loom attack + Life tail**, so the player hears the machine cause and the living effect in one gesture (Pillar A2).

## 5. Motif system (audio side of story)

Motifs are short melodic/harmonic identities (2–6 notes) that recur, transform and pay off. They exist so story can be *felt* without lore dumps (DD-003). AI-09 owns what the mysteries *mean*; AI-08 owns how they *sound*.

| Motif (audio name) | Attached to (canon owner AI-09) | Audio design rule | Transformation arc |
|---|---|---|---|
| **Loom Motif** | The Axis Loom / mechanism awakening | Ascending, symmetric interval pattern; feels "designed". First heard fully at the first mechanism restart (Act I, First Light). | Act I: fragmentary, incomplete cadence. Act II: heard in contradictory harmonisations (mirrors "was it an accident?"). Act III: completed or deliberately *left unfinished* depending on the finale state. |
| **Weaver Motif** | The player's touch / "why does the world react to my hands?" | Simple, warm, hummable; grows from single note to phrase as mastery progresses. | Gains one note per act; first heard as a solved-pattern reward, later as a *question* under the Loom Motif. |
| **Nox Motif** | First companion | Playful, small, quick; reacts rather than leads. Built from the Life layer of the current biome so Nox always "belongs" to where you are. | Bond stages change articulation, not the notes: shy → confident → harmonising with Weaver Motif. |
| **Misalignment Texture** | The Great Misalignment / instability | Not a melody: detuned, phase-shifting cluster; the "wrongness" of unstable world states. | Reframed in Ember Hollow as *useful* energy (instability ≠ failure), then reinterpreted in Act III. |
| **Architect Fragment** | The Quiet Architect | Rarely heard; a hidden inversion of the Loom Motif. Seeded in relics and Quiet Engine spaces as foreshadowing (V7.1 foreshadowing ledger). | Recognised late as the "designed to evolve" idea. |

Motif usage rules:
- Motifs are **never** used as generic reward jingles; a motif appearance must correspond to a narrative or mastery meaning.
- Motif statements are gated by narrative/world state through released contracts (`NarrativeEvent`, `WorldStateEvent`, `NarrativeMemoryFlag`), never by audio-side hidden state.
- Foreshadowing placements must be recorded in the Phase 01+ cue registry with the mystery they seed, so payoff can be verified (V7.1 §3.3).

## 6. Adaptive audio language

### 6.1 Puzzle states (highest priority)

| Puzzle moment | Audio intent | Fatigue control |
|---|---|---|
| Touch/grab | Weaver-layer confirmation, very short, dry | Round-robin variation, minimal |
| Rotate in progress | Loom-layer continuous, pitch follows rotation progress (tactile) | Continuous, not per-frame retriggered |
| Move commit | Loom click, quantised to key | Variation pool; pitch scheme by axis (design hypothesis to test) |
| Invalid move / locked axis | Distinct *negative-but-not-punishing* damped tone (maps to typed failure `InvalidMove`, `LockedAxis` in `INTERACTION_CONTRACTS.md`) | Never harsh; never louder than commit |
| Partial alignment / progress | Harmonic tension resolves stepwise as tiles align; this is how the player "hears they are close" | Sparse; intensity tied to progress, not time |
| Solve | Resolution chord + Weaver Motif phrase + Life tail; leads directly into world reaction | Unique per biome tonal centre; never identical twice in a row |
| Undo/redo | Reverse-envelope of the commit cue (recognisably "the same thing backwards") | Low level |
| Smart Assist / hint (source concepts: Cube Pulse / Golden Trail) | Gentle, guiding, clearly *not* a solve cue | Cool-down; never nagging |

### 6.2 World / biome states

Music and ambience are driven by biome transformation tier (World Biome Bible: Tier 0 dormant → Tier 4 mastered) and by explicit world-state (restored / unstable / discovered / mastered / story / companion / secret):

- **Tier 0 dormant:** ambience only, sparse Loom breath, no melodic music. Silence is content.
- **Tier 1 awakened:** harmonic pad enters; Loom Motif fragment allowed.
- **Tier 2 recovering:** rhythmic/organic Life layer enters; biome instrument identity becomes clear.
- **Tier 3 flourishing:** full adaptive arrangement; Weaver Motif may be harmonised.
- **Tier 4 mastered/rare:** unique colour layer for that biome; used sparingly as a reward for mastery, not grinding (Bible: no forced Tier 4).
- **Unstable state:** Misalignment Texture blends in proportionally; puzzle-critical bus remains fully protected.
- **World memory:** a place the player restored keeps its tier layer on return — audio *remembers* (DD-004). Small persistent changes preferred (a single instrument added) over huge ones.

Each biome has a distinct **tonal centre and instrument identity** so a returning player can identify a biome with eyes closed:

| Biome | Mechanical identity (Biome Bible) | Audio identity (intent) |
|---|---|---|
| Hearthwild | orientation, basic alignment | warm wood/breath, open intervals, first-growth textures |
| Glassroot | pattern recognition, state echoes | glass/crystal resonances, echo/memory delays that literally repeat earlier phrases |
| Sunken Grid | sequencing, controlled restoration | submerged filtered tones, pumps/pulses as rhythm, clearing as water drains |
| Ember Hollow | risk/reward, controlled instability | heat crackle, brass-like swells, Misalignment Texture used as *energy* |
| Verdant Archive | long-range planning | living/rooted low drones, slow-evolving polyphony |
| Quiet Engine | advanced multi-state | precise mechanical polyrhythm, Architect Fragment surfaces |

### 6.3 Story reveals
Narrative stingers are **motif statements**, not orchestral hits. Reveal intensity is scaled by the four-layer model (IMMEDIATE EVENT → PERSONAL CONSEQUENCE → WORLD CONTEXT → LONG-TERM MYSTERY): immediate events get short, close cues; long-term mystery reveals get the widest, longest tails. Dialogue is text-first at Phase 00 (voice-over is an open Product decision, §11); audio supports dialogue with character-specific "speech texture" (Mira/Orin/Nox), not VO.

### 6.4 Equipment / items
Each important item has: **acquire** (discovery scene), **equip** (identity statement), **use** (behavioural sound that describes *what it does*), **resonance** (when the item resonates with a compatible puzzle/biome/companion condition), and **limit** (charge/cooldown exhausted, clearly non-punitive). Sonic identity follows function: e.g. a state-echo item sounds like a delayed memory of the current world sound; a stabiliser sounds like the Misalignment Texture being tuned into consonance. Item names in the starter catalog are design seeds owned by AI-01/AI-09 and may change; audio identities are bound to *behaviour classes*, not names, so renames do not break audio.

### 6.5 Companion reactions
Nox reacts to puzzle states, biome health, relics, story beats, mastery moments and player choices (Companion Bond Bible). Audio rules: Nox vocalisations are short, non-verbal, derived from the Life layer of the current biome, and their *priority is below puzzle-critical* — Nox never talks over the solve. Bond level changes articulation (§5), never volume.

### 6.6 Discovery
Discovery has a three-stage audio grammar so secrets reward observation, not guessing (Content Rules): **proximity hint** (subtle, optional, may be disabled), **reveal** (Architect Fragment or biome-specific colour), **record** (collectible logged; quiet, satisfying). Proximity hints must be deterministic given world state and player position; no random triggering.

## 7. Non-fatigue and mix rules (locked)

1. **Bus hierarchy (design):** `Master → { PuzzleCritical, Narrative, Companion, Item, World/Ambience, Music, UI }`. PuzzleCritical is the only bus that may duck every other bus and may never itself be ducked below its floor.
2. **Priority classes** (used in the cue registry): `P0_PUZZLE_CRITICAL`, `P1_NARRATIVE`, `P2_WORLD_REACTION`, `P3_COMPANION_ITEM`, `P4_AMBIENT_MUSIC`, `P5_UI`. Voice-stealing steals lowest priority first, oldest second.
3. **No abrupt layer jumps** (Gate D): all adaptive layer changes are beat- or bar-quantised or cross-faded; transitions are stated in the registry.
4. **Variation:** any cue that can trigger more than ~1×/second in normal play must declare a variation strategy (round-robin, pitch/timing micro-variation, or intensity ladder).
5. **Density ceiling:** music is allowed to be *absent*. Dormant states and long think-phases default to sparse ambience.
6. **Loudness:** one integrated loudness target and a true-peak ceiling are set for the whole game in Phase 01 (measured with a loudness meter; no clipping — Gate D). Numbers are not asserted here because they are not yet measured.
7. **Interruption safety:** app pause/resume, phone calls and audio-focus loss must resume the adaptive state deterministically from saved/derived state, never from a stale mid-transition (Bible §13 "stable under interruption").

## 8. Accessibility (audio-owned options) and redundancy

AI-08 owns the audio-side options and the *requirement* that every critical cue have a non-audio equivalent. The visual/haptic equivalents themselves are owned by AI-07 (UI/accessibility) and AI-04 (haptics), consumed through `AccessibilityPreference` (owner AI-07) once frozen.

Audio-side options (locked as scope):
- independent volume: Music, SFX, Ambience, Dialogue/Narrative, UI
- master mute that keeps puzzle-critical *caption/visual* channel intact (via AI-07)
- mono downmix
- **Reduced audio intensity** mode: fewer adaptive layers, softer transients, no Misalignment Texture swell
- **Cue redundancy** mode (V7.1 §9 "audio cue redundancy"): emits caption/haptic events for `P0` and `P1` cues (payload defined in Phase 01 contract)
- hearing-safe defaults on first launch (no sudden loud content before the player can reach a slider)

Every `P0_PUZZLE_CRITICAL` and `P1_NARRATIVE` cue in the registry carries `requiresNonAudioEquivalent: true`; the validator enforces it.

## 9. Platform assumptions (Android-first, DD-010)

VERIFIED from repository: target engine is Unity 6 + URP + Android (`02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`). UNKNOWN: audio middleware (Unity built-in mixer vs. third-party) — a Phase 01 decision requiring AI-11 (performance) and AI-12 (build/licensing) input; not assumed here.

Locked design assumptions regardless of middleware:
- Audio must be fully functional on low-end Android with a reduced voice count; puzzle-critical cues never drop under voice pressure.
- Mobile speakers are small and mono-ish: puzzle-critical cues carry information in the **mid band (roughly 500 Hz–4 kHz)**, not in sub-bass or extreme highs; stereo width is decoration, never information.
- Headphone and speaker mixes are validated separately (Phase 06+).
- Compressed streaming for music/ambience, decompressed-in-memory only for short critical SFX; exact formats/bitrates set in Phase 01 with AI-11 budgets.
- Offline-first: no audio content depends on network (DD-015). Remote audio content, if ever added, follows the remote-content safety rules (V7.1 §12).

## 10. Success criteria and measurable boundaries

Status of all numbers: **HYPOTHESIS budgets** to be measured and confirmed/adjusted with AI-10 (QA) and AI-11 (performance). None are measured results.

| ID | Criterion | Measurement (planned) | Gate |
|---|---|---|---|
| AUD-SC-01 | Player can identify solve vs. non-solve outcome by audio alone | Blind playtest task, ≥ 90% correct classification target (hypothesis) | Phase 06 Gold Slice |
| AUD-SC-02 | Puzzle-critical cue latency from committed move to audible onset is not perceptible | Device measurement (AI-11 method); target hypothesis < 50 ms onset on mid-tier device | Phase 04/12 |
| AUD-SC-03 | No cue reported as irritating in a 30-min session | Playtest questionnaire + telemetry-free observation | Phase 06/15 |
| AUD-SC-04 | Each biome identifiable by ear | Blind identification task on ≥ 3 biomes (hypothesis ≥ 75%) | Phase 08+ |
| AUD-SC-05 | No clipping; no abrupt layer jumps | Loudness/true-peak meter + adaptive transition audit | Gate D |
| AUD-SC-06 | All P0/P1 cues have non-audio equivalent | Registry validator (`requiresNonAudioEquivalent`) + AI-07 mapping evidence | Phase 01 → every phase |
| AUD-SC-07 | Audio CPU/memory within AI-11 budget on low-tier device | Profiler evidence per `PerformanceBudget` contract | Phase 12 |
| AUD-SC-08 | Interruption (pause/call/focus loss) resumes correct adaptive state | Automated/device test | Phase 11 |
| AUD-SC-09 | All audio assets carry license metadata; zero placeholder audio in release | Asset validator (mechanically detectable placeholders, `ASSET_PIPELINE.md`) | Gate C/D |
| AUD-SC-10 | Motif foreshadowing → payoff is complete for each major mystery | Registry ledger review with AI-09 | Phase 09 |

## 11. Scope: in / out / cut list (Phase 00)

**In scope for Vertical Slice Gold (Phase 06):** Hearthwild adaptive music (Tier 0–3), full puzzle-critical cue set, one world-reaction cue family, Loom + Weaver + Nox motifs (Act I forms), one item full identity set (acquire/equip/use/resonance/limit), one discovery grammar instance, accessibility options above, one narrative stinger.

**Deferred (not cut):** remaining biomes, Act II/III motif transformations, Tier 4 layers, headphone-specific mix pass.

**Cut / not planned unless a Product decision reopens it:**
- Full voice-over (see §13 open decisions) — text-first.
- Licensed music.
- Procedural/generative music engine beyond adaptive layers (complexity without demonstrated player value — V7.1 §16).
- Player-authored music/instrument features.
- Rhythm-based puzzle mechanics (would change gameplay rules — not AI-08's to introduce).

## 12. Audio terminology (AI-08 terms, not narrative canon)

| Term | Meaning |
|---|---|
| **Cue** | A semantic audio request with a stable cue ID; engine-agnostic (what should be heard and why). |
| **Audio asset** | A concrete file/clip with an asset ID (how it is heard). Cues reference assets; content never references files. |
| **Layer** | A music/ambience stem that can be added/removed adaptively. |
| **Motif** | A short recurring melodic/harmonic identity carrying story or mastery meaning (§5). |
| **Tonal centre** | The key/mode a biome's cues are quantised to. |
| **Priority class** | `P0`–`P5` scheduling/ducking class (§7). |
| **Bus** | A mix group with its own volume/ducking rules. |
| **Redundancy event** | A non-audio equivalent (caption/haptic/visual) emitted for a critical cue (§8). |
| **Misalignment Texture** | Audio-only name for the instability sound family; the *event* it reflects is canon owned by AI-09. |

## 13. Open decisions (Product/Human) — not guessed

| ID | Decision needed | Owner | Default until decided |
|---|---|---|---|
| AUD-OD-01 | Voice-over: none / partial (companion + key lines) / full | AI-01 + Human | None (text-first; speech textures only) |
| AUD-OD-02 | Audio middleware selection and licence | AI-13 governance with AI-11/AI-12 input | UNKNOWN; design remains middleware-agnostic |
| AUD-OD-03 | Whether the finale leaves the Loom Motif unresolved (depends on finale canon) | AI-09 + Human | Both variants designed; selection by NarrativeEvent |
| AUD-OD-04 | Loudness target / true-peak ceiling numbers | AI-08 proposes in Phase 01, AI-11/AI-10 confirm by measurement | Not asserted |

## 14. Recorded UNKNOWN / MISSING / CONFLICT

- UNKNOWN: audio middleware; asset format/bitrate budgets; exact `WorldStateEvent`, `NarrativeEvent`, `CompanionReaction`, `AccessibilityPreference` field names (contracts are `TBD 1.0.0`).
- MISSING: `integration` branch on remote (only `ai-13-integration` exists) — PR target per `07_GITHUB/GITHUB_MODEL.md` cannot be used yet; AI-13 to create.
- CONFLICT (report only): `07_GITHUB/CODEOWNERS_EXAMPLE.txt` and `07_GITHUB/scripts/validate_ownership.py` assign `/Assets/Audio/` to `@AI-06`, contradicting `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md`. Both files are explicitly labelled examples; correction belongs to AI-13/AI-12.

## 15. Companion documents (AI-08 owned)

- `09_ART_AUDIO/AUDIO/AUDIO_CUE_ID_POLICY_DRAFT.md` — DRAFT ID namespace and registry rules (to be frozen in Phase 01).
- `09_ART_AUDIO/AUDIO/fixtures/audio_cue_registry_draft.v0.1.0.json` — DRAFT machine-readable registry fixture (non-production).
- `09_ART_AUDIO/AUDIO/scripts/validate_audio_cue_registry.py` — deterministic validator.
- `09_ART_AUDIO/AUDIO/PHASE_00_HANDOFF_AI-08.md` — evidence and handoff.
