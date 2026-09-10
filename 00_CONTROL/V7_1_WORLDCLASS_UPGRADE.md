# CraftCube v7.1 — World-Class Upgrade Layer

This document adds a final pre-production quality layer to the CraftCube v7 start-ready pack.
It does not replace the 13-AI ownership model or the 18-phase roadmap.
It adds missing safeguards and deeper content systems so the project can scale without becoming bloated.

## 1. World-class target

CraftCube should feel like a premium, authored universe rather than a collection of systems.
The player should be able to explain the experience in one sentence, understand what to do without friction, care about at least one character/companion, remember at least one transformed place, and have a reason to master the puzzle language.

## 2. New protected principles

### 2.1 Coherence over quantity
A smaller amount of deeply connected content is preferred over a large amount of disconnected content.

### 2.2 Every system must pay rent
Each system must strengthen at least one of:
- puzzle mastery,
- world causality,
- story/emotion,
- discovery,
- player expression,
- meaningful progression.

### 2.3 No content vacuum
Do not add lore, items, quests, characters, currencies or biomes before defining their interaction with the core loop.

### 2.4 Memory with restraint
World Memory should preserve meaningful player history without creating impossible content permutations or save bloat.

## 3. Narrative depth system

Add a four-layer narrative model:

IMMEDIATE EVENT -> PERSONAL CONSEQUENCE -> WORLD CONTEXT -> LONG-TERM MYSTERY

Every major chapter should have:
- an emotional objective,
- a gameplay objective,
- a visual transformation,
- a question introduced,
- a question resolved or advanced,
- a memorable scene or interaction.

### 3.1 Character memory
Characters and companions should remember selected meaningful events through deterministic flags.
Memory should change later dialogue, reactions, optional scenes or traversal assistance, not explode into hundreds of branches.

### 3.2 Relationship quality
Companion bonds should be based on shared experiences, not repetitive gift-grinding.
A bond level is only useful when it unlocks:
- new interpretation,
- emotional payoff,
- new interaction,
- new discovery,
- or a carefully scoped capability.

### 3.3 Foreshadowing ledger
Every major mystery must have a seeded trail of evidence and a planned payoff before the first related content is considered final.

## 4. Quest architecture upgrade

Quests must use explicit states:
DISCOVERED -> ACCEPTED -> ACTIVE -> BLOCKED (OPTIONAL) -> RESOLVED -> CONSEQUENCE APPLIED

Required properties:
- stable quest ID,
- owner,
- prerequisites,
- fail/recovery behavior,
- reward definition,
- narrative consequence,
- save persistence,
- replay behavior.

Avoid checklist quests such as collect/kill/repeat unless the action itself is a meaningful puzzle or world interaction.

## 5. Item and equipment depth upgrade

### 5.1 Item identity card
Every meaningful item must have:
- stable ID,
- family,
- fantasy/purpose,
- source/provenance,
- acquisition method,
- gameplay behavior,
- puzzle/world interaction,
- upgrade path or intentional no-upgrade reason,
- risk/tradeoff if applicable,
- narrative hook,
- companion reaction eligibility,
- persistence behavior,
- balancing variables,
- telemetry classification if telemetry is enabled.

### 5.2 Upgrade philosophy
Upgrades should create sidegrades, capability branches and contextual advantages before raw numerical escalation.

### 5.3 Item progression loop
DISCOVER -> UNDERSTAND -> TEST -> CHOOSE -> UPGRADE -> MASTER -> REMEMBER

### 5.4 Loadout tension
The player should not be able to equip every useful effect simultaneously.
Limited slots create decisions, but switching must remain friction-light.

### 5.5 Crafting restraint
Crafting exists only when it makes discovery, preparation or world interaction better.
Do not create a crafting tree merely to increase resource sinks.

## 6. Economy without grind

