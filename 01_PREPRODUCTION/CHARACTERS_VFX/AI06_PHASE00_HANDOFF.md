# AI-06 — Phase 00 Handoff (per `05_PROMPTS/HANDOFF_TEMPLATE.md`)

STATUS:
READY_FOR_REVIEW. All Phase 00 AI-06 artifacts exist, validate, and are pushed to `ai-06-creatures`. LOCK status of the direction document depends on two external events recorded below (AI-01 product lock approval; AI-13 ownership-split decisions). Not claiming COMPLETE for items that depend on other tracks.

TASK_ID:
phase_00/ai_06 — "Characters / Creatures / Animation / VFX contribution to Product/IP Lock"

PHASE:
00 — Product/IP Lock

ACCOUNT:
AI-06 — Characters / Creatures / Animation / VFX

TASKS_COMPLETED:
1. Preflight: read master prompt, execution protocol, anti-hallucination addendum, AI-06 track, PROGRESS.md, contract registers (v7 + v7.1), Game Master Bible, Companion Bond Bible, Companion & Character System, Story Bible (cast), World Biome Bible, V7.1 upgrade, asset pipeline, technical blueprint, QA gates, GitHub model, phase matrix, and the unmerged AI-01 (`origin/ai-01-product`) and AI-02 (`origin/ai-02-core`) Phase 00 outputs.
2. Searched all 14 remote branches for existing creature/reaction/VFX systems or IDs before creating anything (only doc examples `creature.pollinator.bee`, `companion.ability.used`, `vfx_bloom_meadow_a_v01` exist; no equivalent system).
3. Wrote the Characters/Creatures/VFX Direction Lock v1.0.0: domain purpose, IP-safe visual grammar, terminology policy, v1 roster, Nox presentation role, reaction principles, VFX hard rules VFX-R1..R8, runtime hypotheses, measurable boundaries CVX-M01..M12, asset metadata spec, domain cut list CVX-CUT-001..012, boundary proposals B6-01..B6-04, UNKNOWN/CONFLICT/DECISION register.
4. Wrote the Companion Reaction Model with a DRAFT `CompanionReaction` contract outline (trigger/definition shapes, closed sets, arbitration, validation rules V-01..V-11).
5. Wrote a machine-readable draft register (closed sets, roster, rules, boundaries, cut list, open items, IP forbidden terms).
6. Wrote a clearly labeled non-production fixture (one definition per PD-005 trigger class + trigger examples incl. a negative case).
7. Wrote a stdlib validator and ran it; fixed two findings it surfaced in my own lock document (IP-term prose); verified the scan still detects an injected forbidden term.
8. Updated the AI-06 section of `00_CONTROL/PROGRESS.md` (only that section).

FILES_ADDED:
- `01_PREPRODUCTION/CHARACTERS_VFX/AI06_CHARACTER_CREATURE_VFX_LOCK_V1.md`
- `01_PREPRODUCTION/CHARACTERS_VFX/AI06_COMPANION_REACTION_MODEL_DRAFT.md`
- `01_PREPRODUCTION/CHARACTERS_VFX/AI06_CHARACTERS_VFX_REGISTER_PHASE00.json`
- `01_PREPRODUCTION/CHARACTERS_VFX/fixtures/AI06_companion_reaction_fixture_DRAFT.json`
- `01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py`
- `01_PREPRODUCTION/CHARACTERS_VFX/AI06_PHASE00_HANDOFF.md` (this file)

