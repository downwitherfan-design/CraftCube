# CraftCube — Performance Product Lock (Phase 00) — AI-11

| Field | Value |
|---|---|
| Owner | AI-11 — Performance / Android / Device Optimization |
| Document ID | `CC.PERF.LOCK` (design vocabulary; not a localization key, not a content ID) |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW |
| Phase | 00 — Product/IP Lock |
| Baseline inspected | `origin/main` @ `584141c`; sibling Phase 00 branches inspected at the commits listed in §2 |
| Canonical intent sources | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` §13 ("performant across Android tiers"), `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` DD-010, DD-015, `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` §Performance budgets, `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate E |

## 0. What this document is and is not

The Phase 00 mission is to lock *platform assumptions, success criteria and measurable boundaries*.
AI-11's share of that mission is to turn "performant across Android tiers" into something every
other track can design against **today**, without inventing a single device result.

This document therefore:

- states every platform/performance assumption with its evidence class;
- defines the **measurable boundaries** AI-11 will hold (as numbered hypotheses, `PERF-###`);
- defines **how a hypothesis becomes a measured fact** (see `MEASUREMENT_METHOD_STANDARD.md`);
- names what downstream tracks may rely on now versus what must wait for Phase 01/02 evidence.

It does **not** contain a measurement. The repository has no engine project, no build and no
device at commit `584141c`, so any FPS, ms, MB or °C value presented as a result would be a
fabricated repository fact. Every number below is labelled `HYPOTHESIS`.

## 1. Performance pillars (AI-11 reading of the product hierarchy)

Product pillars are owned by AI-01 (`PRODUCT_LOCK_V1.md` §3, branch `ai-01-product`). AI-11 does
not restate or rank them. It derives the performance consequences:

| # | Performance pillar | Derived from | Consequence for budgets |
|---|---|---|---|
| PP-1 | **The cube never stutters.** | Bible §3 rank 1 (puzzle mastery), Bible §13 "responsive on touch devices" | Puzzle interaction (touch → twist preview → commit → settle) is the highest-priority frame-time consumer. Every other system yields to it under load. |
| PP-2 | **World reaction stays visible on Low tier.** | Bible §3 rank 2 (causality); AI-01 §10 "solve → visible world reaction ≤ 2 s" | Fallback tiers may *simplify* a world-state transition (fewer particles, shorter glide) but may never *remove* or *delay beyond the product bound* the visible consequence. |
| PP-3 | **Fallback never changes gameplay truth.** | DD-001, DD-002; AI-11 Track "performance fixes must preserve behavior" | Quality tier is a presentation-only input. Domain/simulation (AI-02) must have zero dependency on it. Save data must never depend on the tier. |
| PP-4 | **Interruptions cost frames, not state.** | AI-01 §4 interruption safety; AI-04 LC-01..LC-06 | Backgrounding, thermal throttling and low-battery mode may drop quality; they must not be able to cause data loss (that is AI-02/AI-10's gate; AI-11's duty is to never *trigger* it via memory pressure). |
| PP-5 | **Low tier is a first-class player, not a compatibility checkbox.** | Bible §13; DD-010 "Android-first reality"; AI-07 P4 "UI must remain readable on low tier" | Low tier gets the same content, the same puzzle, the same story. It gets fewer pixels, particles and lights — never fewer chapters. |

## 2. Platform assumptions (each row carries its evidence class)

Sibling-track facts were read from the following branch heads (VERIFIED by `git show`):
`ai-01-product` `2db84b5`, `ai-04-gameplay`, `ai-05-world`, `ai-06-creatures`, `ai-07-uiux`,
`ai-02-core` (all inspected 0 commits behind their remote at time of writing; none merged to `main`).