If resources are present:
- every resource needs a readable source and sink;
- no resource may be required solely to delay content;
- early economy must be understandable without spreadsheets;
- rare materials must have predictable non-gambling acquisition paths;
- failed attempts must not create irreversible economic damage.

A soft-currency, hard-currency or premium-currency layer is not assumed. It must earn its existence through a validated product decision.

## 7. Anti-power-creep rules

Equipment, companions and upgrades must not invalidate old content.
New power should preferably create new possibilities rather than make earlier mechanics meaningless.

Use capability checks instead of endless stat scaling.

## 8. Discovery and community value

Secrets should be legible enough to reward observation and discussion.
Some discoveries may intentionally produce “I wonder if…” moments that encourage players to compare interpretations without requiring external services.

## 9. Accessibility and comfort upgrade

Add:
- camera comfort settings,
- motion reduction,
- screen shake intensity,
- haptic intensity,
- audio cue redundancy,
- optional visual indicators for color-dependent mechanics,
- larger touch targets mode,
- left/right hand-friendly interaction where practical,
- safe-area/device-cutout handling,
- text speed control for dialogue.

## 10. Analytics and telemetry

Telemetry is optional for core play and must not become a hidden dependency.
If enabled, it should answer product questions such as:
- where players abandon onboarding,
- which tutorial step causes errors,
- which item is misunderstood,
- which quest is abandoned,
- which biome is revisited,
- where performance drops.

Do not collect unnecessary personal data.
Do not log raw sensitive user content.
Provide privacy-aware event schemas, retention rules and opt-out behavior where required.

## 11. Competitive integrity and anti-cheat

For any leaderboard, challenge score or shared ranking:
- use deterministic challenge seeds where appropriate;
- validate submitted metrics against legal move/state rules;
- distinguish local bests from trusted/server-validated scores;
- never expose secrets or signing material in the client;
- define replay/proof data where practical.

Core offline play remains independent from leaderboard services.

## 12. Content versioning / live content safety

Any remotely delivered or versioned content must support:
- schema version,
- content version,
- compatibility range,
- checksum/integrity validation,
- rollback to last known-good content,
- safe disable of a broken optional feature.

A broken optional content package must never brick the main game.

## 13. Localization at scale

Narrative, item names, quest text, tutorial text and accessibility strings must be localization-safe from the start.
Avoid embedding language-specific assumptions in logic.
Prepare for:
- text expansion,
- pluralization,
- line wrapping,
- RTL where applicable,
- font fallback,
- cultural date/number formatting,
- voice/text synchronization if voice is later added.

## 14. First-session quality target

The first 10 minutes must communicate:
1. what the player controls,
2. why the cube matters,
3. that actions alter the world,
4. that the world has a mystery,
5. that the player has meaningful choices,
6. that progression is more than numbers.

Do not require a long lore introduction to achieve this.

## 15. Vertical Slice Gold requirements

The Gold Slice should contain, at minimum:
- one polished core puzzle interaction,
- one reactive biome,
- one story arc segment,
- one companion interaction,
- one meaningful equipment decision,
- one upgrade/capability decision,
- one discovery,
- one world-memory consequence,
- one save/reload cycle,
- low/mid-device performance validation,
- accessibility smoke test,
- end-to-end evidence.

## 16. Complexity budget

Track the number of:
- currencies,
- item families,
- equipment slots,
- upgrade currencies/materials,
- quest states,
- world states,
- branching flags,
- dependencies,
- runtime systems.

The default direction is to remove complexity unless its player value is demonstrated.

## 17. Human review gates

AI-generated output is never the final authority for:
- product taste,
- narrative canon changes,
- irreversible economy changes,
- public-facing monetization,
- legal/privacy decisions,
- store policy interpretations,
- major scope additions.

These require explicit human approval records.

## 18. Final world-class question

Before any feature is kept, ask:

“Will a player remember this feature a week later, and will they understand why it belongs in CraftCube?”

If the answer is no, simplify, combine or cut it.
