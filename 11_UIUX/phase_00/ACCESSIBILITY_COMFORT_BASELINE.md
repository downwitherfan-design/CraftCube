# CraftCube — Accessibility & Comfort Baseline (Phase 00, AI-07)

Owner: AI-07
Version: 0.1.0-phase00
Status: READY_FOR_REVIEW
Authoritative inputs: `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §9 (comfort list) and §13
(localization), `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate B/K, `08_QA_RELEASE/WORLDCLASS_QA_EXPANSION.md`
(UX QA), `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` (UI architecture line).

Purpose: lock *which* accessibility/comfort capabilities exist, *who owns* each, and *how each
is verified*, so that Phase 01 can freeze the `AccessibilityPreference` contract and other
tracks can build against the fixture in `11_UIUX/fixtures/`.

---

## 1. Principles

1. **Comfort is default-safe.** Every preference has a default that is safe for the widest
   audience; opting into more intensity is the player's choice.
2. **Preferences are data, not code paths.** Consumers (AI-04 camera/haptics, AI-08 audio,
   AI-06 VFX intensity, AI-11 low-power) read a single versioned preference block. No consumer
   invents its own toggle for the same semantic (anti-duplication rule).
3. **Persist first, then apply.** A change is written to persistence before the UI confirms it
   (UXM-8, "accessibility toggles persist").
4. **Redundant channels.** Every gameplay-critical signal has at least two of: visual shape,
   colour, motion, audio, haptic, text.
5. **Never gate mastery on a preference.** Enabling an accessibility option must never change
   puzzle truth (DD-002 analogue for accessibility). Assist levels remain a gameplay feature
   owned by AI-03/AI-04, *presented* by AI-07.

---

## 2. Preference set (Phase 00 lock)

Each row = one stable preference key in the `AccessibilityPreference` contract draft.
Key names use `lower_snake_case`, are immutable once RELEASED, and are **not** localization keys.

| Key | Type / Range | Default | Owner of *effect* | AI-07 responsibility | V7.1 §9 item |
|---|---|---|---|---|---|
| `reduce_motion` | bool | false | AI-07 (UI), AI-04 (camera), AI-06 (VFX) | UI motion collapse; expose value | motion reduction |
| `camera_comfort` | enum `standard` / `steady` / `minimal` | `standard` | AI-04 | Settings UI + contract | camera comfort settings |
| `screen_shake_intensity` | float 0.0–1.0 step 0.25 | 0.5 | AI-04 / AI-06 | Settings UI + contract | screen shake intensity |
| `haptic_intensity` | float 0.0–1.0 step 0.25 | 0.5 | AI-04 | Settings UI + contract | haptic intensity |
| `audio_cue_redundancy` | bool | true | AI-08 (produces cues), AI-07 (visual mirror) | Visual/text mirror of critical audio cues | audio cue redundancy |
| `color_assist_indicators` | bool | false | AI-07 (UI), AI-05 (world tiles) | Shape/pattern overlays where colour carries meaning | optional visual indicators for color-dependent mechanics |
| `large_touch_targets` | bool | false | AI-07 | ≥ 56 dp targets, wider HUD bands | larger touch targets mode |
| `handedness` | enum `right` / `left` / `auto` | `auto` | AI-07 (HUD mirroring), AI-04 (gesture zones) | Mirror HUD; expose value | left/right hand-friendly |
| `safe_area_mode` | enum `system` / `extended_padding` | `system` | AI-07 | Extra inset for cutouts/curved edges | safe-area/device-cutout handling |
| `dialogue_text_speed` | enum `slow` / `normal` / `fast` / `instant` | `normal` | AI-07 (beat strip) | Text reveal speed | text speed control for dialogue |
| `text_scale` | float 1.0 / 1.15 / 1.3 / 1.5 | 1.0 (follows OS if available) | AI-07 | Type ramp scaling with reflow | (added by AI-07; localization/readability) |
| `high_contrast_ui` | bool | false | AI-07 | Contrast-boosted UI theme | (added by AI-07; Gate B readability) |
| `hold_to_confirm_destructive` | bool | true | AI-07 | Prevents accidental reset/abandon | (added by AI-07; recovery) |

Notes:
- The V7.1 §9 list is covered **1:1** (10 items) plus 3 AI-07 additions justified by Gate B
  ("touch targets reliable", "localization safe") and recovery requirements.
- Assist levels, undo depth and hint frequency are **not** here: they are gameplay settings
  (AI-03/AI-04). AI-07 presents them but does not own their semantics.
- Audio volume sliders are AI-08's domain; the Settings screen will host them via AI-08's
  contract when released.

---

## 3. Consumer matrix (who must read what)

| Consumer | Keys read | Failure mode if ignored |
|---|---|---|
| AI-04 Gameplay/Camera/Touch | `reduce_motion`, `camera_comfort`, `screen_shake_intensity`, `haptic_intensity`, `handedness` | Motion sickness, accidental input |
| AI-06 Characters/VFX | `reduce_motion`, `screen_shake_intensity`, `color_assist_indicators` | Overwhelming VFX, colour-only cues |
| AI-05 World/Lighting | `color_assist_indicators`, `high_contrast_ui` (for world-tile readability only) | Colour-blind players cannot read tile states |
| AI-08 Audio | `audio_cue_redundancy` (to emit cue events AI-07 mirrors) | Deaf/HoH players miss critical cues |
| AI-10 QA | all | Cannot verify persistence/toggle behaviour |
| AI-11 Performance | `reduce_motion`, `screen_shake_intensity` (low-power interplay) | Redundant "low power" toggles duplicating semantics |
| AI-02 Core | none (contract is UI/preference layer; AI-02 decides in Phase 01 whether the block is embedded in `SaveSchema`) | — |

