# CraftCube — Release Validation Gate Policy v1.0.0 (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-12 — Build / CI/CD / Release / Store |
| Document ID | `AI12-DOC-RELEASE-VALIDATION-GATE-POLICY` |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW (POLICY — mechanically enforced from Phase 02 when the CI template in `../ci/` is activated by RFC, see RD-010) |
| Phase | 00 — Product/IP Lock |
| Answers | Phase 00 AI-12 prompt: "Content validation must include narrative IDs, item IDs, equipment effects, save migrations, localization keys and discovery references. Release packaging must prove that content-only changes cannot bypass validation." |
| Sources | `08_QA_RELEASE/QUALITY_AND_RELEASE.md` (Gates A–K), `06_CONTRACTS/EVENT_AND_ID_POLICY.md` ("CI should fail on duplicate canonical IDs"), `06_CONTRACTS/SAVE_MIGRATION_POLICY.md`, `09_ART_AUDIO/ASSET_PIPELINE.md` ("placeholders … mechanically detectable before release"), `01_GOVERNANCE/INTEGRATION_PLAYBOOK.md` §Conflict rule 5 |

## 1. The problem this policy prevents

Content-only changes (a new item definition, a renamed localization key, a tweaked narrative flag, a new discovery reference) are the changes most likely to be treated as "safe" and waved through. They are also the changes most likely to ship a dangling ID, an unmigrated save field or a placeholder asset. This policy makes it **structurally impossible** for such a change to reach a release channel without the full validator set having run and passed on exactly the bytes being shipped.

## 2. Principle: validation is a property of the artifact, not of the PR

A PR passing CI is necessary but not sufficient. The release artifact itself must carry proof that validation ran on its content:

1. CI computes a **content digest** = deterministic hash over the sorted list of `(relative_path, sha256)` for every file under the declared content roots (RD-008; paths bound in Phase 01).
2. Each validator writes a result record containing the content digest it validated, its own `validator_id` and `validator_version`, the exit status and a findings count.
3. The packaging step **refuses to build** unless, for the current content digest, a result record exists for **every** validator in the required set (§3) with exit status `0`.
4. The `BuildProvenance` record embeds the content digest and the list of validator result records. A provenance record whose validator list is incomplete fails the provenance validator (`RG-012`).

Consequence: there is no code path that produces a release-channel artifact from content that was not validated, because the packaging step keys on the digest of the actual bytes, not on a branch status.

## 3. Required validator set (Release Gate checks, `RG-###`)

Each row names the **owner of the validator logic** (the domain owner) and states that AI-12's role is to **require and run** it, never to author its rules. Where the owner has not yet published a validator, the gate treats it as MISSING and **blocks** the release channel (a missing validator is never satisfied by default — R3 / "no silent fallbacks").

