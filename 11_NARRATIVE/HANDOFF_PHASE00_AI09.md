# Handoff — Phase 00 — AI-09 (Narrative / Lore / Localization)

Format: `05_PROMPTS/HANDOFF_TEMPLATE.md`. Fact labels per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`: everything below is VERIFIED unless marked PROPOSED / UNKNOWN / MISSING.

STATUS:
READY_FOR_REVIEW. All Phase 00 narrative deliverables exist and self-validate. Formal READY requires AI-01 approval of the Story Promise (OD-03) — a human/product gate AI-09 cannot pass alone.

TASK_ID:
phase_00/ai_09 (`05_PROMPTS/phase_00/ai_09.md`)

PHASE:
00 — Product/IP Lock

ACCOUNT:
AI-09 — Narrative / Lore / Localization · branch `ai-09-narrative`

TASKS_COMPLETED:
- Preflight: read master prompt, execution protocol, anti-hallucination addendum, AI-09 track, PROGRESS.md, all contract docs, Game Master Bible, Story/World/Equipment/Companion/Quest bibles, v7.1 world-class layer, decision register; inspected tree/branches; searched for existing narrative IDs (none existed).
- Refined canonical Story Bible in place (owner path): player role, story promise, 8 world rules, act purposes, chapter cadence, ≤12 flag budget, relic philosophy, localization principle, IP-safety statement.
- Defined first-10-minute narrative experience (7 beats, mapped to R1–R6, dialogue budget ≤14 lines, verification checklist).
- Chapter Beat Map (10 chapters: emotional/gameplay objective, transformation, question introduced/advanced, memorable scene, flags, items, fail-safe sentence).
- Character/Companion Arc Register (Mira, Orin, Nox full arcs; Quiet Architect absence arc; Weaver constraints) + 10-flag narrative memory set with write-once/read rules.
- Mystery/Payoff Register (7 mysteries × 5 stages × channels; 1 spine; 1 intentionally-unresolved component).
- Narrative Item/Relic Lore Ledger (12 entries, provenance, mystery links, companion eligibility, epilogue variation; 1 seed candidate merged).
- Environmental Storytelling Vocabulary (14 motifs, colour/creature/audio grammar, anti-patterns).
- Localization & Terminology Bible (`loc.*` grammar, 23 canon terms with dnt/class, translator/dialogue rules, fixture format).
- Machine-readable fixtures + stdlib validator; validator run clean.
- Open Decisions register; PROGRESS.md AI-09 section.

FILES_ADDED:
- `11_NARRATIVE/README.md`
- `11_NARRATIVE/FIRST_TEN_MINUTES.md`
- `11_NARRATIVE/CHAPTER_BEAT_MAP.md`
- `11_NARRATIVE/CHARACTER_ARC_REGISTER.md`
- `11_NARRATIVE/MYSTERY_PAYOFF_REGISTER.md`
- `11_NARRATIVE/NARRATIVE_ITEM_LEDGER.md`
- `11_NARRATIVE/ENVIRONMENTAL_STORYTELLING_VOCABULARY.md`
- `11_NARRATIVE/LOCALIZATION_TERMINOLOGY_BIBLE.md`
- `11_NARRATIVE/OPEN_DECISIONS_AI09.md`
- `11_NARRATIVE/HANDOFF_PHASE00_AI09.md` (this file)
- `11_NARRATIVE/fixtures/narrative_canon_registry.v0.1.0.json`
- `11_NARRATIVE/fixtures/loc/en.v0.1.0.json`
- `11_NARRATIVE/tools/validate_narrative_registry.py`

FILES_MODIFIED:
- `01_PREPRODUCTION/STORY_BIBLE_V7.md` (AI-09-owned canon; additive refinement, all seeded names/chapters preserved)
- `00_CONTROL/PROGRESS.md` (AI-09 section only, per file's own instruction)

FILES_DELETED:
none

CONTRACTS_CONSUMED:
none released. VERIFIED: `06_CONTRACTS/` names contract families (`CC.NARRATIVE.CHAPTER`, `CC.NARRATIVE.EVENT`, `NarrativeEvent`, `LocalizationKey`, `CharacterMemory`, `NarrativeMemoryFlag`, …) but no versioned schema exists and PROGRESS baseline reads "TBD 1.0.0". Work is therefore DRAFT input to the Phase 01 freeze, not consumption of frozen contracts.

CONTRACTS_CHANGED:
none. PROPOSED for Phase 01 (AI-09-owned families): `cc.narrative.canon_registry` 0.1.0 DRAFT, `cc.loc.strings` 0.1.0 DRAFT. Semantic flag set (10 flags) proposed as payload of `NarrativeMemoryFlag` / `CharacterMemory`.

NEW_IDS:
91 `nar.*` DRAFT IDs (3 acts, 10 chapters, 7 beats, 5 characters, 10 flags, 7 mysteries, 12 item_lore, 14 motifs, 23 terms) and 85 `loc.*` DRAFT keys — enumerated in `fixtures/narrative_canon_registry.v0.1.0.json` and `fixtures/loc/en.v0.1.0.json`. None immutable until Phase 01 FROZEN/RELEASED. Item lore entries carry `item_ref: PROPOSED`; AI-02 owns item IDs.

TESTS_AND_COMMANDS:
```
cd <repo-root>
python3 -c "import json;json.load(open('11_NARRATIVE/fixtures/narrative_canon_registry.v0.1.0.json'))"   # json ok
python3 -c "import json;json.load(open('11_NARRATIVE/fixtures/loc/en.v0.1.0.json'))"                    # json ok
python3 11_NARRATIVE/tools/validate_narrative_registry.py                                              # exit 0
```
Result of final run: `35 pass groups, 0 failures — registry 0.1.1 [APPROVED_BASELINE]: 91 nar.* IDs | en 0.1.1: 85 loc.* keys | flags: 10/60 total, per-chapter cap 6`.
First run found 3 defects (a truncated dialogue key, a bare namespace in backticks, an unregistered example flag ID); each fixed in its own checkpoint commit and re-validated.
PD-028 follow-up (integration gate, CR-0011): the v7.1 baseline validator failed on the PR head — `Chapter Beat Map` still labelled Ch.07 "The Silent Engine" with the old ID, and the markdown cross-reference scan flagged the Story Bible's own rename-history row. Fixed by renaming the Chapter 7 heading to the canonical `nar.chapter.07_quiet_engine` and by making the scan exempt an old ID only when the same document also cites its registered `superseded_ids.new` (a genuinely orphaned old ID still fails — verified). Result on the PR head is now exit 0, 35 pass groups, 0 failures.
Not run: any Unity/Flutter build, any device test, any CI (none exist in the repository — VERIFIED).

EVIDENCE:
- Validator output above (reproducible, deterministic, stdlib only).
- `git diff --name-only main..ai-09-narrative` → 14 files, all inside AI-09 ownership + PROGRESS.md section.
- `grep` for `nar.*`/`loc.*` IDs outside AI-09 files → none (no duplicate semantic systems).
- 17 checkpoint commits, each pushed before the next edit (checkpoint directive).

PERFORMANCE_NOTES:
No runtime artifacts. Design constraints with runtime impact, for AI-02/AI-11: narrative state is 10 write-once flags (≤12 budget) — trivially small save footprint; dialogue variants are enumerable (`key.<flag_value>`) so string tables stay bounded; no per-move narrative logic except the pre-existing companion reaction channel.

SECURITY_OR_PRIVACY_NOTES:
None. No credentials, no user data, no analytics. Token used for git push was never echoed or written to the repo.

KNOWN_LIMITATIONS:
- Dialogue exists only for the first ten minutes (13 lines); later chapters have purpose rows and a handful of quoted anchor lines, not scripts — by design (no content tree in Phase 00).
- English source only; no locale list decided (OD-09).
- Item lore is keyed to PROPOSED slugs until AI-02 releases `ItemDefinition` IDs.
- Mystery "COMPLETE" status means the plan is complete, not that content exists.
- Validator is track-local, not CI; AI-10/AI-12 decide whether to adopt it.
- Folder `11_NARRATIVE/` is a proposed path (OD-10).

RISKS:
- Canon not yet human-approved; any downstream content written against these IDs before OD-03 is speculative (mitigation: everything is marked DRAFT; IDs are additive).
- `integration` branch MISSING (only `ai-13-integration`); PR sequencing depends on AI-13 (OD-11).
- If AI-01 changes finale option count (OD-04), `nar.flag.final_configuration` enum and 3 term IDs change — still pre-freeze, so no migration.
- Localization runtime conventions (OD-06) unconfirmed; if rejected, fixture *format* changes, keys do not.

INTEGRATION_STEPS:
1. AI-13: review PR `ai-09-narrative` → `ai-13-integration` (no conflicts expected; all new files + 2 owned-section edits).
2. AI-01: decide OD-03 (Story Promise), OD-04 (finale set), OD-02 (cast size), OD-05 (Wayfinder merge).
3. Phase 01: AI-13 registers `cc.narrative.canon_registry` and `cc.loc.strings` in the contract registry; AI-09 bumps status DRAFT→FROZEN.
4. AI-02: map `proposed_item_slug` → `ItemDefinition` IDs; adopt the 10-flag set for `NarrativeMemoryFlag` storage.
5. AI-03/05/06/08: consume chapter/mystery/motif IDs from the registry fixture for slice planning; AI-07 proposes `loc.ui.*` grammar for AI-09 to register.
6. AI-10: adopt or replace `tools/validate_narrative_registry.py`; add flag write-once and en-superset locale tests.

ROLLBACK_STEPS:
- Full: `git revert` the 17 AI-09 commits (range `main..ai-09-narrative`), or delete `11_NARRATIVE/` and `git checkout main -- 01_PREPRODUCTION/STORY_BIBLE_V7.md 00_CONTROL/PROGRESS.md`. No other file is touched; no runtime, save or CI dependency exists yet, so rollback has zero downstream migration.
- Partial: each deliverable is one commit; any single file can be reverted independently (validator will report resulting broken cross-references).

NEXT_SAFE_ACTION:
Open PR to `ai-13-integration`; wait for OD-03/OD-04 decisions; begin Phase 01 prompt (`05_PROMPTS/phase_01/ai_09.md`) by turning the two DRAFT fixtures into versioned contract entries.

OWNERSHIP_AUDIT:
Files touched: 12 new under `11_NARRATIVE/` (proposed AI-09 path), `01_PREPRODUCTION/STORY_BIBLE_V7.md` (AI-09 canon per track + START_HERE), `00_CONTROL/PROGRESS.md` (AI-09 section only, as the file instructs). No runtime, UI, asset, audio or CI file changed. No other track's file edited. No contract file in `06_CONTRACTS/` edited (proposals recorded here and in OPEN_DECISIONS for AI-13 governance). No `integration` branch created.