All consumers are already listed as consumers of `AccessibilityPreference` in
`06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` (AI-04/08/10/11) — AI-05 and AI-06 are **proposed
additions** (IR-AI07-005).

---

## 4. Visual accessibility rules (AI-07 owned)

| ID | Rule |
|---|---|
| A11Y-V1 | Body text contrast ≥ 4.5:1; large text/icons ≥ 3:1 (UXM-5). |
| A11Y-V2 | Minimum body text 14 sp at `text_scale` 1.0; UI must reflow (not clip) at 1.5. |
| A11Y-V3 | Colour is never the only carrier of meaning in UI; when `color_assist_indicators` is on, world-tile colour states also get shape/pattern glyphs (AI-05 renders, AI-07 defines glyph set). |
| A11Y-V4 | No UI element flashes > 3 Hz. |
| A11Y-V5 | Focus/selection state is visible without colour (outline + scale). |
| A11Y-V6 | Iconography always paired with a text label at first exposure; label may collapse to icon-only after the player has used it once **and** `large_touch_targets` is off. |

## 5. Motor / touch rules

| ID | Rule |
|---|---|
| A11Y-M1 | Minimum target 48×48 dp; 56×56 dp in Large Targets mode; ≥ 8 dp spacing between adjacent targets. |
| A11Y-M2 | Primary action in the bottom 40% of the screen (thumb zone) in portrait. |
| A11Y-M3 | No time-limited UI confirmations on core surfaces. |
| A11Y-M4 | Destructive actions (reset puzzle, abandon chapter, delete save) use hold-to-confirm when `hold_to_confirm_destructive` is on. |
| A11Y-M5 | HUD mirrors horizontally under `handedness = left`. |
| A11Y-M6 | Gesture conflicts (cube turn vs UI swipe) are resolved by AI-04; AI-07 guarantees UI never places swipeable elements over the cube interaction area (UXP-1). |

## 6. Cognitive load rules

| ID | Rule |
|---|---|
| A11Y-C1 | ≤ 1 primary + ≤ 3 secondary actions above the fold (UXP-2). |
| A11Y-C2 | Onboarding prompts ≤ 12 words, ≤ 8 prompts in first 10 minutes. |
| A11Y-C3 | Item cards lead with a one-line behaviour statement; lore is one tap deeper. |
| A11Y-C4 | Dialogue supports pause/replay; text speed obeys `dialogue_text_speed`. |
| A11Y-C5 | Every screen has a single, consistent back/close affordance location. |

## 7. Hearing rules

| ID | Rule |
|---|---|
| A11Y-H1 | Every gameplay-critical audio cue has a visual mirror when `audio_cue_redundancy` is on (requires AI-08 cue event list — IR-AI07-003). |
| A11Y-H2 | Dialogue is always text-first; voice (if ever added) is additive. |

## 8. Localization-safe layout rules (V7.1 §13)

| ID | Rule |
|---|---|
| L10N-1 | No text in textures. |
| L10N-2 | Layouts survive +40% horizontal expansion via wrapping or auto-size within a defined min size; never truncate meaning-bearing text. |
| L10N-3 | RTL: layout mirroring supported by anchor rules; icons with directional meaning are mirrored explicitly. |
| L10N-4 | Font fallback chain defined per script; fonts openly licensed with metadata recorded (asset pipeline). |
| L10N-5 | Numbers/dates rendered via locale-aware formatting from the platform/engine, never string-concatenated. |
| L10N-6 | Pluralization handled via localization system rules, never by UI code branching on count == 1. |
| L10N-7 | UI code references localization **keys** owned by AI-09; AI-07 fixtures use clearly labelled placeholder key *shapes* until AI-09 releases the key contract. |

---

## 9. Verification plan (evidence expectations by phase)

| Rule set | Verification | Phase | Evidence owner |
|---|---|---|---|
| Preference persistence | kill/relaunch, toggle survives; corrupted block falls back to defaults **with a logged, user-visible notice** (no silent fallback) | 05/11 | AI-07 test + AI-10 |
| Contract shape | fixture validator `11_UIUX/tools/validate_a11y_fixtures.py` passes | 00 (now) | AI-07 |
| Contrast | automated theme contrast audit | 11 | AI-07 |
| Touch targets | static layout audit script | 04/11 | AI-07 |
| Reduced motion | UI smoke test with `reduce_motion=true` | 11 | AI-07 + AI-10 |
| Pseudo-localization | build with +40% expansion pseudo-locale | 11 | AI-07 + AI-12 |
| Safe area | device matrix cutout cases | 12 | AI-11 + AI-10 |
| Colour assist | colour-blind simulation review of tile glyphs | 06/11 | AI-07 + AI-05 |

Phase 00 evidence exists **only** for "Contract shape" (see `11_UIUX/evidence/`). All other rows
are planned, not executed.

---

## 10. Non-goals for this baseline

- Screen reader / TalkBack support for a 3D puzzle is **not** committed in Phase 00; it is
  recorded as a Product decision for later phases (D-UX-07 in the integration requests) because
  feasibility in Unity mobile UI requires evaluation.
- Colour-blind *simulation* modes (recolouring the whole world) are not planned; shape/pattern
  indicators are the chosen approach (lower content-permutation risk, V7.1 §2.4 spirit).
