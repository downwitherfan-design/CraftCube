# CraftCube — Investment Gate Metrics

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.IGM` |
| Version | 1.0.2 |
| ID family | `IGM-###` (Investment Gate Metric). Immutable once released. |
| Extends | `01_PREPRODUCTION/INVESTMENT_GATE.md` (Gates A–D) and `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md` §Investment Gate extension |
| Applied at | Phase 00 exit (documentation form), Phase 06 Gold Slice (measured form), Phase 15 soft launch (live form) |

## Purpose

`INVESTMENT_GATE.md` says *what* must be true. This document says *how we will know*, with a number, a method, a minimum sample, and an owner for each of the six product dimensions the Phase 00 prompt requires: **fun, clarity, uniqueness, equipment value, story curiosity, mobile feasibility** — plus two product-added dimensions (**causality**, **retention intent**) that the Master Control Prompt's gate extension requires.

## Honesty rules for this document

- Every threshold below is a **product target set before measurement**. None has been measured. No metric in this file is evidence.
- Thresholds are deliberately set at "clearly good enough to justify spending", not "world-class". World-class is judged at Phase 15/16 with live data.
- If a metric cannot be measured with the stated method, the gate result for that metric is `UNMEASURED`, never `PASS`.
- Playtest cohorts: minimum **8** fresh participants per iteration for Phase 06; minimum **30** for Phase 15. Below minimum → `UNDERPOWERED`, reported but not used to pass a gate.
- Product may tighten thresholds later; loosening a threshold requires a new `PD-###` with the reason recorded.

## Gate outcome rule

For the Phase 06 Gold Slice gate:
- **PASS** — all `MUST` metrics ≥ threshold and no `MUST` metric `UNMEASURED`.
- **CONDITIONAL** — ≤ 2 `MUST` metrics within 10 percentage points (or 10%) below threshold, each with a named mitigation owner and a re-test date.
- **FAIL** — any `MUST` metric more than 10 points below threshold, or any `HARD_STOP` condition triggered.

`SHOULD` metrics inform scope decisions (`PD-009`, `PD-015`) but do not fail the gate alone.

---

## Dimension 1 — Fun

### IGM-001 — Voluntary continuation
- **Priority:** MUST
- **Question:** Do players want one more solve without being asked?
- **Method:** At the end of the scripted 10-minute protocol (`FIRST_10_MINUTES_PROOF.md`), the observer says "You can stop here or keep going." Record whether the participant continues ≥ 3 more minutes unprompted.
- **Threshold:** ≥ 60% continue.
- **Owner:** AI-10 (protocol), AI-01 (threshold).

### IGM-001b — Solve ownership
- **Priority:** MUST
- **Question:** Does the solve feel earned even with assist?
- **Method:** Exit question "Did you figure it out yourself, or did the game do it for you?" (3-point scale: me / mix / game).
- **Threshold:** ≥ 70% answer "me" or "mix"; ≤ 10% answer "game".
- **HARD_STOP:** > 30% "game" → the protected core is compromised (DD-001).

---

## Dimension 2 — Clarity

### IGM-002 — First-session comprehension
- **Priority:** MUST
- **Method:** Composite of `F10-001` (deliberate twist ≤ 90 s: ≥ 90%), `F10-002` (median time-to-first-solve ≤ 3:00), `F10-006` (value-prop restatement: ≥ 70%).
- **Threshold:** all three sub-conditions met.
- **HARD_STOP:** median time-to-first-solve > 5:00.
- **Owner:** AI-10 (measurement), AI-07/AI-04 (fix ownership).

### IGM-002b — Menu comprehension (Gold Slice only)
- **Priority:** MUST
- **Method:** Task: "change the item in your loadout." Record success without help on first attempt.
- **Threshold:** ≥ 80% (matches `PD-003`).

---

## Dimension 3 — Uniqueness

