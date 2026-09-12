# 12_PERFORMANCE — AI-11 owned workspace

| Field | Value |
|---|---|
| Owner | AI-11 — Performance / Android / Device Optimization |
| Branch | `ai-11-performance` |
| Ownership source | `04_AI_ACCOUNTS/AI-11_Track.md`, `00_CONTROL/13_AI_EXECUTION_MANUAL.md` §AI-11, `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md` (`PerformanceBudget` owner) |
| Created in | Phase 00 — Product/IP Lock |

## What lives here

Everything AI-11 owns: performance budgets, the Android device tier matrix, fallback (quality) tier
policy, profiling/measurement method, and performance acceptance evidence.

```text
12_PERFORMANCE/
├── README.md                                  this file
├── phase_00/
│   ├── PERFORMANCE_PRODUCT_LOCK_AI11.md       Phase 00 contribution: platform assumptions, measurable boundaries, success criteria
│   ├── ANDROID_DEVICE_TIER_MATRIX_V1.md       Low / Mid / High tier definitions by capability class (no device names)
│   ├── MEASUREMENT_METHOD_STANDARD.md         how a performance number becomes evidence
│   └── INTEGRATION_REQUESTS_AND_UNKNOWNS.md   IR-AI11-###, U11-##, D-PERF-##
├── contracts/
│   └── PerformanceBudget.v0.1.0-draft.md      DRAFT contract (not consumable until FROZEN in Phase 01)
├── fixtures/
│   └── performance_budget/
│       ├── budget_hypothesis_v0.json          HYPOTHESIS fixture — every number unmeasured, labelled as such
│       └── _expect_invalid/                   NEGATIVE fixtures — validator must reject each one
│           ├── measured_without_evidence.json
│           ├── missing_tier_value.json
│           ├── duplicate_id.json
│           └── unknown_build_id.json
└── tools/
    └── validate_performance_budget.py         stdlib-only deterministic validator for the fixture/schema
```

## What does NOT live here

- Product scope, puzzle rules, UI design, narrative, release signing (forbidden scope for AI-11).
- Measured device results before a device has actually been measured. There are none in Phase 00.
- Device model names. Tiers are defined by capability class until AI-11 has physical devices and
  measurements; naming a device without measuring it would be a fabricated repository fact.

## Status legend used in AI-11 documents

| Label | Meaning |
|---|---|
| VERIFIED | Fact checked against the repository at the stated commit/branch. |
| INFERRED | Derived from verified facts by stated reasoning. |
| ASSUMED | Working assumption; must be replaced by measurement or a decision. |
| HYPOTHESIS | A budget/threshold set before measurement. Never evidence. |
| MEASURED | Backed by evidence per `08_QA_RELEASE/EVIDENCE_STANDARD.md` (device, OS, build ID, scene, method, artifact path). |
| UNKNOWN | Not determinable from the repository; must not be guessed. |
| CONFLICT | Two repository sources disagree; reported to the owner, not resolved by AI-11. |

## Consumers

All runtime tracks consume `PerformanceBudget` once it is FROZEN (Phase 01). Until then, the
fixture in `fixtures/performance_budget/` is a labelled hypothesis that lets AI-02..AI-10 and AI-12
design against explicit numbers instead of guessing.

## Rule of this folder

**No performance number is a fact until it has a device, an OS version, a build ID, a scene, a
method and an artifact path attached.** The validator enforces this mechanically: an entry with
`status: MEASURED` and no evidence is rejected.
