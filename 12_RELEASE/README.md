# 12_RELEASE — AI-12 owned workspace (Build / CI/CD / Release / Store)

| Field | Value |
|---|---|
| Owner | AI-12 — Build / CI/CD / Release / Store |
| Branch | `ai-12-build` |
| Ownership source | `04_AI_ACCOUNTS/AI-12_Track.md`, `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` (row AI-12), `00_CONTROL/13_AI_EXECUTION_MANUAL.md` §AI-12 |
| Path status | PROPOSED — single-owner top-level folder (same pattern as `11_UIUX/` for AI-07). Ratification requested from AI-13 (see `handoffs/`). |

## What lives here

```text
12_RELEASE/
├── README.md                          this file
├── phase_00/                          Phase 00 deliverables (direction lock, gate policy)
├── contracts/                         AI-12-owned contract drafts (BuildProvenance, RemoteContentManifest, TelemetryEvent)
├── fixtures/                          MOCK-labelled positive fixtures + NEG_ negative fixtures per contract
├── tools/                             stdlib-only deterministic validators (no third-party dependencies)
├── templates/                         files that must be installed at repo root by the governance owner (e.g. .gitignore)
├── ci/                                GitHub Actions workflow templates, staged here until an RFC activates them under .github/workflows/
└── handoffs/                          per-phase handoff documents (05_PROMPTS/HANDOFF_TEMPLATE.md format)
```

## What does NOT live here

- No gameplay, puzzle, art, audio, narrative or UX behaviour. AI-12 changes only build-specific configuration required for release.
- No secrets, keystores, service-account JSON, API keys or signing passwords — ever. See `phase_00/RELEASE_AND_BUILD_DIRECTION_LOCK_V1.md` §Secrets and signing policy.
- No production save data or user data in fixtures (`08_QA_RELEASE/TEST_DATA_POLICY.md`).

## Status legend used in this folder

| Label | Meaning |
|---|---|
| DRAFT | Mutable. Not consumable as a released contract. Becomes FROZEN only through the Phase 01 contract freeze. |
| PROPOSED | Requires ratification by the named owner (AI-13 governance or Human Product Authority). |
| MOCK | Fixture that stands in for a producer that does not exist yet. Machine-detectable via `fixture_kind: "MOCK"`. Never a production artifact. |
| VERIFIED / INFERRED / ASSUMED / UNKNOWN | Evidence labels per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`. |

## Running the validators

```bash
python3 12_RELEASE/tools/validate_release_fixtures.py
```

Exit code `0` = all positive fixtures pass and every negative fixture fails on the check it names. Any other exit code = defect; do not merge.
