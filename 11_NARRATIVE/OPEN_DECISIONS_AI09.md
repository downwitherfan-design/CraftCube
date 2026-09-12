# Open Product / Human Decisions — AI-09 (Phase 00)

**Owner of this list:** AI-09. **Deciders:** AI-01 (Product) and the human product authority per `00_CONTROL/13_AI_EXECUTION_MANUAL.md` "Human approval gates" (story canon is a human gate).
Nothing below has been guessed. Where AI-09 needed a working value to keep the pack internally consistent, it is marked PROPOSED and is reversible.

| ID | Decision needed | AI-09 proposal (PROPOSED, reversible) | Blocks | Affected tracks |
|---|---|---|---|---|
| OD-01 | Public use of the world name "Asterra" and working title "The Loom of Asterra"; trademark clearance | Keep internal only until legal clears it. All player-facing use is behind `loc.term.asterra`, so the name can change with a string edit. | Phase 01 loc freeze (key stays; text may change) | AI-01, AI-12 |
| OD-02 | Cast size: are biome-local speaking characters allowed beyond Mira/Orin/Nox? | No additional speaking cast in Phase 00–06. Re-evaluate after Vertical Slice Gold with playtest evidence of attachment. | Any Phase 08+ content that wants new NPCs | AI-01, AI-06, AI-07, AI-08 |
| OD-03 | Story Promise approval (Story Bible "Story promise") | As written. | Phase 00 READY for AI-09 (formal) | AI-01 |
| OD-04 | Finale option set `nar.flag.final_configuration` = {hold, weave, open} and their names | Three closed options; no "bad" ending; all three warm. Names are English placeholders. | Ch.10 content; epilogue presentation | AI-01, AI-05, AI-07 |
| OD-05 | Rejection/merge of "Wayfinder Shard" from the seed item set into Nox's sensing role | Merge (anti-duplication). If Product wants a non-companion hint item, re-open here. | none (additive either way) | AI-01, AI-02, AI-03 |
| OD-06 | Localization runtime conventions: ICU MessageFormat plural/gender syntax; flag-variant key selection rule (`key.<value>` else `key`) | Adopt both as the contract in Phase 01 unless AI-07/AI-12 present a library constraint. | Phase 01 `LocalizationKey` contract freeze | AI-07, AI-12, AI-04 |
| OD-07 | Ownership of accessibility captions for non-verbal companion sounds (`loc.caption.*`) | AI-09 authors text; AI-07 owns when/how shown; key namespace registered by AI-09. | Phase 11 accessibility | AI-07, AI-08 |
| OD-08 | Voice-over: none / partial / full | Write for unvoiced text. Decide before Phase 06 so VO does not become a late dependency. | Phase 06 audio scope | AI-01, AI-08 |
| OD-09 | Target locale list for launch | Not proposed (business decision). Pack is locale-agnostic; en source only. | Phase 14 store package | AI-01, AI-12 |
| OD-10 | Folder path for AI-09-owned narrative data (`11_NARRATIVE/` proposed; numeric prefix may collide with future folder plan) | Keep until AI-13 publishes the Phase 01 ownership map; move is non-breaking because IDs are not paths. | none | AI-13 |
| OD-11 | PR target branch: phase prompt says `integration`; repository has only `ai-13-integration` | AI-09 targets `ai-13-integration` and does not create `integration` (governance = AI-13). | Merge sequencing | AI-13 |

## Explicitly NOT decided by AI-09 (outside ownership)

- Exact puzzle size/difficulty per beat (AI-03).
- Number of equipment slots (Product/UX, Equipment Bible).
- Whether narrative flags live in the main save blob or a sub-document (AI-02).
- Dialogue presentation form (AI-07).
- Any asset, cue or shader (AI-05/06/08).