### IGM-003 — Differentiation in the player's words
- **Priority:** MUST
- **Method:** Exit question "In one sentence, what is this game about?" Coded by two independent raters against two lists: **CraftCube-distinct concepts** (cube changes world / restoring a world / mystery of why it broke / creature that reacts / tools that reveal) and **generic/competitor concepts** (Rubik's cube app / Minecraft-like / match-3 / RPG / building game).
- **Threshold:** ≥ 60% of answers contain ≥ 1 distinct concept; ≤ 20% contain a competitor name or "like [franchise]" as the *primary* description.
- **HARD_STOP:** ≥ 40% describe it primarily as "a Rubik's cube app" or "Minecraft-like" → identity failure; escalate to Human Product Authority.
- **Owner:** AI-01 (coding lists), AI-10 (collection).

### IGM-003b — Competitor review (Phase 00 documentation form)
- **Priority:** MUST (documentation)
- **Method:** `INVESTMENT_GATE.md` Gate A requires a review of the top 5 direct/adjacent competitors.
- **Status (v1.0.1): PRESENT** — `COMPETITOR_REVIEW.md` v1.0.0 reviews five adjacent titles with store-listing-verified facts and a per-title differentiation claim, and supplies the coding lists for `IGM-003`. Gate A item is satisfied at documentation level; **Human confirmation of the differentiation claim (§2 of that document) is still open** because product taste is a human gate (`V7_1_WORLDCLASS_UPGRADE.md` §17). Until that confirmation is recorded the item is `CONDITIONAL (human review)`, not `MISSING`.

---

## Dimension 4 — Equipment value

### IGM-004 — "It let me do something differently"
- **Priority:** MUST
- **Method:** Exit question "Did any object you found let you do something new? What?" Answer coded as: *behavioral* (see/reach/reveal/compare/stabilize…), *numeric* (stronger/faster/more points), *none/unsure*.
- **Threshold:** ≥ 60% behavioral; ≤ 10% numeric.
- **HARD_STOP:** any equipment in the slice is described by ≥ 30% of players as "made it easier/solved it for me" → violates DD-002.
- **Owner:** AI-01 (coding), AI-03/AI-09 (item design ownership).

### IGM-004b — Loadout tension
- **Priority:** SHOULD
- **Method:** Telemetry-free observation: does the participant swap a loadout item at least once during the Gold Slice when facing the second biome/condition?
- **Threshold:** ≥ 40%.

---

## Dimension 5 — Story curiosity

### IGM-005 — An unanswered question
- **Priority:** MUST
- **Method:** Exit question "Is there anything you want to find out?" Record whether the answer names a world/story question (not a UI question).
- **Threshold:** ≥ 60% name a story/world question.
- **Owner:** AI-09 (content), AI-10 (collection).

### IGM-005b — No lore-wall complaints
- **Priority:** MUST
- **Method:** Exit question "Was there too much reading or too many cutscenes?"
- **Threshold:** ≤ 10% "yes".
- **Validator companion:** `[VALIDATOR]` total mandatory text in minutes 0–10 ≤ 120 words (`F10-004`).

### IGM-005c — Character recall
- **Priority:** SHOULD
- **Method:** "What do you remember most?" — unprompted mention of Nox, Mira or Orin.
- **Threshold:** ≥ 50% mention Nox (`PD-005`); ≥ 30% mention any human character.

---

## Dimension 6 — Mobile feasibility

All numbers in this dimension are **product ceilings**. AI-11 owns engineering budgets and may set stricter ones. Every value is a HYPOTHESIS until AI-11 publishes measurements with device model, OS, build ID and method (`08_QA_RELEASE/EVIDENCE_STANDARD.md`).

### IGM-006 — Input reliability
- **Priority:** MUST
- **Method:** Count unintended face rotations / camera moves per 10 minutes on mid-tier device, observed + logged by the build's debug counter (AI-04 to provide).
- **Threshold:** ≤ 2 unintended actions per 10 minutes, median across cohort.
- **HARD_STOP:** > 5.

### IGM-006b — Frame-time on low tier
- **Priority:** MUST
- **Method:** AI-11 profiler capture during a twist sequence in the Gold Slice on the lowest device in the AI-11 matrix.
- **Threshold:** no single frame > 100 ms; 95th-percentile frame time consistent with the 30 FPS safe mode in `TECHNICAL_BLUEPRINT.md`.
- **Status:** device matrix MISSING in repo; metric is `UNMEASURED` until AI-11 publishes it.

### IGM-006c — Interruption recovery
- **Priority:** MUST
- **Method:** `F10-007` forced interruption; automated save/kill/reload test (AI-10).
- **Threshold:** 100% of trials restore puzzle state, world state, loadout, discovery ledger and memory flags. Any data loss → HARD_STOP.

### IGM-006d — Offline completeness
- **Priority:** MUST
- **Method:** Full Gold Slice in airplane mode.
- **Threshold:** completable with zero network-related dialogs or blocks (`PD-010`).

### IGM-006e — Install size and cold start
- **Priority:** SHOULD
- **Method:** AI-12 build artifact size; AI-11 cold-start timing on low tier.
- **Threshold:** product wishes are ≤ 150 MB initial install and ≤ 5 s to interactive on low tier; these are placeholders for AI-11/AI-12 to confirm or replace with measured budgets. Not gate-blocking at Phase 06.

---

## Product-added dimensions

### IGM-007 — Causality recognition
- **Priority:** MUST
- **Method:** `F10-003` question "What did solving the cube do?" coded as *concrete world change* vs *abstract reward*.
- **Threshold:** ≥ 70% concrete world change.

### IGM-008 — Retention intent (proxy, pre-live)
- **Priority:** SHOULD (Phase 06); MUST (Phase 15 as measured D1/D7)
- **Method (Phase 06):** exit question "Would you play this again tomorrow if it were on your phone?" (yes / maybe / no) and "Why?" coded against the healthy-retention list (Bible §11: unexplored places, unresolved mysteries, mastery, collection, world change, companion, secrets, new puzzle language).
- **Threshold (Phase 06):** ≥ 50% "yes"; ≥ 70% of "yes/maybe" reasons map to the healthy list; **0%** of reasons cite a timer, reward schedule or fear of missing out (there must be none to cite).
- **Method (Phase 15):** D1 and D7 retention from opt-in telemetry (AI-12 `TelemetryEvent`), privacy-minimal per `02_ARCHITECTURE/ANALYTICS_PRIVACY_COMPETITIVE_ARCHITECTURE.md`.
- **Threshold (Phase 15):** set by Product after Phase 06 data; Product will not invent a retention benchmark before seeing the slice.
- **Monetization note (v1.0.2):** with `PD-027` (premium, no ads/IAP/subscription), retention has **no revenue function** at v1; it is measured solely as a product-quality signal. The "0% dark-pattern reasons" condition is therefore structurally guaranteed by the model and the metric checks that the design has not drifted.

---

## Gate B/D items this document does not measure

- **Gate B (technical feasibility):** owned by AI-02/AI-11/AI-12 evidence; Product consumes it.
- **Gate D (business protection):** monetization hypothesis is **decided** — premium one-time purchase (`PD-027`, HUMAN_DECIDED, supersedes `PD-014`); exact price not frozen; cut list is `CUT_LIST_AND_COMPLEXITY_BUDGET.md`; IP/licensing risk is `PRODUCT_LOCK_V1.md` §6 plus the risk register maintained by AI-13; title trademark clearance remains an open human/legal item (`PD-026`, `PD-029`).

## Summary table

| ID | Dimension | Priority | Threshold (short) | Phase measured | Owner |
|---|---|---|---|---|---|
| IGM-001 | Fun | MUST | ≥ 60% continue voluntarily | 06 | AI-10/AI-01 |
| IGM-001b | Fun | MUST | ≥ 70% "me/mix"; ≤ 10% "game" | 06 | AI-10 |
| IGM-002 | Clarity | MUST | F10-001/002/006 all met | 06 | AI-10 |
| IGM-002b | Clarity | MUST | ≥ 80% loadout task success | 06 | AI-07 |
| IGM-003 | Uniqueness | MUST | ≥ 60% distinct; ≤ 20% competitor-framed | 06 | AI-01 |
| IGM-003b | Uniqueness | MUST (doc) | competitor review exists | 00 | AI-01 + human |
| IGM-004 | Equipment | MUST | ≥ 60% behavioral; ≤ 10% numeric | 06 | AI-01 |
| IGM-004b | Equipment | SHOULD | ≥ 40% swap loadout | 06 | AI-07 |
| IGM-005 | Story | MUST | ≥ 60% name a question | 06 | AI-09 |
| IGM-005b | Story | MUST | ≤ 10% "too much reading" | 06 | AI-09 |
| IGM-005c | Story | SHOULD | ≥ 50% recall Nox | 06 | AI-06/AI-09 |
| IGM-006 | Mobile | MUST | ≤ 2 unintended inputs / 10 min | 06 | AI-04 |
| IGM-006b | Mobile | MUST | no frame > 100 ms low-tier | 06 | AI-11 |
| IGM-006c | Mobile | MUST | 100% state recovery | 06 | AI-02/AI-10 |
| IGM-006d | Mobile | MUST | offline completable | 06 | AI-12 |
| IGM-006e | Mobile | SHOULD | size/cold-start placeholders | 06 | AI-11/AI-12 |
| IGM-007 | Causality | MUST | ≥ 70% concrete change | 06 | AI-10 |
| IGM-008 | Retention | SHOULD→MUST | ≥ 50% "yes"; 0 dark-pattern reasons | 06→15 | AI-01 |