| # | Assumption | Class | Source / note |
|---|---|---|---|
| PA11-01 | Primary platform is Android phones. | VERIFIED (product intent) | DD-010; Bible §13; AI-01 §5 row "Primary platform". |
| PA11-02 | Engine direction is Unity 6 + URP. | VERIFIED (architecture intent) | `TECHNICAL_BLUEPRINT.md` §Engine. **No** Unity project, `ProjectSettings/` or `Packages/manifest.json` exists in the repo (VERIFIED by tree listing). |
| PA11-03 | Exact Unity version string, URP version, scripting backend, and Android target/min API level. | UNKNOWN | Not in repository. Owner of the decision: AI-12 (build) with AI-13 governance (protected zone `Packages/manifest.json`, `ProjectSettings/` per `MULTI_AI_OPERATING_MODEL.md` اصل 5). Recorded as `U11-01`. |
| PA11-04 | Device tiers Low / Mid / High / Tablet exist as a QA template. | VERIFIED (template only) | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`. Its `Owner` column reads AI-07 / AI-05, which contradicts the v7 account matrix where AI-11 owns the device matrix. Recorded as `CONFLICT C11-01`; AI-11 does not edit that file. |
| PA11-05 | Frame targets: 60 FPS on Mid tier, 30 FPS "low-power mode". | VERIFIED (as hypothesis in doc) | Blueprint: "Baseline budgets are hypotheses until measured". Restated below as `PERF-001`/`PERF-002` with the same status. |
| PA11-06 | Display refresh rates 60 Hz through 120 Hz must be handled. | VERIFIED (template) | Device matrix template lists 60 / 60-120 / 120. Consequence: **all AI-11 budgets are expressed in milliseconds and percentiles, never in frames or FPS alone.** Consistent with AI-04 rule "Time is in milliseconds". |
| PA11-07 | Offline core is mandatory. | VERIFIED | DD-015; Bible §12. Consequence: no performance feature (remote quality presets, remote config for tiers) may be required. Tier selection is fully local. |
| PA11-08 | Portrait is the primary orientation. | ASSUMED (inherited) | AI-01 §5 lists it as ASSUMED; AI-04 PA-05 lists it as ASSUMED with a decision flag. AI-11 inherits the same status; budgets below are orientation-independent. |
| PA11-09 | Memory ceiling is defined per test device after profiling. | VERIFIED (doc) | Blueprint §Performance budgets. AI-11 keeps this rule and adds a *tier-level* hypothesis in `PERF-010..012` so tracks can author assets now. |
| PA11-10 | Android background/foreground lifecycle, thermal throttling and battery-saver modes exist and vary by OEM. | ASSUMED (platform knowledge, version/OEM dependent) | No repository source. Consequence: AI-11 treats thermal and battery as **measured-on-device-only** dimensions; no numeric budget is stated in Phase 00 beyond a method (`PERF-020..022`). |
| PA11-11 | Haptics may be absent or on/off only. | VERIFIED (AI-04 IA-03, ASSUMED there) | Consumed as-is; no AI-11 budget impact except that haptic scheduling must not block the render thread (`PERF-031`). |
| PA11-12 | UI stack (uGUI vs UI Toolkit) is undecided and AI-07 asks AI-11 to validate on URP/mobile in Phase 02. | VERIFIED | AI-07 `D-UX-01`. Recorded as `IR-AI11-004` (AI-11 will measure both once a project exists). |

## 3. Terminology (AI-11 internal vocabulary; not player-facing; not localization keys)

AI-09 owns player-facing terminology and localization keys. AI-01 approved product nouns. The terms
below are **engineering vocabulary for AI-11 artifacts** so every track uses the same words for the
same performance concept. Search over all branches (`git grep` for each stem) found no prior
definitions of these terms.

| Term | Definition | Do not confuse with |
|---|---|---|
| **Device tier** | A capability class of hardware: `low`, `mid`, `high`. Determined by measurement, not marketing. See `ANDROID_DEVICE_TIER_MATRIX_V1.md`. | Biome **transformation tier** 0–4 (AI-05/World Biome Bible) — a gameplay/world concept. AI-11 documents always say *device tier* or *quality tier*, never bare "tier", when ambiguity is possible. |
| **Quality tier** | The presentation preset the runtime actually applies (`low`, `mid`, `high`). Usually equals device tier; may be lowered at runtime (thermal, battery-saver, player setting). Never raised above device tier automatically. | Device tier (what the hardware *can* do). |
| **Fallback** | A quality-tier reduction applied at runtime in response to a measured condition (thermal state, sustained frame-time miss, battery-saver). Fallbacks are **visible in a debug overlay**; they are never silent. | A "graceful degradation" that hides a defect. Forbidden by Master Prompt "no silent fallbacks". |
| **Budget** | A per-tier upper bound for a metric, versioned in the `PerformanceBudget` contract. | A *target* (what we aim for) — budgets are ceilings; targets may be tighter. |
| **Frame-time p50 / p95 / p99** | Percentiles of per-frame wall time over a defined capture window and scene. | Average FPS, which hides hitches. AI-11 never accepts an average as gate evidence. |
| **Hitch** | A single frame exceeding the tier's hitch bound (`PERF-004..006`). | A sustained miss (many consecutive frames over budget). |
| **Steady state** | The capture window after load/warm-up during which the scene content is stable (e.g., idle puzzle, mid-twist loop). | Load or transition windows, which have their own budgets. |
| **Interaction latency** | Wall time from touch-down (OS event timestamp) to the first frame presenting the corresponding visual response. Measured with a high-speed camera or the platform's frame-timing API — method fixed in `MEASUREMENT_METHOD_STANDARD.md`. | Input *classification* latency (`TAP_MS`, `HOLD_MS`), which is an AI-04 design tunable. |
| **Resident memory** | Process memory as reported by the platform (`PSS`/`RSS` class metric, exact API fixed in the method standard) at a defined checkpoint. | Engine heap alone, which ignores native/GPU allocations. |
| **Managed allocation rate** | Bytes allocated per frame on the managed heap in steady state. | Total heap size. |

## 4. Measurable boundaries — `PERF-###` (all HYPOTHESIS; none measured)

