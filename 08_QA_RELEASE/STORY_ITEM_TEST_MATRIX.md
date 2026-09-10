# CraftCube v7 — Story / Item / Equipment QA Matrix

## Functional
- item acquisition follows intended idempotency
- item ownership persists
- equip/unequip is reversible
- upgrades persist
- affinity rules are deterministic
- world consequences persist
- narrative events do not duplicate incorrectly
- discoveries are recorded correctly
- migrations preserve story/item/world state

## Abuse / edge cases
- rapid equip/unequip
- repeated reward claims
- interruption during acquisition
- termination during save
- invalid item references
- incompatible equipment
- full inventory behavior if a cap exists
- chapter replay
- old save version

## Design quality
Verify equipment does not trivialize puzzle mastery and story does not depend on mandatory exposition.
