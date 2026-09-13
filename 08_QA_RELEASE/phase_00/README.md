# AI-10 — QA Phase 00 workspace

Owner: **AI-10 — QA / Automation / Quality Engineering**. Everything under `08_QA_RELEASE/phase_00/` is QA-owned. No producer file was edited by AI-10 in Phase 00.

## What Phase 00 QA delivers

Phase 00 locks product vision, scope, audience, platform assumptions, terminology, IP direction, success criteria and measurable boundaries. QA's contribution is to make every one of those locks **verifiable**: each acceptance criterion, first-session proof point, gate metric and complexity cap gets a verification item that says how, when, with which contract and fixture, and who fixes it — without inventing a build, a device result or a number.

| Artifact | ID | Purpose |
|---|---|---|
| `QA_PHASE00_TRACEABILITY_REGISTER.json` | `CC.QA.TRACE` 1.0.0 | Source of truth: `QAT-001..036` verification items tracing `PD-###`, `F10-###`, `IGM-###`, `CUT` caps and release gates. |
| `QA_PHASE00_TRACEABILITY_MATRIX.md` | (rendered) | Human-readable view of the register; kept in sync by the validator. |
| `QA_IP_TERMINOLOGY_RULES.json` | `CC.QA.TERMRULES` 1.0.0 | `QAR-001..008` scope-aware rules consuming Product Lock §6 (IP-safe vocabulary). |
| `QA_FIRST10_PLAYTEST_PROTOCOL_V1.md` | `CC.QA.PROTOCOL.FIRST10` 1.0.0-draft | Fresh-install first-10-minutes protocol with verbatim exit questions and coding rules (AI-01 review pending). |
| `fixtures/playtest_session_record.schema.json` | `CC.QA.PLAYTEST_SESSION_RECORD` 1.0.0 | Pseudonymous per-participant record the protocol produces. |
| `fixtures/MOCK_playtest_session_record_v0.json` | MOCK | Schema exercise only. Not evidence. |
| `QA_PHASE00_VALIDATOR.py` | tool | Deterministic, stdlib-only validator for all of the above + product-document cross-check + negative self-test. |
| `QA_PHASE00_FINDINGS_REGISTER.md` | `CC.QA.FINDINGS` 1.0.0 | `QAF-001..012` evidence-based findings routed to owners. |
| `evidence/*.log` | evidence | Actual validator runs (plain checkout and with AI-01 product docs overlaid). |

## How to run

From the repository root:

```bash
python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py
# exit 0 = no FAIL findings. INFO lines are for human review; SKIP = source not in this checkout.
python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py --no-selftest   # faster, skips negative cases
```

Requires Python 3 standard library only (verified on 3.13.14). No network, read-only.

## Contract position

No contract is frozen in Phase 00 (`00_CONTROL/PROGRESS.md`: all `TBD 1.0.0`). The register therefore references contract **family names** from `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md` and `WORLDCLASS_CONTRACTS_V7_1.md` read-only, and the validator fails if a family name is used that does not appear there. 25 of 36 items are `BLOCKED_ON_CONTRACT` or `BLOCKED_ON_SOURCE` by design; they become fixtures + tests in Phase 01–06.

## ID families registered by AI-10 (pending governance registry, QAF-001)

| Family | Pattern | Meaning |
|---|---|---|
| `QAT-###` | `^QAT-[0-9]{3}$` | QA verification item |
| `QAR-###` | `^QAR-[0-9]{3}$` | QA terminology/IP rule |
| `QAF-###` | `^QAF-[0-9]{3}$` | QA finding |
| `PT-####-###` | `^PT-[0-9]{4}-[0-9]{3}$` | Pseudonymous playtest session |

Collision search across all 15 remote branches before creation: none of these stems were in use.

## What this workspace deliberately does not do

- It does not contain engine code or tests: no Unity project exists yet (`TECHNICAL_BLUEPRINT.md` targets Unity 6 + URP; Phase 02 bootstraps it).
- It does not report any device, performance or playtest number. Every threshold is a product target quoted from AI-01's documents; every status is executability, not outcome.
- It does not edit `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`, whose content is AI-11's domain (QAF-003).