Rules for this table:

- **ID stem `PERF-`** was searched over all 14 branches before use: absent → assigned to AI-11.
- All numbers are **ceilings** (worst acceptable), not targets, unless the row says "target".
- Product ceilings from AI-01 (`IGM-006b`: "no single frame > 100 ms on low tier"; `IGM-006e`:
  "≤ 150 MB install, ≤ 5 s to interactive, placeholders") are **respected and tightened**, never
  loosened. Where AI-11 is stricter, the AI-11 value governs engineering; the AI-01 value remains
  the product gate.
- Values become MEASURED only via the method standard and are then recorded in the fixture with
  evidence. Until then, treat them as design constraints, not facts.

### 4.1 Frame time and pacing

| ID | Boundary | Low | Mid | High | Why this number | Product link |
|---|---|---|---|---|---|---|
| PERF-001 | Steady-state frame-time **p95** during interactive puzzle (idle + twist loop) | ≤ 33.3 ms | ≤ 16.7 ms | ≤ 16.7 ms (8.3 ms target on 120 Hz) | Blueprint 30/60 FPS hypotheses expressed as p95 ms so 120 Hz devices are covered | Blueprint §Performance budgets |
| PERF-002 | Steady-state frame-time **p99** during interactive puzzle | ≤ 50 ms | ≤ 25 ms | ≤ 20 ms | p99 catches "occasional stutter" that p95 hides | Gate E "frame pacing stable" |
| PERF-003 | Frame-time p95 during world-state transition (biome tier change VFX + camera Reaction Framing) | ≤ 40 ms | ≤ 20 ms | ≤ 16.7 ms | Transitions are the heaviest presentation moment; Low may drop to ~25 FPS momentarily but must not hitch | PP-2; AI-04 `REACTION_FRAMING_MAX_MS` 1200 ms |
| PERF-004 | Single-frame **hitch bound** (any frame, any scene, after load) | ≤ 100 ms | ≤ 50 ms | ≤ 33 ms | Low bound equals AI-01 `IGM-006b` HARD line; Mid/High tightened | AI-01 `IGM-006b` |
| PERF-005 | Hitch **count** per 10-minute steady-state capture | ≤ 3 | ≤ 1 | 0 | Rare hitches are tolerable on Low; a "no critical spikes" Mid must be near-zero | Device template "no-critical-spikes" |
| PERF-006 | Consecutive frames over `PERF-001` before a runtime fallback is *considered* | 120 frames | 120 frames | 120 frames | ~2–4 s of sustained miss; avoids flapping on a single hitch. Fallback decision logic is Phase 02+ | Fallback policy §6 |

