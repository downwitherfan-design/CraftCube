# Integration Playbook

## How all accounts work simultaneously

### Stage 1: Contract wave
AI-01 + AI-02 + AI-08 define product, domain and infrastructure contracts.

### Stage 2: Independent implementation wave
All AI accounts build against the frozen contract package. Mocks/stubs are mandatory where a real provider is missing.

### Stage 3: Evidence wave
Each account produces evidence independently.

### Stage 4: Merge wave
Approved PRs enter `integration`. CI catches actual incompatibilities.

### Stage 5: Integration test
Use combined build + end-to-end tests + representative content.

### Stage 6: Gate
If a conflict is found, do not let accounts randomly fix it in each branch. Assign a single owner and publish a contract/version decision.

## Conflict resolution rules
1. Same file conflict → primary owner decides.
2. Contract conflict → Product + Domain + Release jointly review.
3. Asset ID collision → Art owner keeps canonical ID; consumer updates reference.
4. API mismatch → no workaround in UI; update adapter/contract version properly.
5. CI failure → Build owner reproduces; originating account fixes its code.

## Never use "just merge both"
Two semantically different implementations can compile while corrupting game logic. Use behavior tests and golden fixtures.
