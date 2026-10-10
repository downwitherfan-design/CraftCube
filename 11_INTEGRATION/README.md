# 11_INTEGRATION — AI-13 Integration / Governance Workspace

**Owner:** AI-13 (Integration / Technical Production / Architecture Governance)
**Ownership basis:** `04_AI_ACCOUNTS/AI-13_Track.md`, `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` ("Shared contracts are owned by AI-13 as governance unless a contract explicitly names another owner").

This directory holds the cross-track governance artifacts that AI-13 owns:
contract registry, dependency graph, risk register, change requests, merge
sequencing and integration gates. It contains **no implementation** and **no
design canon**. Design canon stays in `00_CONTROL/`, `01_PREPRODUCTION/` and
`02_ARCHITECTURE/`; contract policy stays in `06_CONTRACTS/`. Files here
reference those documents; they do not replace them.

## Rules for this directory

- Only AI-13 edits files here. Other accounts request changes through
  `CHANGE_REQUESTS.md` entries or by referencing an ID in their handoff.
- Everything is additive and versioned. IDs (`RISK-nnnn`, `CR-nnnn`,
  `OD-nnnn`, contract IDs) are never renamed or reused once committed.
- `registry/contract_registry.json` is the single machine-readable source of
  truth for contract identity, owner, consumers and status. Markdown tables
  derived from it are generated with `scripts/validate_registry.py --render`
  and must not be hand-edited.
- A contract is consumable only when its status is `FROZEN` or `RELEASED`
  (see `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`). At Phase 00 every
  contract is `DRAFT` with no version assigned.
- Claims in this directory are labelled VERIFIED / INFERRED / ASSUMED /
  UNKNOWN / CONFLICT / MISSING per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`.

## File index

| File | Purpose | Update cadence |
|---|---|---|
| `PHASE00_PREFLIGHT_FINDINGS.md` | Repository facts found during Phase 00 preflight, with evidence labels | Phase 00 only (frozen after gate) |
| `registry/contract_registry.json` | Machine-readable contract identity register | Every contract change |
| `scripts/validate_registry.py` | Deterministic validator for registry, risk, CR and decision IDs | When validation rules change |
| `CONTRACT_REGISTRY.md` | Rendered view of the JSON registry | Regenerated, never hand-edited |
| `DEPENDENCY_GRAPH.md` | Producer/consumer graph across the 13 tracks and mock policy per edge | Every contract or ownership change |
| `RISK_REGISTER.md` | Cross-track risks with owner, trigger, mitigation, status | Every phase |
| `CHANGE_REQUESTS.md` | Actionable requests returned to owning accounts | Continuous |
| `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md` | Actual branch model, PR flow, merge order, rollback | When branch model changes |
| `COMPLEXITY_BUDGET.md` | Tracked counts required by `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §16 | Every phase gate |
| `PHASE00_INTEGRATION_GATE.md` | Phase 00 lock checklist, per-account expected artifacts, open Product/Human decisions | Phase 00 |
| `evidence/` | Command outputs backing claims made in handoffs | Every handoff |

## How downstream accounts use this directory

1. Before starting a task, read `CONTRACT_REGISTRY.md` to see whether the
   contract you depend on is `DRAFT`, `FROZEN` or `RELEASED`. If it is
   `DRAFT`, build against your own clearly-labelled mock/fixture.
2. Check `DEPENDENCY_GRAPH.md` for who produces what you consume and which
   mock policy applies to that edge.
3. Check `CHANGE_REQUESTS.md` for any `CR-nnnn` addressed to your account.
4. Check `RISK_REGISTER.md` for risks you own.
5. Open your PR against `integration` following
   `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`.

## Validation

```bash
python3 11_INTEGRATION/scripts/validate_registry.py
```

Exit code `0` means all identity/ownership/status rules pass. Any other exit
code is a gate failure and must be resolved by the owning account before merge.