### 4.2 Interaction latency (touch → visible response)

| ID | Boundary | Low | Mid | High | Why | Product link |
|---|---|---|---|---|---|---|
| PERF-007 | Touch-down → first visual change (twist preview/"ghost" begins) **p95** | ≤ 100 ms | ≤ 70 ms | ≤ 50 ms | Below common perceptual "instant" thresholds for direct manipulation; Low allows one extra 33 ms frame | Blueprint "no input-to-feedback delay noticeable"; Bible §13 |
| PERF-008 | Twist **commit** → puzzle state visually updated (before Settle animation completes) **p95** | ≤ 66 ms | ≤ 33 ms | ≤ 25 ms | Two Low frames / two Mid frames | PP-1 |
| PERF-009 | Solve confirmed → **first visible world reaction** begins | ≤ 500 ms | ≤ 300 ms | ≤ 300 ms | AI-01 product bound is ≤ 2 s to *visible reaction*; AI-11 budgets the *start* so the remaining time is authored animation, not load stall | AI-01 §10 "≤ 2 s"; PP-2 |

### 4.3 Memory

| ID | Boundary | Low | Mid | High | Why | Product link |
|---|---|---|---|---|---|---|
| PERF-010 | **Resident memory** ceiling during gameplay (single biome loaded, HUD, companion, 1 transition in flight) | ≤ 350 MB | ≤ 600 MB | ≤ 900 MB | Placeholder ceilings so asset tracks can author now; Low is set for devices in the 2–3 GB RAM class where background kill pressure is high. Replaced by per-device measured ceilings (Blueprint rule) | Blueprint "memory ceiling defined per test device after profiling" |
| PERF-011 | Resident environment **texture** memory per loaded biome | ≤ 64 MB | ≤ 128 MB | ≤ 192 MB | Low value **adopts** AI-05's pending proposal verbatim so AI-05 is unblocked; Mid/High scaled | AI-05 `ENVIRONMENT_ART_DIRECTION_LOCK_V1.md` §Materials "PENDING AI-11 budget" |
| PERF-012 | Managed **allocation rate** in steady-state interactive puzzle (excluding first 5 s after load) | ≤ 8 KB/frame | ≤ 4 KB/frame | ≤ 4 KB/frame | Keeps GC cadence low; "no repeated GC spikes in common loop" | Gate E |
| PERF-013 | UI layer managed allocation in steady state | 0 B/frame | 0 B/frame | 0 B/frame | **Adopts** AI-07 `UXM-11` verbatim | AI-07 `UXM-11` |
| PERF-014 | Save/World-memory serialized payload for one full profile (all chapters, all flags) | ≤ 256 KB | ≤ 256 KB | ≤ 256 KB | World Memory "with restraint" (V7.1 §2.4); keeps atomic writes fast and interruption-safe. Value is a hypothesis for AI-02 to confirm against the SaveSchema once drafted | V7.1 §2.4; DD-013 |

### 4.4 Rendering and scene composition (authoring ceilings)

| ID | Boundary | Low | Mid | High | Why | Product link |
|---|---|---|---|---|---|---|
| PERF-015 | Draw calls per frame (after batching), gameplay view | ≤ 80 | ≤ 150 | ≤ 250 | Mobile tile-GPU friendly; Low is strict because one biome + cube + HUD + companion must fit | Gate E |
| PERF-016 | Real-time **shadow-casting lights** per scene | ≤ 1 | ≤ 1 | ≤ 2 | **Adopts** AI-05 lighting rule ("no more than one real-time shadow-casting light on Low/Mid") | AI-05 §Lighting |
| PERF-017 | Simultaneous transient **VFX systems** on screen during interactive puzzle | ≤ 2 | ≤ 3 | ≤ 4 | AI-06 `VFX-R8` proposes ≤ 3 as hypothesis; AI-11 tightens Low to 2 (readability + fill-rate) and allows 4 on High | AI-06 `VFX-R8` |
| PERF-018 | Particle systems spawned per environment **state beacon** per transition | ≤ 1 | ≤ 2 | ≤ 3 | **Adopts** AI-05 rule for Low verbatim | AI-05 §Performance |
| PERF-019 | Render resolution scale (relative to native) | 0.70–0.85 | 0.85–1.0 | 1.0 | Gives Low tier its largest single GPU win without touching content; exact value chosen per measured device | PP-5 |

