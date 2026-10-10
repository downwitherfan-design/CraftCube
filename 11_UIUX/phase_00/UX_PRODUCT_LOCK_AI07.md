# CraftCube — Phase 00 UX Product Lock (AI-07)

Owner: AI-07 (UI/UX / Motion / Accessibility)
Document version: 0.1.0-phase00
Status: READY_FOR_REVIEW (Product/AI-01 confirmation required for items marked `DECISION-NEEDED`)

Source hierarchy applied (per `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md`):
`00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` > `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` >
`00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §9/§13/§14 > `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` (UI architecture) >
`08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate B/K > this document.

Every statement below is tagged **VERIFIED** (traceable to a repository document), **INFERRED**
(derived from verified intent), or **DECISION-NEEDED** (requires AI-01/human product authority).

---

## 1. UX mission statement (what AI-07 locks in Phase 00)

**VERIFIED intent:** The game must be "immediately understandable", "responsive on touch
devices", "stable under interruption" and must not become "a menu-heavy collection game"
(Game Master Bible §12, §13). The first 10 minutes must communicate six things without a long
lore introduction (V7.1 §14). The UI architecture is "safe-area aware, resolution independent,
state-driven, localization-ready, reduced-motion aware" (Technical Blueprint, UI architecture).

**INFERRED UX mission:**
> The interface exists to make the cube, the world's reaction and the player's next meaningful
> choice legible in one glance on a phone held in one hand — and then get out of the way.

UX is a *servant* of the protected hierarchy (Bible §3). Any UI surface that competes with the
cube for attention during play violates this lock.

---

## 2. Platform & device assumptions (UX-relevant)

| # | Assumption | Tag | Source |
|---|---|---|---|
| P1 | Primary platform is Android phones; touch is the primary input. | VERIFIED | DD-010; Technical Blueprint (Engine) |
| P2 | Engine is Unity 6 + URP. UI stack (uGUI vs UI Toolkit) is **not** decided in repo. | VERIFIED (gap) | Technical Blueprint lists no UI toolkit → `DECISION-NEEDED D-UX-01` |
| P3 | Portrait is the default play orientation; landscape is not assumed. | INFERRED | Mobile-first + one-hand ergonomics; no repo statement on orientation → `DECISION-NEEDED D-UX-02` |
| P4 | Device tiers low / mid / high exist and UI must remain readable on low tier. | VERIFIED | AI-11 track; Gate E "low-end fallback works" |
| P5 | Device cutouts / safe areas / gesture-navigation bars must be handled. | VERIFIED | V7.1 §9; WORLDCLASS_QA_EXPANSION "safe-area/device-cutout cases verified" |
| P6 | Core play is fully offline; UI must never block on network. | VERIFIED | DD-015; Bible §12 "an online-required experience" is a non-goal |
| P7 | Reference design canvas for layout specs: 1080×2400 logical portrait; must scale 16:9 → 21:9 without clipping. | INFERRED | Common Android range; **not** a repo fact — recorded as AI-07 working assumption to be validated in Phase 04/12 |

---

## 3. Target audience → UX consequences

**VERIFIED intent:** emotional targets are curiosity, tactile satisfaction, "I figured it out",
visible consequence, discovery, attachment, anticipation, mastery (Bible §5). Tone is "wonder +
mystery + warmth + quiet danger" (Story Bible, Tone). No dark-pattern retention (Bible §11).

**INFERRED audience profile for UX purposes** (AI-01 owns the canonical audience definition —
this is only the UX reading of it):

| Audience trait | UX consequence |
|---|---|
| Plays in short mobile sessions, often one-handed | Primary actions reachable by thumb; no critical control in top corners |
| Mixed puzzle experience (twisty-puzzle novices to experts) | Assist levels are opt-in and never shame the player; expert UI is discoverable, not default |
| Wants a calm, tactile experience | Motion is physical and short; no flashing/strobing; no urgency timers on core UI |
| Cares about world and characters, not spreadsheets | Item/equipment UI shows *what changes*, never a stat table first |
| Global audience | Localization-safe layout from day one (V7.1 §13) |

---

## 4. UX pillars (locked)

