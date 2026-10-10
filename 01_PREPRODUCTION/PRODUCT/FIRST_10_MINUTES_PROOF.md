# CraftCube — What the First 10 Minutes Must Prove

| Field | Value |
|---|---|
| Owner | AI-01 — Product / Game Direction |
| Document ID | `CC.PRODUCT.FIRST10` |
| Version | 1.0.0 |
| ID family | `F10-###` (First-10 proof point). Immutable once released. |
| Source requirement | `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §14 (six communication goals) |
| Consumers | AI-03 (chapter 1 puzzle design), AI-04 (interaction), AI-07 (onboarding UX), AI-09 (first-10-minute narrative), AI-10 (playtest protocol), AI-13 (gate) |

## Purpose

The first ten minutes are the product's only guaranteed audience. This document converts V7.1 §14's six goals into **proof points** with a measurable pass condition each, a rough time window, and the owning track. It is a product specification, not a level script — AI-03/AI-09 author the actual content; AI-07 authors the onboarding flow.

## Non-negotiables for the first session

1. **No lore wall.** Total mandatory reading before the first solve ≤ 40 words. No cutscene > 20 s before the first solve (`PRODUCT_LOCK_V1.md` §10).
2. **Hands on the cube inside 60 seconds** of app start (after first-launch permissions/loading, which AI-12/AI-11 keep minimal).
3. **The first solve is a real solve**, not a scripted single tap — but it is small (Product recommends a 2×2 or partially-scrambled configuration; AI-03 owns the exact choice).
4. **The world answers the first solve within 2 seconds**, visibly and audibly, in the place the player is looking.
5. **The companion appears because of the solve**, not before it — Nox is a *consequence*, which teaches P2 causality emotionally.
6. **The first item is found, not given by a menu**, and its first use is in the world, not in an inventory screen.
7. **No menu is opened by force** in the first 10 minutes. Menus may be *hinted* once.
8. **Interruption safety is demonstrated implicitly:** if the player backgrounds the app during minute 3, minute 4 resumes exactly where they were.

## Proof points

Time windows are guidance for pacing, not hard cuts. Pass conditions are the acceptance criteria AI-10 turns into a fresh-install playtest protocol.

### F10-001 — "I know what I control"
- **Goal (V7.1 §14.1):** what the player controls.
- **Window:** 0:00–1:30
- **Experience:** the cube is on screen, damaged/dim; a single gesture affordance (not a text box) invites a twist. The first twist produces immediate visual + haptic + audio feedback. No camera tutorial yet.
- **Pass:** `[PLAYTEST]` ≥ 90% of fresh players perform a deliberate face rotation within 90 s without verbal help. `[PLAYTEST]` ≤ 5% accidental-input complaints in exit interview.
- **Owners:** AI-04 (gesture), AI-07 (affordance), AI-08 (feedback audio).

### F10-002 — "The cube matters"
- **Goal (§14.2):** why the cube matters.
- **Window:** 1:30–3:00
- **Experience:** completing the first (small) pattern restarts the dormant local mechanism (Story Bible §Premise). Light returns to a small radius; a path segment restores.
- **Pass:** `[PLAYTEST]` median time-to-first-solve ≤ 3:00 from app start. `[BUILD]` world reaction begins ≤ 2 s after solved predicate becomes true.
- **Owners:** AI-03 (first configuration), AI-02 (solved predicate / world event), AI-05 (restoration visual).

### F10-003 — "My actions alter the world"
- **Goal (§14.3):** that actions alter the world.
- **Window:** 3:00–5:00
- **Experience:** the second solve is slightly larger and its consequence is *different in kind* (e.g., first solve = light/path; second = water or growth). The player walks across something that did not exist before. Nox emerges from the restored area and reacts to the cube.
- **Pass:** `[PLAYTEST]` ≥ 70% of players, asked "what did solving the cube do?", describe a concrete world change (not "I got points"). `[PLAYTEST]` ≥ 50% mention the creature unprompted.
- **Owners:** AI-03, AI-05, AI-06 (Nox emergence), AI-09 (Nox introduction beat, ≤ 1 line of text).

### F10-004 — "There is a mystery"
- **Goal (§14.4):** that the world has a mystery.
- **Window:** 5:00–7:00
- **Experience:** an environmental clue — a recurring symbol, a broken structure that clearly *used* to align with the cube's pattern, a sound motif — plus one concise line from Mira or Orin (≤ 25 words) that asks a question rather than answers one ("It's never answered anyone before."). No explanation of the Great Misalignment yet.
- **Pass:** `[PLAYTEST]` ≥ 60% of players state at least one question they want answered (see `IGM-005`). `[VALIDATOR]` no narrative node in minutes 0–10 exceeds 40 words; total mandatory text in minutes 0–10 ≤ 120 words.
- **Owners:** AI-09 (line + clue vocabulary), AI-05 (environmental clue), AI-08 (motif).

### F10-005 — "I have meaningful choices"
- **Goal (§14.5):** that the player has meaningful choices.
- **Window:** 7:00–9:00
- **Experience:** the first item is discovered in the restored area (Product recommends a **Tool** or **Resonator** whose effect is *information* or *access*, e.g., a Memory-Lens-type reveal — AI-09/AI-03 own the exact item). The player is presented with **two** visibly different restoration targets and can only reach one now. Choosing is done in the world (walk toward it / use the item on it), not in a menu. The unchosen target remains visible and reachable later — the choice is about *order and memory*, not permanent exclusion.
- **Pass:** `[PLAYTEST]` ≥ 70% of players recognize they made a choice ("I picked the X one first"). `[VALIDATOR]` the choice writes exactly one narrative memory flag and does not gate the critical path. `[PLAYTEST]` ≥ 60% can say what the item let them do (feeds `IGM-004`).
- **Owners:** AI-03 (branch structure), AI-09 (item identity), AI-07 (in-world pickup/equip with ≤ 1 hint), AI-02 (memory flag).

### F10-006 — "Progression is more than numbers"
- **Goal (§14.6):** that progression is more than numbers.
- **Window:** 9:00–10:00
- **Experience:** the chapter-1 beat closes with a wide reveal of the area as it now is — the player's changes are visible together. Nothing shows a level, XP bar or score. If a resource exists (`PD-004`), it is *not* introduced in minutes 0–10. A single quiet hint points toward the Journal/Map without opening it.
- **Pass:** `[PLAYTEST]` ≥ 70% of players can restate the value proposition gist ("solving the cube fixes the world / the world reacts"). `[PLAYTEST]` when asked "how do you get better/progress in this game?", ≤ 20% answer in terms of numbers/levels; ≥ 60% answer in terms of skill, tools, places or story. `[BUILD]` no numeric progression indicator is rendered in minutes 0–10.
- **Owners:** AI-05 (wide reveal), AI-07 (no-HUD-inflation), AI-01 (value-prop question in protocol), AI-10 (protocol).

### F10-007 — "It survived my phone"
- **Goal (product-added, DD-010 Android-first):** interruption and touch reliability.
- **Window:** any time during 0:00–10:00
- **Experience:** the playtest protocol includes one forced interruption (simulated call/background) between minutes 2 and 6.
- **Pass:** `[BUILD]` resume restores the exact puzzle state, world state and position; no progress lost except the in-progress twist animation. `[BUILD]` on the AI-11 low-tier device, no frame hitch > 100 ms during a twist in minutes 0–10 (this number is a *product* ceiling; AI-11 may set stricter engineering budgets; it stays a HYPOTHESIS until measured).
- **Owners:** AI-02 (state), AI-04 (input recovery), AI-11 (measurement), AI-12 (test build).

## What the first 10 minutes must NOT contain

- A menu the player is forced to open.
- A currency, XP, level or score.
- A timer.
- A second companion or a companion "bond meter".
- A settings prompt other than OS permissions.
- Any text block > 40 words.
- Any reference to online features, accounts or purchases.
- An equipment slot screen (the first item auto-occupies its slot; the slot UI is introduced after minute 10).

## Playtest protocol handoff (for AI-10)

Minimum protocol per participant:
1. Fresh install, no coaching, think-aloud allowed.
2. Observer records: time to first deliberate twist; time to first solve; accidental inputs; unprompted mentions of world change / creature / question.
3. Forced interruption once between minutes 2–6; record recovery.
4. Stop at 10:00.
5. Exit questions (verbatim wording to be frozen by AI-10 with AI-01 review):
   - "In one sentence, what is this game about?"
   - "What did solving the cube do?"
   - "Is there anything you want to find out?"
   - "Did any object you found let you do something new? What?"
   - "How do you think you get better or progress in this game?"
   - "Did anything feel confusing or fiddly?"
6. Minimum cohort: 8 participants per iteration; pass thresholds above are evaluated on the cohort.

## Traceability

| F10 | V7.1 §14 goal | Feeds IGM | Related PD |
|---|---|---|---|
| F10-001 | 1 | IGM-002, IGM-006 | PD-011 |
| F10-002 | 2 | IGM-001, IGM-002 | PD-001 |
| F10-003 | 3 | IGM-002, IGM-003 | PD-001, PD-005 |
| F10-004 | 4 | IGM-005 | PD-001 |
| F10-005 | 5 | IGM-004 | PD-002, PD-006 |
| F10-006 | 6 | IGM-002, IGM-003 | PD-003, PD-004 |
| F10-007 | (product) | IGM-006 | PD-010 |