### 4.5 Thermal and battery (method-only in Phase 00; numeric budgets are deferred by design)

| ID | Boundary | All tiers | Why no number yet |
|---|---|---|---|
| PERF-020 | 30-minute continuous-play **thermal** capture: record platform thermal-status transitions and frame-time p95 per 5-minute bucket | Method required; pass criterion set after first measurement | Thermal headroom varies by OEM chassis more than by SoC; a Phase 00 number would be invented. What is locked: **the capture method and that the runtime must observe thermal status** (`IR-AI11-003`). |
| PERF-021 | 30-minute continuous-play **battery** drain (% and mWh where the platform exposes it), screen at fixed brightness | Method required; pass criterion set after first measurement | Same reason. Locked: the method and the comparison baseline (system idle at same brightness). |
| PERF-022 | Fallback engaged by thermal status must be **reversible** when status clears and **visible** in the development overlay | Required behaviour | Master Prompt "no silent fallbacks". |

### 4.6 Load, install and startup

| ID | Boundary | Low | Mid | High | Why | Product link |
|---|---|---|---|---|---|---|
| PERF-023 | Cold start → interactive title/continue (first accepted touch) | ≤ 5.0 s | ≤ 3.0 s | ≤ 2.0 s | Low adopts AI-01 `IGM-006e` placeholder ceiling; Mid/High tightened | AI-01 `IGM-006e` |
| PERF-024 | Chapter/biome load from continue → first accepted puzzle touch | ≤ 4.0 s | ≤ 2.5 s | ≤ 2.0 s | On-demand chapter packs are the Blueprint's assumption | Blueprint §Performance budgets |
| PERF-025 | Initial install size (download) | ≤ 150 MB | — | — | Adopts AI-01 `IGM-006e` placeholder; artifact size is AI-12's measurement | AI-01 `IGM-006e`; AI-12 |
| PERF-026 | Save write (atomic) blocks the render thread for | 0 ms | 0 ms | 0 ms | Save must be off the render thread; interruption safety must not cost a hitch | PP-4; AI-01 §4 |

### 4.7 Systems added by v7 (story, world memory, inventory, equipment, companions, discovery)

These systems are new in v7 and have **no** budgets anywhere in the repository. AI-11 sets authoring
ceilings so their owners (AI-02/03/06/07/09) can design now.

| ID | System | Boundary (all tiers unless noted) | Why | Owner consuming |
|---|---|---|---|---|
| PERF-027 | Story presentation (dialogue + environmental beat) | Presenting a dialogue line or narrative event must add ≤ 2 ms to frame time on Mid and allocate ≤ 1 KB per line shown | Story is concise by product rule (≤ 40 words pre-solve); presentation must be as light as the text | AI-09 (content), AI-07 (UX) |
| PERF-028 | World-memory / narrative-memory flag evaluation | Evaluating all active flags for a scene must complete in ≤ 0.5 ms on Low, run at most once per state change (never per frame) | DD-013 "controlled flag set"; AI-01 ≤ 6 flags per chapter | AI-02, AI-09 |
| PERF-029 | Inventory/equipment/collection data | Full profile inventory (≤ 12 equipment items at release per AI-01 §7.1, plus collectibles) loads in ≤ 50 ms on Low; equipment-effect resolution (Puzzle Affinity lookup) ≤ 0.2 ms per query | Affinity is a data lookup, not a simulation | AI-02, AI-03, AI-07 |
| PERF-030 | Companion (Nox) runtime | Single skinned mesh, ≤ 32 bones (adopts AI-06 hypothesis), 2 LODs, ≤ 1 active reaction (adopts AI-06 arbitration rule); companion total ≤ 1.5 ms CPU + GPU on Low | Companions "add meaning, not bloat" (DD-007) | AI-06 |
| PERF-031 | Haptic / audio cue scheduling | Dispatching a haptic or audio cue must never block the render thread; ≤ 0.1 ms dispatch cost | AI-04 IA-03; Gate D | AI-04, AI-08 |
| PERF-032 | Discovery / secret evaluation | Deterministic; evaluated on state change, never per frame; ≤ 0.5 ms on Low | "Discoveries must be optional, testable and save-safe" | AI-03 |