| ID | Pillar | Testable meaning |
|---|---|---|
| UXP-1 | **Cube first** | During puzzle interaction, HUD occlusion of the cube's bounding area is 0%. Persistent HUD occupies only safe edge bands. |
| UXP-2 | **One glance, one decision** | Any screen presents at most one primary action and ≤ 3 secondary actions above the fold. |
| UXP-3 | **Consequence is visible before it is explained** | World reaction plays before any text/tutorial explanation of it (supports DD-003, V7.1 §14). |
| UXP-4 | **Small loadout, big meaning** | Equipment UI is built for ≤ 4 active slots (Equipment Bible "Suggested structure"); every equipment card leads with behavior, not numbers. |
| UXP-5 | **Comfort is not a hidden menu** | Reduced motion, text size, haptics, screen-shake and camera comfort are reachable within 2 taps from the pause surface and offered during onboarding. |
| UXP-6 | **Nothing is lost** | Interruption (call, background, rotation, low battery) never loses more than the current gesture. UI state is restorable from `SaveSchema` + `AccessibilityPreference` alone. |
| UXP-7 | **Localization-safe by construction** | No text baked into textures; every label has ≥ 40% horizontal expansion headroom or wraps; RTL mirroring is supported by layout rules. |

---

## 5. Screen inventory & cut list (Phase 00 scope boundary)

**Principle (VERIFIED):** "fewer but memorable" (Content Rules), "menu-heavy collection game" is a
non-goal (Bible §12), complexity budget tracks runtime systems (V7.1 §16).

### 5.1 IN scope for Vertical Slice Gold (Phase 06)

| Surface ID | Surface | Why it pays rent (V7.1 §2.2) |
|---|---|---|
| SCR-PLAY-HUD | Play HUD (minimal: pause, assist toggle, companion presence, move/undo) | Puzzle mastery |
| SCR-ONBOARD | Onboarding overlay (diegetic prompts, no separate tutorial screens) | First-session quality target |
| SCR-PAUSE | Pause / comfort quick-panel | Comfort, recovery |
| SCR-LOADOUT | Loadout (≤ 4 slots) + item detail card | Meaningful equipment choice |
| SCR-DISCOVERY | Discovery ledger (single list, chapter-grouped) | Discovery |
| SCR-STORY-BEAT | Story beat presentation (concise dialogue strip; skip/replay; text speed) | Story/emotion |
| SCR-SETTINGS | Settings incl. accessibility & comfort | Comfort, accessibility |
| SCR-REWARD | Reward choice moment (choose 1 of N; N ≤ 3) | Meaningful progression |

### 5.2 DEFERRED (not in Vertical Slice; require Product evidence of value)

| Surface | Reason deferred |
|---|---|
| Crafting UI | "Crafting is optional and should remain lightweight" (Equipment Bible) — no validated need yet |
| Shop / currency wallet | Currency layer "is not assumed" (V7.1 §6) |
| Leaderboard UI | Optional online, Phase 13 |
| Achievement gallery | Phase 09 meta; must not become collection-menu bloat |
| Codex / lore encyclopedia | Risk of lore dump (DD-003). Item lore lives *in* the item card, not a separate wing |

### 5.3 CUT (UX explicitly rejects for CraftCube identity)

| Rejected pattern | Reason |
|---|---|
| Stat comparison tables / DPS-style numbers on item cards | Bible §9, Equipment Bible "My number is bigger" anti-target |
| Rarity colour inflation (5+ rarity colours) | Equipment Bible "narrative/functional rarity, not arbitrary color inflation" |
| Daily-login streak banners, countdown timers on core UI | Bible §11 "No dark-pattern dependency" |
| Block-grid inventory with drag-to-hotbar | Reads as block-building clone (Bible §1) |
| Generic RPG character sheet | Non-goal "generic RPG" |
| Full-screen modal tutorials with "Next" pagination | Conflicts with V7.1 §14 "do not require a long lore introduction" |

---

## 6. UX terminology (AI-07 consumption of AI-09 terminology)

**Ownership:** AI-09 owns terminology and localization keys. AI-07 owns *how* terms appear in UI.
The terms below are **VERIFIED** in repository design documents and are the only vocabulary
AI-07 will use in UI mock-ups until AI-09 publishes the Localization Terminology Bible.

| Player-facing term | Source | UI usage rule |
|---|---|---|
| Weaver | Story Bible (player character) | Never used as a label for the player in HUD; only in dialogue |
| Axis Loom / the Loom | Bible §6 | Proper noun; never abbreviated in UI |
| Great Misalignment | Bible §6 | Dialogue only |
| Hearthwild, Glassroot, Sunken Grid, Ember Hollow, Silent Engine | Story Bible chapters | Biome/chapter names in discovery ledger headers |
| Nox | Story Bible | Companion name |
| Relic / Tool / Resonator / Companion Gear / Field Module / Memory Collectible | Equipment Bible item families | Family label on item card (icon + word) |
| Utility / Named / Relic / Mastery | Equipment Bible rarity tiers | Rendered as a single subtle marker, not a colour rainbow |
| Core Resonator / Tool / Companion Module / Field Module | Equipment Bible suggested slots | Slot labels — *suggested*, see D-UX-03 |
| Precision / Versatility / Efficiency / Discovery | Equipment Bible upgrade branches | Upgrade branch labels |
| Bloom / Collapse / Vitality | Technical Blueprint domain modules, event IDs | HUD state names — meaning owned by AI-02/AI-03 |

