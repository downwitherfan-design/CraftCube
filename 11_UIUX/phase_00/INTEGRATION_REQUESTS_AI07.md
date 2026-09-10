# Integration Requests — AI-07, Phase 00

Per Ownership Firewall: AI-07 does not edit other owners' files. Each request names the exact
file/owner, required behaviour, contract impact and acceptance test.

| ID | To | File / artifact | Request | Contract impact | Acceptance test | Blocking AI-07? |
|---|---|---|---|---|---|---|
| IR-AI07-001 | AI-13 | GitHub remote branches | `07_GITHUB/GITHUB_MODEL.md` says PRs target `integration`, but the remote has no `integration` branch (only `ai-13-integration`). Please create `integration` or update the model doc to name `ai-13-integration` as the PR target. | Governance only | `git ls-remote --heads origin integration` returns a ref, **or** GITHUB_MODEL.md names the real target | Blocks PR step only |
| IR-AI07-002 | AI-13 | `07_GITHUB/scripts/validate_ownership.py`, `07_GITHUB/CODEOWNERS_EXAMPLE.txt` | Both map `Assets/UI/`, `src/UI/` → AI-05 and `tests/`, `QA/` → AI-07, contradicting `00_CONTROL/13_AI_EXECUTION_MANUAL.md` (AI-07 = UI/UX, AI-10 = QA, AI-12 = CI). Please align before Phase 01 ownership freeze; AI-07 requests ownership of `11_UIUX/` now and the UI runtime path decided in Phase 01. | Ownership map | `validate_ownership.py` `owner_for('11_UIUX/x')` returns `AI-07`; UI paths map to AI-07; tests map to AI-10 | Not for Phase 00 |
| IR-AI07-003 | AI-08 | Audio cue contract (Phase 01) | Publish the list of **gameplay-critical** audio cue IDs so AI-07 can mirror them visually when `audio_cue_redundancy = true`. Request a `critical: true/false` flag per cue. | New/extended AI-08 contract | Fixture of cue IDs with criticality exists; AI-07 mirror table references only those IDs | No (AI-07 mocks with placeholder until released) |
| IR-AI07-004 | AI-09 (terminology), AI-01 (product) | `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` | Slot name "Tool" collides with item family "Tools". Recommend renaming the **slot** (e.g., a Loom-flavoured slot noun) so UI does not need visual disambiguation hacks. | Terminology (AI-09) | Terminology Bible lists distinct slot vs family nouns | No |
| IR-AI07-005 | AI-13 | `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` row `AccessibilityPreference` | Add AI-05 and AI-06 as consumers (world-tile colour-assist glyphs; VFX intensity under `reduce_motion`/`screen_shake_intensity`). | Register consumers list | Row reads `AI-04/05/06/08/10/11` | No |
| IR-AI07-006 | AI-13 (event governance) | Event ID registry (Phase 01) | Reserve namespace `ux.*` for AI-07 UI events; first proposed ID `ux.accessibility.changed` (payload: full AccessibilityPreference block). Verified no existing `ux.*` IDs in repo. | New event ID | ID appears in registry with producer AI-07 | No |
| IR-AI07-007 | AI-02 | `SaveSchema` (Phase 01) | Decide storage of `AccessibilityPreference`: embedded under `settings` (Option A) vs device-local + mirrored (Option B, AI-07 recommendation). See `11_UIUX/contracts/AccessibilityPreference.v0.1.0-draft.md` §2. | SaveSchema field | Decision recorded; fixture round-trips through chosen storage | No |
| IR-AI07-008 | AI-01 | Product decisions | Please rule on D-UX-01…D-UX-06 in `UX_PRODUCT_LOCK_AI07.md` §12, and D-UX-07 below. | Product | Decision IDs recorded in `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md` process | D-UX-02/03 block Phase 04/05 detail, not Phase 00 |
| IR-AI07-009 | AI-11 | Performance budgets (Phase 01) | Please publish a UI-layer budget (draw time ms, steady-state allocations, texture memory for UI atlas) per device tier so UXM-11 has an owned number. | PerformanceBudget contract | Budget row for "UI layer" exists | No |
| IR-AI07-010 | AI-04 | Interaction contract (Phase 01) | Expose the cube interaction area (screen-space rect) so AI-07 can enforce UXP-1 (0% HUD occlusion) programmatically; confirm consumption of `handedness`, `camera_comfort`, `screen_shake_intensity`, `haptic_intensity`, `reduce_motion`. | Read-only presentation state (INTERACTION_CONTRACTS "State contract") | HUD occlusion test reads the rect from AI-04's DTO | No |

## Additional Product decision (not in UX lock §12)

| ID | Decision | AI-07 recommendation |
|---|---|---|
| D-UX-07 | Commit to screen-reader (TalkBack) support for menus in v1? | Evaluate feasibility in Phase 02 spike; commit only for menu/settings surfaces, not the 3D puzzle, if feasible |

## Status

All requests are OPEN as of this document's commit. None blocks AI-07 Phase 00 completion; the
PR step depends on IR-AI07-001 (target branch) — see handoff for the fallback used.