FILES_MODIFIED:
- `00_CONTROL/PROGRESS.md` — AI-06 section only (the file's own rule: "Each AI must update only its own section").

FILES_DELETED:
- none

CONTRACTS_CONSUMED:
- All consumed families are `TBD 1.0.0` per `00_CONTROL/PROGRESS.md`; nothing is FROZEN/RELEASED yet, so AI-06 consumed **no released contract** and worked against verified design documents only. Families AI-06 will consume (listed in the register): PuzzleState, WorldState, WorldStateEvent, EquipmentEffect (AI-02); NarrativeEvent, CharacterMemory, NarrativeMemoryFlag, LocalizationKey (AI-09); DiscoveryDefinition (AI-03); AccessibilityPreference (AI-07); PerformanceBudget (AI-11).
- Product inputs consumed from the **unmerged** `origin/ai-01-product` branch (status READY_FOR_REVIEW): PD-005 (companion role + validator whitelist), PD-011 (accessibility), CUT-004/005/011/014/031, IGM-005c. If AI-01's lock changes before merge, §2 of the lock doc names each dependency so re-validation is mechanical.

CONTRACTS_CHANGED:
- none. `CompanionReaction` is proposed as a DRAFT outline only (version `0.1.0-draft`, explicitly "not consumable"). No registry entry, version bump or frozen schema was created.

NEW_IDS:
- Document-ID families (AI-06 namespace, immutable once released; registration requested from AI-13 as D6-04): `CC.CHARVFX.LOCK`, `CC.CHARVFX.REACTION_MODEL`, `VFX-R1..R8`, `CVX-M01..M12`, `CVX-CUT-001..012`, `B6-01..B6-04`, `U6-01..U6-09`, `C6-01..C6-03`, `D6-01..D6-05`.
- Draft concept keys (not runtime IDs): `concept.charvfx.*` in the register.
- Fixture IDs: all prefixed `draft.` (e.g. `draft.reaction.nox.biome_health.tier_up.clear`) — **not released**, cannot collide with future canonical IDs.
- No runtime event IDs, asset IDs, localization keys or save fields were created.

TESTS_AND_COMMANDS:
```
cd /home/user/flutter_app
python3 01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py
# -> "AI-06 Phase 00 validator: 187 passed, 0 failed", exit 0
python3 01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py --verbose   # prints every PASS line
python3 -c "import json;json.load(open('01_PREPRODUCTION/CHARACTERS_VFX/AI06_CHARACTERS_VFX_REGISTER_PHASE00.json'))"
python3 -c "import json;json.load(open('01_PREPRODUCTION/CHARACTERS_VFX/fixtures/AI06_companion_reaction_fixture_DRAFT.json'))"
```
Validator history (honest): first run 186 passed / 1 failed (CVX-M12 found `minecraft`, `mob` in my own prose) → prose reworded → 186/1 (`mob` remained in the terminology table's Avoid column) → validator taught to treat whole "Avoid"-column tables as policy while still scanning prose → 187/0. Negative self-test: injecting "creeper" into a copy of the lock text was detected (`['creeper']`).

EVIDENCE:
- Branch: `ai-06-creatures`, commits `116cef6`, `e6dbe33`, `c0e6ef6`, `0fd4b6c`, `fa41ec4`, `8f98c59`, `3a2ce89` (+ this handoff and PROGRESS commits), all pushed to `origin/ai-06-creatures`.
- Validator output above; the fixture's negative trigger example (`gift_received`) is asserted to be outside the whitelist (check `FX-NEGATIVE`).
- Not done / not claimed: no Unity project exists in the repo, so no build, no device run, no performance measurement, no visual asset review. Every number in lock §9 is labeled HYPOTHESIS; no performance figure is presented as measured.

PERFORMANCE_NOTES:
- No runtime code. Performance impact of this phase: none.
- Recorded for later phases: particle system choice (built-in vs VFX Graph) must follow AI-11's device matrix because VFX Graph requires compute-shader support not assumable on low tier; Nox rig/LOD/particle caps are hypotheses awaiting `PerformanceBudget` (U6-01).

SECURITY_OR_PRIVACY_NOTES:
- No credentials, signing material, personal data or telemetry involved. The validator is stdlib-only, reads repo files, writes nothing.

KNOWN_LIMITATIONS:
- Direction lock cannot become LOCKED until AI-01's product lock is human-approved and AI-13 records D-04/D6-03.
- `CompanionReaction` shape is a draft; field names may change at Phase 01 freeze.
- Fixture selectors (`match`) are illustrative; real `puzzle_state`/mastery descriptors are AI-02/AI-03's (U6-07, U6-08).
- Visual grammar ("Loom-formed") is a presentation proposal, not narrative canon; AI-09/AI-05 must confirm coherence.
- Ambient creatures are blocked on a Product decision (D6-02); no asset planning beyond Nox.
- The IP-term scan is a word-list heuristic, not a legal review; human art review remains required (CVX-M12 second clause).

RISKS:
- If AI-13 rejects split B6-01, the trigger-side of the fixture must move to AI-02's shape (low cost: the definition side is unaffected).
- If AI-01's PD-005 whitelist changes, `closedSets.triggerClass` and the fixture change together (validator will fail loudly, by design).
- Terminology conflict C6-01 (Quiet/Silent Engine) will affect `applicability` biome references if unresolved by Phase 01.
- CODEOWNERS example maps `Assets/VFX/` to AI-04 (C6-02); if adopted literally, AI-06 would be locked out of its own asset path.

INTEGRATION_STEPS:
1. AI-13: confirm PR target — `integration` branch does not exist on the remote (U6-02); only `ai-13-integration` exists. AI-06 did not create governance branches.
2. AI-13: record decisions D6-03 (B6-01..B6-04) and D6-04 (ID families); merge order independent of other Phase 00 PRs (documentation-only, no shared files besides the AI-06 section of `PROGRESS.md`).
3. AI-01: acknowledge CVX-M01 = IGM-005c shared target; decide D6-01, D6-02.
4. AI-09: resolve C6-01; provide flag/key formats (U6-06); review §4.2 grammar and §4.3 vocabulary for canon coherence.
5. AI-02 / AI-03 / AI-04: react to trigger payload draft (U6-07/08/09) before Phase 01 freeze.
6. AI-10: adopt `tools/ai06_validate_phase00.py` rules V-01..V-11 as the seed for production `CompanionReaction` validators.
7. AI-12/AI-13: fix C6-02 in the CODEOWNERS/validator example.

ROLLBACK_STEPS:
```
git rm -r 01_PREPRODUCTION/CHARACTERS_VFX
# then revert the AI-06 section of 00_CONTROL/PROGRESS.md to the template text
```
No other file, contract, ID or track depends on these artifacts; deletion is non-destructive.

NEXT_SAFE_ACTION:
Open the PR from `ai-06-creatures` to the integration branch AI-13 names; then in Phase 01 freeze `CompanionReaction` 1.0.0 (trigger + definition schemas, closed sets, validation rules) against the recorded decisions, and replace the `draft.` fixture with the frozen-contract fixture.

OWNERSHIP_AUDIT:
- All added files live under `01_PREPRODUCTION/CHARACTERS_VFX/` (new AI-06-owned folder; no other track has files there).
- Only modification outside that folder: AI-06 section of `00_CONTROL/PROGRESS.md`, explicitly permitted by that file.
- No puzzle rules, UI layout, audio content, narrative canon, save schema, contract registry, CI, or release files were touched. No other account's files were edited; cross-track needs are filed as B6/U6/C6/D6 items instead.
- `git diff --stat main..ai-06-creatures` should show only the paths listed above.