**UI-internal terms (AI-07 owned, not player-facing):** "Loadout" (= active equipment set),
"Ledger" (= discovery list), "Beat strip" (= concise dialogue presentation), "Comfort panel"
(= quick accessibility surface). These are engineering names, not localization strings.

**CONFLICT noted:** `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` lists slot "Tool" and
item family "Tools" with the same word. UI must disambiguate visually (slot icon vs family
icon). Reported to AI-09/AI-01 in `INTEGRATION_REQUESTS_AI07.md` (IR-AI07-004).

---

## 7. IP-safe presentation direction

**VERIFIED constraint:** must not copy "Minecraft's art, creatures, terminology, UI or
progression patterns" (Bible §1); "no misleading IP claims" (Gate G); "Original/IP-safe
presentation; do not introduce unlicensed proprietary branding/assets" (Phase 00 prompt).

AI-07 IP-safe UI rules (locked):

1. **No hotbar.** No 9-slot bottom bar; loadout is a ≤ 4-slot radial/arc or card row.
2. **No pixel-block iconography.** Icons are geometric "woven-line / loom" motifs (INFERRED from
   Axis Loom fantasy); AI-05/AI-06 own final art, AI-07 owns icon *grammar* and legibility rules.
3. **No crafting-grid metaphor** in any UI.
4. **No copied UI sounds/fonts/colour palettes** from other titles; fonts must be openly licensed
   with license metadata recorded (Master Roadmap DoD: "all assets have source/license metadata").
5. **No Rubik's® trademark language** in UI text ("Rubik's", "Rubik's Cube"). UI refers only to
   "the cube" / "the Loom device". *(Trademark status of the word "Rubik's" is a legal matter —
   flagged as `DECISION-NEEDED D-UX-05` for human/legal review; AI-07 simply avoids the term.)*
6. **Generic Rubik-style visual language** (stickered 3×3 cube) is a mechanic, not owned UI —
   but the UI must not present the product as a "Rubik simulator" (Bible §12 non-goal).

---

## 8. Success criteria & measurable UX boundaries

These are AI-07's proposed acceptance thresholds. They are **INFERRED** from Gate B/K and V7.1 §14
and become binding only when AI-01 accepts them (`DECISION-NEEDED D-UX-06`).

| ID | Metric | Threshold | Measured how (Phase) |
|---|---|---|---|
| UXM-1 | Fresh-install first-move time | ≤ 60 s from first frame to first legal cube move, without reading any text | Fresh-install observation (Phase 06 playtest) |
| UXM-2 | Onboarding completion | ≥ 85% of testers complete the first restoration without external help | Playtest (Phase 06/15) |
| UXM-3 | Six-message check (V7.1 §14) | ≥ 5 of 6 messages recalled unprompted after 10 min | Post-session interview (Phase 06) |
| UXM-4 | Minimum touch target | ≥ 48×48 dp for all interactive UI; ≥ 56×56 dp in Large Targets mode | Static layout audit (Phase 04+) |
| UXM-5 | Text contrast | ≥ 4.5:1 for body text, ≥ 3:1 for large text/icons, on every biome background | Automated contrast check (Phase 11) |
| UXM-6 | Localization headroom | Every label survives +40% string length and pseudo-localization without clipping/overlap | Pseudo-loc build (Phase 11) |
| UXM-7 | Reduced-motion respected | 100% of non-essential UI motion disabled; essential motion ≤ 150 ms | UI smoke test (Phase 11) |
| UXM-8 | Interruption safety | Backgrounding mid-gesture loses ≤ 1 move; comfort settings persist across kill/relaunch | Save/recovery test (Phase 11) |
| UXM-9 | Menu depth | Any in-scope surface (§5.1) reachable in ≤ 2 taps from play | Static navigation audit |
| UXM-10 | Equipment comprehension | ≥ 80% of testers can state what an equipped item *does* after reading its card once | Playtest (Phase 06) |
| UXM-11 | UI performance | UI layer allocates 0 bytes/frame in steady state; UI draw ≤ 1 ms on mid-tier (budget owned by AI-11) | Profiler (Phase 12) |

Numbers marked as thresholds are **targets to validate**, not measured results. No measurement
has been performed in Phase 00.

---

## 9. Accessibility & comfort baseline (Phase 00 lock)

Full baseline: `11_UIUX/phase_00/ACCESSIBILITY_COMFORT_BASELINE.md`.
Contract draft: `11_UIUX/contracts/AccessibilityPreference.v0.1.0-draft.md` (owner AI-07).