### 4.8 Complexity budget items AI-11 will track (V7.1 §16)

| ID | Count tracked | Phase 00 ceiling | Why |
|---|---|---|---|
| PERF-033 | Distinct **quality tiers** | 3 (`low`, `mid`, `high`) | More presets = more QA permutations without measured benefit. Tablet is a *layout* class (AI-07), not a quality tier. |
| PERF-034 | Distinct **runtime fallback triggers** | ≤ 3 (thermal status, sustained frame miss, battery-saver) | Each trigger needs a test; keep the set small and observable. |
| PERF-035 | Distinct **per-tier tunables** exposed in `PerformanceBudget` | ≤ 12 at v1 | Every tunable is a permutation asset tracks must author for. |

## 5. Success criteria for AI-11's Phase 00 contribution

The Phase 00 gate asks whether platform assumptions, success criteria and measurable boundaries are
clear. For AI-11 that is true when **all** of the following hold:

| # | Criterion | How verified | State at this commit |
|---|---|---|---|
| S11-1 | Every performance-relevant assumption has an evidence class and, if UNKNOWN, a recorded owner. | §2 table; `INTEGRATION_REQUESTS_AND_UNKNOWNS.md` | DONE |
| S11-2 | Every measurable boundary has a stable ID, per-tier value, rationale and product link. | §4; fixture; validator run | DONE (as HYPOTHESIS) |
| S11-3 | No boundary loosens a product ceiling set by AI-01. | Cross-check `IGM-006b`, `IGM-006e`, §10 causality ≤ 2 s | DONE — Low hitch = 100 ms (equal), cold start Low = 5 s (equal), install = 150 MB (equal), reaction start ≤ 500 ms < 2 s |
| S11-4 | Every pending "PENDING AI-11" / "HYPOTHESIS until AI-11" item raised by a sibling track is either adopted or answered. | AI-05 texture/lighting/particles → `PERF-011/016/018`; AI-06 `VFX-R8`, rig → `PERF-017/030`; AI-07 `UXM-11`, `D-UX-01` → `PERF-013`, `IR-AI11-004`; AI-01 platform rows → §2, `IR-AI11-001`; AI-04 latency → `PERF-007/008` | DONE |
| S11-5 | A machine-readable form exists and is validated, so downstream tracks can consume numbers programmatically. | `fixtures/performance_budget/budget_hypothesis_v0.json` + `tools/validate_performance_budget.py` exit 0 | See handoff evidence |
| S11-6 | The validator **rejects** a `MEASURED` entry with no evidence. | Negative fixture test in the validator | See handoff evidence |
| S11-7 | Device tiers are defined **without** fabricated device names. | `ANDROID_DEVICE_TIER_MATRIX_V1.md` | DONE |
| S11-8 | No file outside AI-11 ownership was modified, except AI-11's own section of `00_CONTROL/PROGRESS.md` (explicitly permitted by that file). | `git diff --stat origin/main..HEAD` | See handoff ownership audit |

## 6. Fallback (quality tier) policy — locked principles, mechanism deferred

Locked in Phase 00 (design truth):

1. Quality tier is **presentation-only**. The domain (AI-02) receives no tier input. Puzzle legality,
   scoring, progression, world memory and saves are tier-independent. (PP-3)
2. **Three** tiers only (`PERF-033`).
3. Initial tier = device tier from the matrix classification; the player may lower it; the runtime
   may lower it on a measured trigger (`PERF-034`) and must restore it when the trigger clears
   (`PERF-022`).
