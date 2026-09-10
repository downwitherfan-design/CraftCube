# AI-05 Handoff — Phase 00 (Product/IP Lock)

Format: `05_PROMPTS/HANDOFF_TEMPLATE.md`. Evidence labels per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`.

STATUS:
READY_FOR_REVIEW — all AI-05 Phase-00 artifacts exist, validated and pushed. NOT "COMPLETE": phase closure requires AI-01 ratification of boundaries/cut list (DEP-08), AI-13 ratification of the owned path (DEP-07) and an `integration` branch to PR into (DEP-06).

TASK_ID:
PHASE00-AI05-ENV-DIRECTION-LOCK

PHASE:
00 — Product/IP Lock

ACCOUNT:
AI-05 — Environment Art / World / Materials / Lighting

TASKS_COMPLETED:
1. Preflight read of master prompt, execution protocol, anti-hallucination addendum, AI-05 track, PROGRESS.md, all contract docs, Game Master Bible, World Biome Bible, Story Bible, Decision Register, V7.1 upgrade layer, technical blueprint, asset pipeline, phase-00 prompts of neighbouring accounts (AI-01/06/09/11).
2. Repository inspection: single commit `584141c` on all branches; documentation-only pack; no Unity project, `src/`, `Assets/`, tests or fixtures exist. Searched for existing biome IDs / `env.` IDs / fixtures → ABSENT.
3. Environment Art Direction Lock v1.0.0: vision, 6 pillars, IP-safe direction + explicit rejections, internal terminology (non-player-facing), platform assumptions with VERIFIED/ASSUMED/UNKNOWN labels, lighting + material direction, 6 measurable readability rules, accessibility/localization/performance/recovery implications, scope boundaries, cut list, dependency register.
4. Biome Presentation Identity Matrix v1.0.0: DRAFT `env.*` ID scheme, cross-biome Tier 0→4 visual grammar (shape + light + colour per step), per-biome gameplay-identity → visual-identity mapping for all 6 biomes with a state beacon and 5 tier looks each, ≤ 3 memory marks per biome, ≤ 6 master shader semantics, world-memory presentation contract, canon coherence self-audit.
5. Labelled MOCK fixture (`fixture_kind: MOCK`, `_mock_notice`) so AI-02/03/04/06/08/10 can consume presentation state now; includes sample persisted-state inputs including a missing-state case.
6. Deterministic stdlib-only validator enforcing 9 checks (ID uniqueness, ID scheme, tier coverage, R6 non-hue cue, memory-mark limit, shader declaration/limit, mock detectability). Positive run recorded; negative runs against 7 mutated copies each produced exit 1 with the expected check ID.

FILES_ADDED:
- `09_ART_AUDIO/environment/ENVIRONMENT_ART_DIRECTION_LOCK_V1.md`
- `09_ART_AUDIO/environment/BIOME_PRESENTATION_IDENTITY_MATRIX_V1.md`
- `09_ART_AUDIO/environment/fixtures/MOCK_biome_presentation_state_v0.json`
- `09_ART_AUDIO/environment/tools/validate_environment_fixtures.py`
- `09_ART_AUDIO/environment/handoffs/AI-05_PHASE00_HANDOFF.md` (this file)

FILES_MODIFIED:
- `00_CONTROL/PROGRESS.md` — AI-05 section only, in the format required by that file (committed after this handoff).

FILES_DELETED:
- none

CONTRACTS_CONSUMED:
- World Biome Bible tier model (Tier 0–4) and biome list — design intent, not a released contract (no contract is FROZEN/RELEASED in repo; `PROGRESS.md` baseline is "TBD 1.0.0" for all families).
- `CC.BIOME.STATE`, `CC.WORLD.STATE` (names only, from `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md`) — schema MISSING; mocked.
- `09_ART_AUDIO/ASSET_PIPELINE.md` naming/metadata/no-placeholder-leakage rules.

CONTRACTS_CHANGED:
- none. No shared contract file was edited.

NEW_IDS:
All DRAFT presentation IDs (mutable until Phase-1 freeze, then immutable). Documents: `AI05-DOC-ENV-DIRECTION-LOCK`, `AI05-DOC-BIOME-PRESENTATION-MATRIX`. Fixture: `AI05-FIXTURE-BIOME-PRESENTATION-MOCK`. Presentation IDs (66 total, all unique per validator V2):
- Biomes: `env.biome.hearthwild`, `env.biome.glassroot`, `env.biome.sunken_grid`, `env.biome.ember_hollow`, `env.biome.verdant_archive`, `env.biome.quiet_engine`
- Per biome: `.beacon`, `.tier.0` … `.tier.4`, three `.memory.<slug>` marks (listed in the Matrix §3 and the fixture).
- Shaders: `env.shader.opaque_stylised`, `env.shader.foliage_cut`, `env.shader.emissive_lattice`, `env.shader.water_glass`, `env.shader.terrain_blend`, `env.shader.decal`
- Reserved: `env.motif.lattice`
Pre-creation search: `grep -rn "env\.\|hearthwild\|glassroot" --include=*.md --include=*.json` at `584141c` → only prose mentions in bibles; no IDs. ABSENT → CREATE.

TESTS_AND_COMMANDS:
```
cd <repo>
python3 -c "import json;json.load(open('09_ART_AUDIO/environment/fixtures/MOCK_biome_presentation_state_v0.json'))"
python3 09_ART_AUDIO/environment/tools/validate_environment_fixtures.py
# exit 0; output: RESULT OK (9 passed, 0 failed)
```
Negative test (ad-hoc, /tmp, not committed): 7 mutated fixtures (duplicate ID, hue-only cue, missing tier, 4 memory marks, undeclared shader, off-scheme ID, MOCK without notice) → each exit 1 with FAIL on V2/V5/V4/V6/V8/V3/V9 respectively.

EVIDENCE:
- Commits on `origin/ai-05-world`: `d9435c9` (direction lock), `0e30236` (matrix), `b200a85` (fixture), `5895272` (validator), plus this handoff and PROGRESS commits.
- Validator stdout (VERIFIED, run 2025-09-10 in sandbox): 
  `PASS [V1] parsed; fixture_kind=MOCK schema_version=0.1.0-draft` … `RESULT OK (9 passed, 0 failed)`.
- No build, no Unity, no device run was performed (none exists to run). No visual asset was produced in this phase; visual claims in the documents are design intent, not measured results.

PERFORMANCE_NOTES:
- No runtime code. Budgets in the Direction Lock (§6 texture ceilings, §8 LOD/particle limits) are explicitly labelled hypotheses PENDING AI-11 budgets. Design choices that reduce cost by construction: ≤ 6 master shaders, `_RestoreAmount` parameter instead of per-tier mesh sets, one planar water level per zone, one particle system per beacon on Low tier, no real-time GI, no day/night, no weather in v1.

SECURITY_OR_PRIVACY_NOTES:
- None. No credentials, no telemetry, no personal data. Validator is stdlib-only and offline.

KNOWN_LIMITATIONS:
- Presentation IDs and fixture field names are DRAFT until Phase 1; `canonical_biome_id` is `null` everywhere pending AI-02.
- Screen orientation UNKNOWN (DEP-04); readability rules assume portrait-first as a hypothesis.
- Colour temperatures / value bands in the Lock are starting hypotheses to be measured in Phase 4 with real cube materials.
- "Quiet Engine" vs "Silent Engine" naming CONFLICT unresolved (DEP-03, AI-09).
- No concept art or blockout exists yet; this phase locks direction, not assets.

RISKS:
- R-01 (Medium): if AI-02's `CC.BIOME.STATE` uses a tier model other than 0–4, the Matrix tier looks need re-binding (mitigation: pure-function contract in Matrix §5 keeps the remap local to an adapter).
- R-02 (Low): downstream tracks may treat the MOCK fixture as production data — mitigated by `fixture_kind: MOCK`, `_mock_notice`, validator V9, and the `fixtures/` path outside any future `Assets/` tree.
- R-03 (Low): legacy ownership mappings (DEP-05) could cause a CI ownership validator to mis-attribute AI-05 files if adopted as-is.
- R-04 (Product): the cut list rejects day/night and weather; if Product wants them, the R3 cube-contrast guarantee must be re-designed.

INTEGRATION_STEPS:
1. AI-13: create `integration` branch from `main` (DEP-06) and ratify `09_ART_AUDIO/environment/` as the AI-05 owned path (DEP-07); update ownership examples (DEP-05).
2. Open PR `ai-05-world` → `integration` using `07_GITHUB/PR_TEMPLATE.md`; merge order per `PHASE_KICKOFF_PROCEDURE.md` (docs/contract-adjacent, no code conflicts; independent of other tracks).
3. AI-01: ratify Direction Lock §9 boundaries + cut list (DEP-08) or return with a decision record.
4. AI-09: resolve DEP-03 naming; AI-05 will rename the `quiet_engine` slug before Phase-1 freeze if required.
5. AI-02 (Phase 1): publish `CC.BIOME.STATE`; AI-05 will bind `canonical_biome_id` and bump fixture to `0.2.0` — additive change.
6. AI-11 (Phase 1): publish budgets; AI-05 replaces hypothesis numbers in Lock §6/§8 with budget references.
7. AI-10: may adopt `validate_environment_fixtures.py` into the QA pipeline as-is (no dependencies).

ROLLBACK_STEPS:
- Revert commits `d9435c9`, `0e30236`, `b200a85`, `5895272` and the handoff/PROGRESS commits on `ai-05-world`, or `git rm -r 09_ART_AUDIO/environment/` and restore the AI-05 section of `00_CONTROL/PROGRESS.md` to the template. No other file, contract or ID is affected; nothing consumes these artifacts yet.

NEXT_SAFE_ACTION:
- Wait for DEP-06/07/08 ratifications; in parallel, prepare Phase-1 inputs: the `_RestoreAmount` shader-property contract proposal and the presentation-adapter interface request (`BiomePresentationState` DTO) for AI-02/AI-13 review. Do not start asset production before the Investment Gate.

OWNERSHIP_AUDIT:
- All added files are under `09_ART_AUDIO/environment/` (environment art direction, biome presentation, materials/lighting direction, presentation fixtures/validator) → inside "environment art direction, modular world kits, materials, lighting, LODs, biome presentation".
- The only file outside that path is `00_CONTROL/PROGRESS.md`, edited strictly within the AI-05 section as that file itself instructs.
- No gameplay logic, simulation, UI navigation, audio, build settings, contracts or other accounts' files were touched. `git diff --stat 584141c..HEAD` confirms the file list above.
- Duplicate-system check: no other environment direction, biome presentation matrix, presentation fixture or fixture validator exists in the repo (searched before creation).
