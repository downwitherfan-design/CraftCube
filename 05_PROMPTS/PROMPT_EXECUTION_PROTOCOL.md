# Prompt Execution Protocol

Every phase prompt is a bounded work order.

## Required behavior
1. Read master prompt.
2. Read account track.
3. Read exact phase prompt.
4. Inspect repository and contracts.
5. State the execution plan before editing.
6. Work only inside ownership.
7. Validate assumptions.
8. Test.
9. Self-audit the diff.
10. Produce evidence and handoff.

## Completion threshold
Do not stop because the code compiles. A production task must satisfy behavioral correctness, integration compatibility, quality constraints and evidence requirements appropriate to its phase.

## v7 preflight order

For every task, read in this order:
1. `START_HERE.md`
2. `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md`
3. `00_CONTROL/13_AI_EXECUTION_MANUAL.md`
4. `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md`
5. your AI track
6. the exact phase prompt
7. relevant contracts and design bibles

Do not skip the game bible when working on story, items, world, companions, puzzle design, UX or progression. It is the canonical product intent layer.