4. Every automatic fallback is **logged and visible** in development builds. Release builds record
   it in the (opt-in, privacy-minimal) `TelemetryEvent` stream *if* telemetry exists — never as a
   requirement (DD-015).
5. Fallback must never disable: the visible world reaction to a solve (PP-2), any accessibility
   feature (`AccessibilityPreference` — AI-11 may *read* `reduce_motion` to skip cosmetic motion
   earlier on Low, but never writes the block), any story beat, any save.
6. `reduce_motion == true` is **not** a performance fallback and must not be conflated with one; it
   is a player comfort choice (AI-07). AI-11 may use it as an *additional* reason to skip cosmetic
   particle motion, with no behavioural difference beyond what AI-07 already specifies.

Deferred to Phase 01/02: the concrete trigger thresholds, hysteresis, and the API through which
presentation systems read the current tier (part of `PerformanceBudget` contract freeze).

## 7. What downstream tracks may rely on **now**

| Track | May rely on | Must not assume |
|---|---|---|
| AI-02 | `PERF-012`, `PERF-014`, `PERF-026`, `PERF-028`, `PERF-029`, `PERF-032` as allocation/latency design constraints; PP-3 (no tier input to domain). | Any measured value. |
| AI-03 | `PERF-029`, `PERF-032`; chapter load `PERF-024` when sizing chapter packs. | That Low tier gets fewer puzzles or chapters. |
| AI-04 | `PERF-007..009` as the latency ceilings AI-04 asked AI-11 to set. | Frame-count based thresholds (`PA11-06`). |
| AI-05 | `PERF-011`, `PERF-015`, `PERF-016`, `PERF-018`, `PERF-019`; LOD bias/culling per tier is an AI-11 tunable (`PERF-035`). | That texture ceilings are final — they are the adopted hypothesis. |
| AI-06 | `PERF-017`, `PERF-030`. | More than one active companion reaction. |
| AI-07 | `PERF-013` (adopted from `UXM-11`), `PERF-027`; AI-11 reads `AccessibilityPreference.reduce_motion` (consumer, never writer). | That AI-11 has picked a UI stack (`IR-AI11-004` pending). |
| AI-08 | `PERF-031`. | Audio budget numbers (voices, memory) — deferred to Phase 01 with AI-08's cue list. |
| AI-09 | `PERF-027`, `PERF-028`. | Any tier-dependent story content. |
| AI-10 | `PERF-###` IDs as test targets; the measurement method standard as the procedure. | That any `PERF-###` has passed. |
| AI-12 | `PERF-023`, `PERF-025`; build must expose build ID for evidence. | A chosen Android API level (`U11-01`). |
| AI-13 | `PERF-`, `IR-AI11-`, `U11-`, `C11-`, `D-PERF-`, `PP-`, `PA11-`, `S11-` as new stable ID families owned by AI-11, for the governance registry. | — |

## 8. Unresolved Product/Human decisions (deferred — not guessed)

| Item | Why AI-11 cannot decide | Owner |
|---|---|---|
| Minimum Android API level and target API | Store policy + build pipeline decision; changes which "Low" hardware exists | AI-12 → AI-13 → Human (store policy interpretation is a human gate, V7.1 §17) |
| Whether the lowest supported device class includes ~2 GB RAM phones | Product audience/market decision with cost consequences | AI-01 → Human |
| Whether to ship a player-facing "Performance mode" toggle vs automatic-only | UX and product decision | AI-01 / AI-07 |
| Whether telemetry (and therefore remote performance evidence) exists at all | Privacy/legal human gate | Human |

## 9. Change control

Additive clarification → patch. Changing any `PERF-###` value → minor version **plus** an entry in
`INTEGRATION_REQUESTS_AND_UNKNOWNS.md` §Decisions (`D-PERF-##`) stating old value, new value,
evidence, and affected tracks. Replacing a HYPOTHESIS with MEASURED is *not* a value change if the
measured result is within the ceiling; it is an evidence update to the fixture.
