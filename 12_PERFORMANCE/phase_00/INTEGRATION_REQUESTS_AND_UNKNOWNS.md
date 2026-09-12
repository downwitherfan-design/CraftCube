# AI-11 Phase 00 — Integration Requests, Unknowns, Conflicts and Decisions

| Field | Value |
|---|---|
| Owner | AI-11 |
| Status | READY_FOR_REVIEW |
| ID stems introduced here | `IR-AI11-###` (integration request), `U11-##` (unknown), `C11-##` (conflict), `D-PERF-##` (AI-11 decision) — each searched over all remote branches before use; none pre-existed. |

Rule: AI-11 does not edit another owner's files. Every cross-track need below is a request with the
exact file, required behaviour, contract impact and acceptance test, per the Ownership Firewall.

## 1. Integration requests (`IR-AI11-###`)

| ID | To | Request | Why | Acceptance |
|---|---|---|---|---|
| IR-AI11-001 | AI-01 | In `01_PREPRODUCTION/PRODUCT/PRODUCT_LOCK_V1.md` §5, update the rows "Device tiers … MISSING" and "Frame targets … HYPOTHESIS" to point at `12_PERFORMANCE/phase_00/ANDROID_DEVICE_TIER_MATRIX_V1.md` and `PERF-001/002`. Status may remain HYPOTHESIS; only the "MISSING" label is now inaccurate. | AI-01 asked for measured replacement; measured is not yet possible, but the definitions now exist. | Product Lock §5 references the two AI-11 documents. |
| IR-AI11-002 | AI-12 | Every build (dev and release) must expose a stable `build_id` (a) readable at runtime by the performance overlay and (b) written into the artifact manifest/checksum file, with (a) == (b). | Without it no measurement can be attributed to a build; the validator rejects `build_id: UNKNOWN`. | A build's runtime `build_id` string equals the manifest entry; verified in Phase 02 smoke build. |
| IR-AI11-003 | AI-12 / AI-13 | Confirm the Android build exposes platform thermal status and battery-saver status to the runtime (permission/API decision belongs to the build/platform layer). | `PERF-020..022` and fallback trigger `PERF-034` depend on observing thermal status. | Runtime can log thermal status transitions during `perf.scene.soak_30`. |
| IR-AI11-004 | AI-07 | AI-11 accepts `D-UX-01`: once a project exists (Phase 02), AI-11 will measure both candidate UI stacks against `PERF-013` (0 B/frame) and a UI draw-time budget (to be added as a `PERF-036+` entry) on a classified `mid` device and report. AI-07 keeps the decision. | AI-07 asked for it. | Measurement records for both stacks in `12_PERFORMANCE/evidence/`. |
| IR-AI11-005 | AI-13 | Register new AI-11 stable ID families in the governance ID registry once it exists: `PERF-###`, `perf.scene.*`, `IR-AI11-###`, `U11-##`, `C11-##`, `D-PERF-##`, `PP-#`, `PA11-##`, `S11-#`, document IDs `CC.PERF.LOCK`, `CC.PERF.DEVICE_MATRIX`, `CC.PERF.METHOD`. Also register contract `PerformanceBudget` DRAFT 0.1.0 and proposed contract `QualityTierState` (not yet drafted). | Collision prevention (`EVENT_AND_ID_POLICY.md`). | Registry rows exist. |
| IR-AI11-006 | AI-04 (with AI-02) | Expose the deterministic replayable Command path (AI-04 already requires replayable arbiter input) to a test harness so `perf.scene.puzzle_twist_loop` can drive twists without a finger, using the same Command route as touch. | Repeatable latency/frame captures. | Harness runs a fixed move list; AI-02 state after the run equals the replay's expected state (AI-10 asserts). |
| IR-AI11-007 | AI-13 (governance) | Reserve a small read-only runtime state contract `QualityTierState` (current quality tier + active fallback reason) owned by AI-11, consumers AI-05/06/07/08, for Phase 01 drafting. Explicitly **not** consumed by AI-02 domain. | Keeps `PerformanceBudget` static and lets presentation query the live tier without ad-hoc globals (anti-duplication). | Contract row added to the register in Phase 01. |
| IR-AI11-008 | AI-10 | Adopt `12_PERFORMANCE/phase_00/MEASUREMENT_METHOD_STANDARD.md` §2 record fields and §5 protocol as the harness output/procedure; emit records that pass `tools/validate_performance_budget.py`. Pass criteria are read from the fixture, never hard-coded in the harness. | Single source of truth for pass/fail. | Harness output validates with exit 0. |
| IR-AI11-009 | AI-02 | Confirm or replace `PERF-014` (≤ 256 KB full-profile save payload) against the SaveSchema draft; confirm the domain has **no** dependency on quality tier (PP-3). | Save/world-memory restraint; behaviour preservation. | AI-02 reply recorded as `D-PERF-##` if the number changes. |
| IR-AI11-010 | AI-08 | Provide the audio cue list / voice-count expectations in Phase 01 so AI-11 can add audio memory and voice budgets as additive `PERF-036+` entries. | Audio is the only runtime domain without a Phase 00 budget. | Entries added; fixture validates. |
| IR-AI11-011 | AI-10 / AI-13 | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` `Owner` column lists AI-07 / AI-05 for device tiers. Under the v7 account matrix, device matrix ownership is AI-11 and scene/gate ownership for UI layout remains AI-07. Requested: the file owner (08_QA_RELEASE is QA-adjacent) updates the `Owner` column or marks the CSV as superseded by `ANDROID_DEVICE_TIER_MATRIX_V1.md` for tier definitions. AI-11 has **not** edited the CSV. | `C11-01`. | Column corrected or CSV annotated. |

## 2. Unknowns (`U11-##`) — must not be guessed

