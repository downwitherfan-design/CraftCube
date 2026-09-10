# CraftCube v7 — Master Contract Register

## Contract families

| Contract | Primary owner | Consumers |
|---|---|---|
| PuzzleState | AI-02 | AI-03/04/05/06/10/13 |
| WorldState | AI-02 | AI-05/06/09/10/13 |
| WorldStateEvent | AI-13 governance + AI-02 domain | AI-03/05/06/08/09/10 |
| ItemDefinition | AI-02 | AI-03/07/09/10/11/12 |
| EquipmentDefinition | AI-02 | AI-03/04/07/09/10/11/12 |
| EquipmentEffect | AI-02 | AI-03/04/05/06/07/10 |
| NarrativeEvent | AI-09 | AI-04/07/08/10/13 |
| DiscoveryDefinition | AI-03 | AI-04/07/09/10/12 |
| CompanionReaction | AI-06 | AI-04/08/09/10 |
| RewardDefinition | AI-03 | AI-02/07/09/10/12 |
| SaveSchema | AI-02 | AI-07/10/11/12/13 |
| LocalizationKey | AI-09 | AI-07/08/12 |
| PerformanceBudget | AI-11 | all runtime tracks |

## Versioning

No released ID is silently renamed.
Breaking changes require:
- change request,
- impact report,
- migration plan,
- affected-track list,
- integration approval.

## Mock policy

For every contract, a minimal test fixture must exist so dependent tracks can work without the producer's implementation.


See `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` for additional quest, narrative-memory, upgrade, resource, telemetry, competitive-result, remote-content and accessibility contracts.