| RG ID | Check | Validator owner | Phase 00 status | Blocks which channels |
|---|---|---|---|---|
| RG-001 | Content schema version present and known for every content file | AI-03 (content schema) | MISSING (no schema) | all |
| RG-002 | Every content ID unique across the whole content set (`EVENT_AND_ID_POLICY.md` collision rule) | AI-13 governance registry; AI-10 validator | MISSING | all |
| RG-003 | Every narrative ID / `NarrativeEvent` / `NarrativeMemoryFlag` referenced exists and is owned by AI-09 | AI-09 definitions; AI-10 validator | MISSING | all |
| RG-004 | Every item ID / `ItemDefinition` / `ItemIdentity` referenced exists (AI-02) | AI-02 definitions; AI-10 validator | MISSING | all |
| RG-005 | Every `EquipmentEffect` referenced is a defined effect, and no effect violates the protected-core rule (DD-002; PD `[BUILD]` "all equipment removed → critical path still solvable") | AI-02 + AI-03; AI-10 regression | MISSING | all |
| RG-006 | Every `DiscoveryDefinition` reference resolves; optional discoveries have no critical-path dependency (DD-006) | AI-03; AI-10 validator | MISSING | all |
| RG-007 | Every localization key used in content exists in the master key table; no hard-coded player-facing string outside the localization layer; pseudo-loc variant builds | AI-09 keys; AI-07 layout; AI-10 validator | MISSING | alpha, beta, production |
| RG-008 | Save schema: fixture for every released save version migrates to current; corrupted/truncated/future-version cases behave per `SAVE_MIGRATION_POLICY.md` | AI-02 migrations; AI-10 tests | MISSING | all |
| RG-009 | No placeholder asset in release (`ASSET_PIPELINE.md`); every asset carries required metadata (assetId, owner, license…) | AI-05/06/08 metadata; AI-10 validator | MISSING | beta, production (internal/alpha may carry labelled placeholders) |
| RG-010 | No MOCK fixture (`fixture_kind: "MOCK"`) is reachable from the shipped content roots | AI-12 (this track's validator) | **PRESENT** — `../tools/validate_release_fixtures.py` check `RG-010` | all |
| RG-011 | Secret-pattern scan of the diff and of the packaged artifact: 0 findings | AI-12 | PRESENT as policy + CI template step; pattern list in `../ci/` | all |
| RG-012 | `BuildProvenance` record validates against its contract and lists a passing result for every RG in this table applicable to the channel | AI-12 | **PRESENT** — validator | all |
| RG-013 | `content_version` bumped when content digest differs from the previous tagged release of the same channel (Direction Lock §5) | AI-12 | POLICY; mechanised in Phase 02 | alpha, beta, production |
| RG-014 | Rejected-terminology scan (Product Lock §6.3 "Rejected / avoid" list) over package identifiers, channel names and store metadata | AI-01 owns the list; AI-12 runs | POLICY; list consumed read-only once merged | production |
| RG-015 | Optional-layer flags match the channel matrix (Direction Lock §9); airplane-mode acceptance evidence attached for release channels (PD-010) | AI-12 flags; AI-10 test | POLICY | alpha, beta, production |
| RG-016 | `RemoteContentManifest` (if the flag is ever ON) validates: checksum present, compatibility range covers the app version, `rollback_to` resolves | AI-12 | PRESENT — validator (contract DRAFT) | any channel with `remote_content: true` |
| RG-017 | `TelemetryEvent` catalogue validates: every event has stable ID, schema version, purpose tag, retention class; no forbidden field classes | AI-12 schema; AI-10 privacy QA | PRESENT — validator (contract DRAFT) | any channel with `telemetry: true` |

Pre-creation search for `RG-0` across all 14 branches → ABSENT. IDs are DRAFT until Phase 01 freeze, then immutable and never reused.

## 4. Pipeline stages and what may not be skipped

```text
[PR opened] ─► ownership check ─► secret scan (RG-011) ─► content digest
        ─► required validators for touched domains (always includes RG-002, RG-010, RG-011)
        ─► unit / contract / golden tests
        ─► [merge to integration]
[integration green] ─► FULL validator set (all RG applicable to channel)
        ─► build ─► sign (secret store only) ─► BuildProvenance generated (RG-012)
        ─► artifact + checksum manifest + provenance stored with retention
        ─► [promotion to channel] requires human approval for beta/production
```

Non-negotiable rules:
- **No path filter may exclude a validator.** A CI `paths:` filter may *add* fast feedback jobs; it may never be used to *skip* the full set before packaging.
- **`continue-on-error` is forbidden on any RG step.**
- **A validator that cannot run (missing tool, missing schema) fails the gate** — it does not pass by absence.
- **Skipping a test requires an approved reason recorded in the PR** (Master Control Prompt "Test integrity rule").
- **Re-running a failed job does not re-validate stale content:** the digest is recomputed every run.

## 5. Roles

| Role | Responsibility |
|---|---|
| AI-12 | Defines the gate, runs every validator, generates provenance, refuses to package on any red/missing RG, owns RG-010/011/012/013/015/016/017. |
| Domain owners (AI-02/03/05/06/07/08/09/11) | Publish their validators and fixtures (Phase 01+). Failures are fixed in their own ownership (Integration Playbook rule 5: "Build owner reproduces; originating account fixes its code"). |
| AI-10 | Authors cross-domain validators/tests where the table says so; verifies gate behaviour with negative cases. |
| AI-13 | Ratifies this policy, owns the ID registry that RG-002 reads, decides RFC for `.github/workflows/` activation (RD-010). |
| Human | Approves promotion to beta/production; owns legal/privacy stance behind RG-015/RG-017. |

## 6. Evidence this policy is enforceable today (Phase 00, docs-only repo)

- `../tools/validate_release_fixtures.py` implements RG-010, RG-012, RG-016, RG-017 against the DRAFT contracts and ships with negative fixtures that must fail on the named check. Run and results recorded in `../handoffs/AI-12_PHASE00_HANDOFF.md`.
- The CI template in `../ci/release_gate.template.yml` encodes §4 ordering with no `continue-on-error` and no skip-by-path on the packaging job. It is **not active** (protected zone, RD-010) and has not been executed; no run result is claimed.
- The remaining RG rows are explicitly MISSING and block release by construction. This is the intended Phase 00 state: the gate exists before the content does.

## 7. What this policy deliberately does not do

- It does not define the *rules* of any content validator owned by another track.
- It does not choose a CI vendor beyond assuming GitHub Actions (the repository is on GitHub; `04_AI_ACCOUNTS/AI-12_Track.md` names GitHub Actions in AI-12's ownership).
- It does not claim any build, test or device result.