| ID | Unknown | Impact on AI-11 | Owner of the answer | AI-11 mitigation now |
|---|---|---|---|---|
| U11-01 | Minimum and target Android API level; Unity version string; URP version; scripting backend. | Defines what "Low" hardware exists; affects thermal/battery API availability. | AI-12 → AI-13 → Human (store policy). | Tiers defined by measured capability, not by API level; `unsupported` rule set (`ANDROID_DEVICE_TIER_MATRIX_V1.md` §3). |
| U11-02 | Whether the lowest supported device class includes ~2 GB RAM phones. | Determines whether `PERF-010` low = 350 MB is tight enough. | AI-01 → Human. | 350 MB chosen to leave headroom on a 2–3 GB class; flagged for revision on decision. |
| U11-03 | Exact profiler/trace tool versions available in the build environment. | Evidence records must name them. | AI-12 (build environment). | Method standard names tool *classes*, requires exact version in each record. |
| U11-04 | Whether telemetry exists at all (privacy human gate). | Whether release fallback events are ever recorded remotely. | Human. | Fallback logging is local/dev-only by default; telemetry is never required (DD-015). |
| U11-05 | Audio cue count / voice count. | No audio budget in Phase 00. | AI-08. | `IR-AI11-010`. |
| U11-06 | Whether a player-facing "Performance mode" toggle ships. | Fallback policy §6 item 3 allows player lowering; UI is AI-07's. | AI-01 / AI-07. | Policy written so it is valid either way. |
| U11-07 | Whether landscape/tablet is in v1 scope. | Resolution-scale rules (`PERF-019`) would need a tablet check. | AI-01 (LATER per Product Lock §7.3). | Tablet treated as layout class, not quality tier (`PERF-033`). |

## 3. Conflicts (`C11-##`) — reported, not resolved by AI-11

| ID | Conflict | Sources | Recommendation | Owner |
|---|---|---|---|---|
| C11-01 | Device matrix template `Owner` column says AI-07 (Low/Mid/High) and AI-05 (Tablet); v7 account matrix, execution manual and AI-11 track say AI-11 owns the Android device matrix. | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` vs `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md`, `00_CONTROL/13_AI_EXECUTION_MANUAL.md` §AI-11 | The CSV predates the v7 renumbering (its owners match the older 8-account `CODEOWNERS_EXAMPLE.txt` scheme). Treat the CSV `Owner` as stale; tier definitions live in AI-11's matrix; AI-07 keeps UI-layout pass criteria. | AI-13 (governance) via `IR-AI11-011`. |
| C11-02 | `07_GITHUB/GITHUB_MODEL.md` says PRs target `integration`, but no `integration` branch exists on the remote (VERIFIED: `git ls-remote --heads origin integration` → empty). Remote branch names are `ai-11-performance`, not `ai-11/performance-android` as the model document shows. | `07_GITHUB/GITHUB_MODEL.md` vs `git ls-remote` | AI-11 pushes to `ai-11-performance` and reports; opening the PR is a stop condition until `integration` exists (AI-13). Also noted by AI-02 as `U-05` on its branch. | AI-13. |
| C11-03 | The word **"tier"** is used for biome transformation (0–4, AI-05/World Bible) and for device/quality classes (AI-11). | `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md` vs `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` | Not a blocking conflict; AI-11 documents always qualify as *device tier* / *quality tier*. AI-09 (terminology owner) may want a canonical rule. | AI-09 (advisory). |

## 4. Decisions taken by AI-11 inside its ownership (`D-PERF-##`)

| ID | Decision | Alternatives rejected | Reversible? |
|---|---|---|---|
| D-PERF-01 | Budgets are expressed as frame-time **percentiles in ms**, never FPS averages. | "60 FPS" style targets — hide hitches, break on 120 Hz. | Yes (presentation of the same data). |
| D-PERF-02 | Exactly **three** quality tiers (`PERF-033`); tablet is a layout class. | 4–5 presets incl. "ultra"/"tablet". | Yes, additive (would need a `D-PERF` + fixture change). |
| D-PERF-03 | **No device names** in Phase 00; classification by measured test only. | Listing popular phones per tier. | Yes — measured records are added, nothing removed. |
| D-PERF-04 | Thermal and battery get a **method and a required behaviour**, not a number, in Phase 00. | Inventing e.g. "≤ 8 %/30 min". | Yes — numbers are added when measured. |
| D-PERF-05 | Where a sibling track proposed a value marked "PENDING AI-11", AI-11 **adopts it verbatim** for the tier it was proposed for and records provenance in `adopted_from`, rather than replacing it with a different guess. | Overriding sibling hypotheses with AI-11's own. | Yes. |
| D-PERF-06 | Every AI-01 product ceiling (`IGM-006b`, `IGM-006e`, causality ≤ 2 s) is respected exactly or tightened; never loosened. | — | Loosening requires an AI-01 `PD-###`. |
| D-PERF-07 | Validator treats a **missing tier value as an error**, not a default. | Falling back to `mid` when a tier is absent. | Yes. |
| D-PERF-08 | Quality tier is **presentation-only**; no domain reader exists (PP-3). | Letting the simulation simplify on low. | Changing this would violate DD-001/DD-002 → Human gate. |

## 5. What AI-11 explicitly did NOT do in Phase 00 (and why)

- Did not create `12_PERFORMANCE/devices/` or `12_PERFORMANCE/evidence/` — their absence is evidence that nothing has been measured.
- Did not edit `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`, `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`, or `06_CONTRACTS/*` — not AI-11's files; requests filed above.
- Did not write engine code — no Unity project exists in the repository.
- Did not pick tools, API levels or devices — UNKNOWN, owners named.
- Did not open a PR — `integration` branch is missing (`C11-02`).
