# AI Failure Prevention Protocol

This document defines how CraftCube handles common AI failure modes.

## Failure classes
- UNKNOWN_FACT: repository fact is missing or cannot be verified.
- CONTRACT_CONFLICT: two artifacts disagree on a versioned contract.
- OWNERSHIP_VIOLATION: a task appears to require editing another account's files.
- DUPLICATE_SYSTEM: an equivalent system already exists.
- BUILD_FAILURE: compile/import/build fails.
- TEST_FAILURE: behavior differs from approved expectations.
- PERFORMANCE_REGRESSION: measured budget is exceeded.
- ASSET_COMPLIANCE_FAILURE: asset metadata, licensing, format or budget is invalid.
- SAVE_COMPATIBILITY_FAILURE: old production data cannot migrate safely.
- RELEASE_BLOCKER: release-critical condition is not satisfied.

## Safe reaction
1. Stop unrelated edits.
2. Preserve the branch state.
3. Capture the exact failure and reproduction steps.
4. Determine the owning account.
5. Fix only inside ownership or create a change request.
6. Re-run the narrowest relevant test first, then the regression suite.
7. Record the result in the handoff.

## Forbidden recovery behavior
- random refactors;
- broad dependency upgrades without a decision record;
- changing expected tests to match broken behavior;
- deleting data to make a tool work;
- replacing an unknown dependency with an invented API;
- claiming success without evidence.