The V7.1 §9 list is adopted **in full** as the minimum comfort set. No item is deferred.

---

## 10. Motion principles (locked)

| ID | Principle |
|---|---|
| MOT-1 | Motion communicates physical causality (cube turn → world response) and never decorates. |
| MOT-2 | Default UI transition durations: micro 120 ms, standard 200 ms, emphasis 320 ms. Reduced-motion collapses all to ≤ 150 ms cross-fade or instant. |
| MOT-3 | No flashing > 3 Hz anywhere in UI (photosensitivity). |
| MOT-4 | Screen shake and camera motion are separate intensity controls (V7.1 §9) and both honour reduced motion. |
| MOT-5 | Cube-turn animation timing is owned by AI-04 (runtime feel); AI-07 owns only UI-layer motion and the comfort preferences that AI-04 consumes. |

---

## 11. Complexity budget (UX share)

Per V7.1 §16, AI-07 tracks:

| Item | Phase 00 lock |
|---|---|
| Equipment slots visible in UI | ≤ 4 (D-UX-03) |
| Rarity markers | ≤ 4 (Utility/Named/Relic/Mastery) |
| Upgrade branches shown per item | ≤ 4, typically 2 offered at a time |
| Reward choice options | ≤ 3 |
| Persistent HUD elements during play | ≤ 4 |
| Top-level settings sections | ≤ 5 (Play, Comfort & Accessibility, Audio, Language, About) |
| Onboarding text prompts in first 10 min | ≤ 8, each ≤ 12 words in source language |

---

## 12. Decisions needed from Product / Human authority

| ID | Decision | AI-07 recommendation | Blocking? |
|---|---|---|---|
| D-UX-01 | Unity UI stack (uGUI vs UI Toolkit) | UI Toolkit for data-driven, localization-safe layout; **but** must be validated against URP/mobile performance by AI-11 in Phase 02 | Blocks Phase 02 UI bootstrap, not Phase 00 |
| D-UX-02 | Default orientation | Portrait-locked for Vertical Slice; landscape evaluated post-slice | Blocks Phase 04 layout |
| D-UX-03 | Exact equipment slot count | 3 for Vertical Slice (Core Resonator, Tool, Companion Module), 4th (Field Module) unlocked later | Blocks SCR-LOADOUT detail design (Phase 05) |
| D-UX-04 | Whether assist levels are shown as a persistent HUD toggle or a pause-panel setting | Persistent, single-tap, non-judgemental icon | Phase 05 |
| D-UX-05 | Legal review of trademark-adjacent terms in UI copy | Avoid "Rubik's" entirely; human legal confirmation | Store gate (Phase 14) |
| D-UX-06 | Acceptance of UXM-1..UXM-11 thresholds | Accept as Vertical Slice gate inputs | Phase 06 gate |

None of these blocks other accounts from proceeding in Phase 00/01 with mocks.

---

## 13. Dependencies, unknowns, conflicts (explicit)

| Tag | Item |
|---|---|
| MISSING | `integration` branch does not exist on remote (only `ai-13-integration`). PR target per `07_GITHUB/GITHUB_MODEL.md` is `integration`. Reported IR-AI07-001. |
| MISSING | No localization key contract published by AI-09 yet → AI-07 uses placeholder key *shape* only in fixtures, clearly labeled. |
| MISSING | No `SaveSchema` version published by AI-02 → `AccessibilityPreference` is designed as an independently versioned block so it can be embedded or stored separately (decision deferred to Phase 01). |
| CONFLICT | `07_GITHUB/scripts/validate_ownership.py` and `CODEOWNERS_EXAMPLE.txt` map `Assets/UI/` and `src/UI/` to **AI-05** and `tests/` to **AI-07**, contradicting `13_AI_EXECUTION_MANUAL.md` (AI-07 = UI, AI-10 = QA). Both files self-describe as examples to adapt. Reported IR-AI07-002 to AI-13. |
| CONFLICT | Branch names in `GITHUB_MODEL.md` use `ai-07/uiux`; actual remote uses `ai-07-uiux`. Actual remote is authoritative (source hierarchy rule 1). |
| UNKNOWN | Unity UI stack, orientation, slot count (see §12). |
| UNKNOWN | Whether AI-08 exposes an audio-cue redundancy hook (needed for "audio cue redundancy" comfort setting). Reported IR-AI07-003. |

---

## 14. What this lock does NOT do

- It does not define visual art style (AI-05/AI-06).
- It does not define story text, dialogue or localization keys (AI-09).
- It does not implement any runtime UI (Phase 02+).
- It does not assert any measured result.
