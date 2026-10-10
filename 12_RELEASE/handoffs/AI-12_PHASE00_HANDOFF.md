# AI-12 Handoff — Phase 00 (Product/IP Lock)

Format: `05_PROMPTS/HANDOFF_TEMPLATE.md`. Evidence labels per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`.

STATUS:
READY_FOR_REVIEW — all AI-12 Phase 00 artifacts exist, are validated and are pushed to `origin/ai-12-build`. PR opened: https://github.com/downwitherfan-design/CraftCube/pull/8 (`ai-12-build` → `integration`). RD-001 update: `integration` branch now exists on origin at `584141c` (VERIFIED after initial inspection; created by governance, not by AI-12) — PR is fast-forwardable, 21 files / +2097 lines, disjoint from every sibling branch. NOT "COMPLETE": phase closure requires (a) AI-13 ratification of the `12_RELEASE/` owned path (RD-003), (b) AI-13 integration-gate approval of PR #8, (c) AI-13 registration of `BuildProvenance` as a contract family and of the `RG/RD/RC` ID families, (d) human decisions RD-005/006/007 which are explicitly deferred, not guessed.

TASK_ID:
PHASE00-AI12-RELEASE-DIRECTION-LOCK

PHASE:
00 — Product/IP Lock

ACCOUNT:
AI-12 — Build / CI/CD / Release / Store

TASKS_COMPLETED:
1. Preflight read: Master Control Prompt, Execution Protocol, Anti-Hallucination Addendum, AI-12 Track, PROGRESS.md, all `06_CONTRACTS/*`, Game Master Bible, 13-AI Execution Manual, V7.1 upgrade layer, Technical Blueprint, Analytics/Privacy architecture, Quality & Release gates, Evidence Standard, Save Migration Policy, GitHub model/branch protection/CODEOWNERS/ownership script, Decision Register, Roadmap, Phase Matrix, Investment Gate, Integration Playbook, Kickoff Procedure, Failure Prevention, Incident Recovery.
2. Repository inspection (VERIFIED): docs-only pack at `584141c`; no Unity project, no `.github/`, no `.gitignore`, no code/tests/fixtures, no secrets on any of 14 branches; no `integration` branch; no contract FROZEN/RELEASED. Inspected the seven sibling tracks that had already pushed Phase 00 work (AI-01…AI-07) for alignment and ID-collision avoidance; read AI-01 `PRODUCT_LOCK_V1.md` and `PRODUCT_DECISION_REGISTER.md` (PD-010/013/014) to align platform, offline and human-gated assumptions.
3. Pre-creation searches across all branches for `RG-###`, `RD-###`, `RC-###`, `release.channel.*`, `content.package.*`, `content.manifest.*`, `telemetry.*.*`, `BuildProvenance`, `.github/`, `.gitignore`, `12_RELEASE/` → all ABSENT → CREATE justified. Confirmed `TelemetryEvent` and `RemoteContentManifest` are assigned to AI-12 in `WORLDCLASS_CONTRACTS_V7_1.md`; confirmed Gate F requires "build provenance"/"checksum manifest" with no schema anywhere → `BuildProvenance` fills a genuine gap.
4. Release & Build Direction Lock v1.0.0: release vision, 6 ranked pillars (R1–R6), verified repo facts, platform/toolchain assumptions with VERIFIED/ASSUMED/UNKNOWN labels and named verifiers, four independent version streams, four release channels (DRAFT IDs), secrets & signing policy (7 rules), provenance requirements, optional-layer flag matrix with conservative defaults (telemetry/remote_content/leaderboards), store-readiness split between AI-12 and human owners, IP-safe internal terminology and DRAFT ID stems, measurable release boundaries, RD-001…RD-010 dependency register, RC-001…RC-006 release cut list, change control.
5. Release Validation Gate Policy v1.0.0: content-digest-keyed packaging that makes it structurally impossible for a content-only change to bypass validation; RG-001…RG-017 check table with owner, Phase 00 status (PRESENT vs MISSING → blocks by construction), channel applicability; pipeline stage order and non-skippable rules; role table.
6. Three DRAFT 0.1.0 contract outlines in registry-template form: `BuildProvenance`, `RemoteContentManifest`, `TelemetryEvent` (catalogue + envelope), each with schema, field rules, failure behaviour, determinism/compatibility promise and open items for Phase 01.
7. Labelled MOCK positive fixtures (one per contract; `fixture_kind: "MOCK"` + `_mock_notice`; all digests are sha256 of labelled placeholder strings) and 7 NEG_ negative fixtures each declaring `_expect_fail`.
8. Stdlib-only deterministic validator implementing RG-010/011/012/016/017 with negative-expectation enforcement (a negative fixture that passes, or fails on the wrong check, is itself a defect).
9. Root `.gitignore` template (secrets block first) and a staged, inactive GitHub Actions release-gate template honouring the gate policy (secret scan first, no `paths:` filter, no `continue-on-error`, packaging depends on validators; unknowns marked `TODO_PHASE02`, action refs marked for SHA pinning).

FILES_ADDED:
- `12_RELEASE/README.md`
- `12_RELEASE/phase_00/RELEASE_AND_BUILD_DIRECTION_LOCK_V1.md`
- `12_RELEASE/phase_00/RELEASE_VALIDATION_GATE_POLICY.md`
- `12_RELEASE/contracts/BuildProvenance.v0.1.0-draft.md`
- `12_RELEASE/contracts/RemoteContentManifest.v0.1.0-draft.md`
- `12_RELEASE/contracts/TelemetryEvent.v0.1.0-draft.md`
- `12_RELEASE/fixtures/build_provenance/MOCK_internal_build_v0.json`
- `12_RELEASE/fixtures/build_provenance/NEG_red_validator_recorded.json`
- `12_RELEASE/fixtures/build_provenance/NEG_secret_key_in_record.json`
- `12_RELEASE/fixtures/build_provenance/NEG_production_with_mock_notice.json`
- `12_RELEASE/fixtures/remote_content_manifest/MOCK_manifest_v0.json`
- `12_RELEASE/fixtures/remote_content_manifest/NEG_required_package.json`
- `12_RELEASE/fixtures/remote_content_manifest/NEG_integrity_mismatch.json`
- `12_RELEASE/fixtures/telemetry_event/MOCK_catalogue_v0.json`
- `12_RELEASE/fixtures/telemetry_event/NEG_pii_field.json`
- `12_RELEASE/fixtures/telemetry_event/NEG_off_stem_event_id.json`
- `12_RELEASE/tools/validate_release_fixtures.py`
- `12_RELEASE/templates/gitignore.template`
- `12_RELEASE/ci/release_gate.template.yml`
- `12_RELEASE/handoffs/AI-12_PHASE00_HANDOFF.md` (this file)

FILES_MODIFIED:
- `00_CONTROL/PROGRESS.md` — AI-12 section only, appended in the format that file prescribes (committed after this handoff).

FILES_DELETED:
- none

CONTRACTS_CONSUMED:
- None RELEASED/FROZEN exist. Consumed as design intent / names only: `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` (ownership of `TelemetryEvent`, `RemoteContentManifest`), `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md` (SaveSchema/ItemDefinition/LocalizationKey consumer rows naming AI-12), `06_CONTRACTS/SAVE_MIGRATION_POLICY.md` (newer-MAJOR rejection pattern mirrored), `06_CONTRACTS/EVENT_AND_ID_POLICY.md`, `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gates F/G/K, DD-010/DD-015, PD-010/013/014 (read from `origin/ai-01-product`, unmerged, READY_FOR_REVIEW — treated as product intent, not released truth). AI-07 `AccessibilityPreference` 0.1.0-draft referenced for storage-decision parallel only.

CONTRACTS_CHANGED:
- none. No file under `06_CONTRACTS/` was edited. Three new DRAFT contract outlines live in the AI-12 path and are proposed for registry inclusion (BuildProvenance is new; the other two already have registry rows naming AI-12).

NEW_IDS:
All DRAFT (mutable until Phase 01 freeze; immutable afterwards). Documents: `AI12-DOC-RELEASE-DIRECTION-LOCK`, `AI12-DOC-RELEASE-VALIDATION-GATE-POLICY`.
- Release Gate checks: `RG-001` … `RG-017` (validator: RG-010/011/012/016/017 implemented).
- Release Dependencies/decisions: `RD-001` … `RD-010`.
- Release Cuts: `RC-001` … `RC-006`.
- Channel IDs: `release.channel.internal|alpha|beta|production`.
- Stems: `content.manifest.<slug>`, `content.package.<slug>`, `telemetry.<domain>.<verb>`.
- Contract IDs: `BuildProvenance` (new), plus schema name `TelemetryEventCatalogue` under the `TelemetryEvent` contract.
- Illustrative MOCK-only IDs inside fixtures (NOT approved catalogue entries): `telemetry.onboarding.step_completed`, `telemetry.performance.frame_budget_exceeded`, `telemetry.diagnostic.drop_summary`, `content.package.mock_optional_biome_pack`, `content.manifest.mock_0001/0002`.
Collision check after creation: `git grep` for every family/stem above on all 13 other remote branches (excluding `05_PROMPTS/`) → 0 hits.

TESTS_AND_COMMANDS:
```
cd <repo>
python3 12_RELEASE/tools/validate_release_fixtures.py
# → RESULT OK (10 passed, 0 failed, 10 fixtures) validator=validate_release_fixtures v0.1.0 ; exit 0
```
Self-test of the validator's own integrity (throwaway copy under /tmp, not committed): changed `_expect_fail` of `NEG_pii_field.json` from RG-017 to RG-010 → `FAIL … negative fixture failed on RG-017 but expected RG-010`, `RESULT DEFECT (9 passed, 1 failed)`, exit 1. Confirms mislabelled negatives cannot silently pass.
CI template lint (ad-hoc): no `continue-on-error:` / `paths:` keys present; YAML parses; jobs = secret-scan, ownership, validators, build-and-provenance.
Secret scan over tracked files using the template's own patterns → 0 findings. Ownership audit: `git diff --name-only 584141c..HEAD | grep -v '^12_RELEASE/'` → empty before the PROGRESS.md commit.

EVIDENCE:
- Commits on `origin/ai-12-build` (19 content commits from `d63b7db` to `87ebf46`, one file per commit, each pushed before the next edit), plus this handoff and the PROGRESS commit.
- Validator stdout (VERIFIED, run in sandbox on 2026-09-10 UTC): 3 positive PASS lines, 7 negative "failed as expected on RG-0xx" PASS lines, `RESULT OK`.
- NOT done and NOT claimed: no Unity build, no APK/AAB, no CI run (workflow is a staged template in a protected zone), no device test, no store submission, no performance measurement. There is nothing in the repository to build yet.

PERFORMANCE_NOTES:
- No runtime code. Design choices that reduce future runtime cost by construction: telemetry compiled out when flag OFF; bounded queue with drop counters instead of unbounded retry; remote content OFF at v1; `string_id`-only telemetry payloads (no free text). All numeric bounds (queue size, backoff, artifact size, CI wall-clock) are explicitly UNKNOWN pending AI-11 budgets and a first Phase 02 build — none invented.

SECURITY_OR_PRIVACY_NOTES:
- No secret, credential, keystore or real identifier exists in any added file; the one NEG fixture that names a `keystore_password` key holds a labelled dummy string and exists precisely to prove RG-011 rejects it.
- Secrets policy (Direction Lock §7) is enforced in three layers: `.gitignore` template, CI secret scan step, RG-011 in-record key scan.
- Telemetry contract forbids personal-data field names and free-text types at schema level; retention classes are a closed set; anything beyond `session_only` in beta/production requires a recorded human privacy decision (RD-007). Store data-safety inputs are derived from the shipped catalogue so binary and declaration cannot diverge.
- Store-managed app signing is PROPOSED, not decided (human, Phase 14). Client never holds a signing or integrity secret.

KNOWN_LIMITATIONS:
- All contracts, IDs and fixture field names are DRAFT until Phase 01 freeze.
- RG-001…RG-009 and RG-013…RG-015 are MISSING by design (their domain owners have not published validators); the gate therefore blocks every channel today — intended, but it means "green integration" cannot exist until Phase 01/02 fill them in.
- CI template has never executed; action versions are `<PIN_SHA_PHASE02>` placeholders; Unity build step is a deliberate hard fail until a project exists.
- `content_digest` roots in the template point at `12_RELEASE/fixtures` as a stand-in until AI-03/AI-09 declare content roots (RD-008).
- Product Lock (AI-01) is unmerged; if its §5/§7.3 change on merge, Direction Lock §4/§9 need a patch bump.
- `07_GITHUB/CODEOWNERS_EXAMPLE.txt` / `validate_ownership.py` still map `.github/` and `Release/` to `AI-08` (RD-002); the CI template's ownership job will mis-attribute AI-12 files until AI-13 fixes the mapping.

RISKS:
- R-01 (Medium): AI-13 may choose a different owned-path convention than `<NN>_<AREA>/` (RD-003); mitigation: everything is under one folder — a `git mv` plus path updates in README/handoff is the whole change.
- R-02 (Medium): if Phase 01 assigns the ID registry (RG-002) a format incompatible with `RG-###`, the family renames before freeze — still DRAFT, no consumer yet.
- R-03 (Low): downstream tracks might copy MOCK fixtures into production paths — mitigated by `fixture_kind`, `_mock_notice`, RG-010, and the `fixtures/` location outside any future `Assets/`.
- R-04 (Product/Human): telemetry defaults (§9) assume opt-out UX will exist by alpha; if the human privacy decision is "no telemetry at v1", the flag matrix flips to OFF everywhere — a one-row change, no contract impact.
- R-05 (Governance): activating any workflow before the RFC (RD-010) would violate the protected-zone rule; AI-12 will not do so.

INTEGRATION_STEPS:
1. AI-13: create `integration` from `main` (RD-001); ratify `12_RELEASE/` as the AI-12 path (RD-003); fix legacy ownership mappings (RD-002); install `12_RELEASE/templates/gitignore.template` as `/.gitignore`.
2. Open PR `ai-12-build` → `integration` using `07_GITHUB/PR_TEMPLATE.md`. Merge order per `PHASE_KICKOFF_PROCEDURE.md`: build/release last; no file conflicts with any sibling branch (verified: disjoint paths).
3. AI-13: add `BuildProvenance` to the contract register (owner AI-12; consumers AI-10/11/13/Human) and register `RG/RD/RC` ID families alongside AI-01's `PD/F10/IGM/CUT`.
4. Phase 01: AI-12 freezes the three contracts to 1.0.0 once AI-02 (schema version sources, RD-009), AI-03/AI-09 (content roots, RD-008) and AI-01/AI-10/AI-11 (initial telemetry event proposals, OI-TE-01) provide inputs; each is an additive fixture bump.
5. Phase 02: RFC to install `12_RELEASE/ci/release_gate.template.yml` as `.github/workflows/release_gate.yml` with SHA-pinned actions and the Unity image decision recorded as an ADR (RD-004); human provides Unity licence / upload keystore into the secret store (RD-005).
6. AI-10: may adopt `validate_release_fixtures.py` into the QA pipeline as-is (stdlib only) and extend the forbidden-field list.

ROLLBACK_STEPS:
- `git revert` the AI-12 commits on `ai-12-build` (range `d63b7db..HEAD`), or `git rm -r 12_RELEASE/` and restore the AI-12 section of `00_CONTROL/PROGRESS.md` to the template. No other file, contract, workflow or ID is affected; nothing consumes these artifacts yet; no CI is active; no secret store entry was created.

NEXT_SAFE_ACTION:
- Wait for RD-001/002/003 from AI-13. In parallel, prepare Phase 01 inputs without editing outside ownership: (a) `BuildProvenance` additive field proposal for the telemetry catalogue digest (OI-BP-01), (b) an integration request to AI-13 for the `integration` branch protection rules that require the release-gate check name, (c) a request to AI-01/AI-10/AI-11 for candidate telemetry events mapped to V7.1 §10 questions. Do not build, sign or activate any workflow before the Investment Gate and the RFC.

OWNERSHIP_AUDIT:
- Every added file is under `12_RELEASE/` (build pipeline, CI/CD templates, signing policy, release channels, store compliance, provenance, content-versioning, telemetry transport/config — all inside "Unity build pipeline, GitHub Actions, signing, APK/AAB, release channels, store compliance" plus the v7 "content validation and release packaging" and v7.1 "build provenance, content versioning, remote-content rollback, telemetry configuration, release safety, store readiness" emphases).
- The only file outside that path is `00_CONTROL/PROGRESS.md`, edited strictly within a new AI-12 section as that file instructs.
- No gameplay, puzzle, art, audio, narrative, UX, domain or contract-registry file was touched. No file under `.github/`, `06_CONTRACTS/`, `07_GITHUB/` was created or edited. Verified via `git diff --name-only 584141c..HEAD`.
- Duplicate-system check: no other release direction, gate policy, provenance/manifest/telemetry contract, release fixture set, release validator, `.gitignore` or CI workflow exists on any branch (searched before creation and re-checked after).
