# Localization & Terminology Bible

**Owner:** AI-09 (`LocalizationKey` contract family, canon terminology) · **Status:** DRAFT v0.1.0
**Consumers:** AI-07 (layout, text expansion, fonts), AI-08 (VO/subtitle sync if voice is ever added), AI-12 (string packaging/validation), AI-10 (key coverage tests).

Scope: key grammar, canon term list as stable keys, translation rules, and the fixture format for source strings. **No runtime string-loading implementation** (AI-02/AI-04/AI-07 territory). No translation into other languages in Phase 00 — only the English *source* fixture exists (`fixtures/loc/en.v0.1.0.json`).

## 1. Principles (`V7_1_WORLDCLASS_UPGRADE.md` §13)

1. No player-facing string is hard-coded. Every string has a `loc.*` key.
2. Keys are semantic, not positional: `loc.dlg.ch01.mira.arrive.1` not `loc.string_042`.
3. Keys are immutable once released. Changing English text does not change the key. Changing *meaning* requires a new key and deprecation of the old one.
4. Source language is **English (en)**. All other locales translate from `en`.
5. Design for expansion: budget **+35 %** width for European languages, **+50 %** height risk for stacked scripts. AI-07 owns the layout response; AI-09 owns keeping source lines short (dialogue <= ~90 chars, item names <= 20, UI terms <= 16).
6. Pluralisation and gender are handled with ICU MessageFormat-style syntax in source strings (`{count, plural, one {…} other {…}}`) — **PROPOSED**, subject to AI-07/AI-12 runtime library decision (OD-06). Source fixtures use it now so the requirement is visible.
7. The Weaver has no fixed gender or name: never write a source line that requires a pronoun for the player. Address as "you"; refer as "the Weaver".
8. RTL readiness: no string embeds directional punctuation assumptions (no ASCII arrows `->` in player text; use words or dedicated glyph keys).
9. Do-not-translate terms are marked `dnt: true` in the term list; transliteration is allowed, translation is not.

## 2. Key grammar (DRAFT v0.1.0)

Lowercase, dot-separated, ASCII `[a-z0-9_.]`. Namespaces:

| Prefix | Content | Example |
|---|---|---|
| `loc.term.<slug>` | canon terminology display forms (mirrors `nar.term.<slug>`) | `loc.term.axis_loom` |
| `loc.char.<slug>.name` | character display name | `loc.char.mira.name` |
| `loc.chapter.<nn>.title` | chapter title | `loc.chapter.01.title` |
| `loc.act.<n>.title` / `.question` | act title and core question | `loc.act.1.question` |
| `loc.dlg.<chapter_nn>.<speaker>.<beat>.<n>` | dialogue line n in a beat | `loc.dlg.ch01.mira.arrive.1` |
| `loc.dlg.<chapter_nn>.<speaker>.<beat>.<n>.<flag_value>` | flag-dependent variant (closed set, see Character Arc Register) | `loc.dlg.ch09.orin.core.1.orin` |
| `loc.item.<slug>.name` / `.lore` / `.epilogue.<flag_value>` | item display text (narrative fields only; AI-07 owns UI labels) | `loc.item.memory_lens.lore` |
| `loc.motif.<slug>.record` | optional collectible-record text tied to a motif | `loc.motif.three_notch_mark.record` |
| `loc.biome.<slug>.name` | biome display name | `loc.biome.hearthwild.name` |

UI/system strings (buttons, settings, accessibility labels) are **not** in this namespace plan; AI-07 proposes its own `loc.ui.*` grammar under the same `LocalizationKey` contract in Phase 01. AI-09 will register it; this avoids two owners writing into one namespace.

## 3. Canon terminology (stable IDs)

Meaning is canon (AI-09). Display form is the `en` source string (DRAFT). `dnt` = do not translate (transliterate only). `class` = grammatical hint for translators.

| Term ID | EN source | dnt | class | Meaning / usage rule |
|---|---|---|---|---|
| `nar.term.asterra` | Asterra | yes | proper noun | the world. Internal working name; public use is a Product decision (OD-01). |
| `nar.term.axis_loom` | the Axis Loom | yes (Loom) | proper noun, sing. | the world-spanning spatial mechanism. Short form "the Loom" after first use. Never "machine" in canon voice (Ch.10 payoff). |
| `nar.term.great_misalignment` | the Great Misalignment | no | proper event | the historical fracture. Translate the meaning (mis-alignment), keep capitalisation as a named event. |
| `nar.term.weaver` | Weaver | no | title, sing./pl. | one who can read the Loom's language. Player is "the Weaver". Plural "Weavers" = the vanished practitioners. Never "chosen one", "hero". |
| `nar.term.node` | node | no | common noun | a local Loom anchor that responds to the cube. Never "altar", "shrine". |
| `nar.term.alignment` | alignment | no | common noun | an arrangement the Loom recognises. Verb "align". Never "solve" in character dialogue (that is the player's word, fine in UI). |
| `nar.term.misalignment` | misalignment | no | common noun | any non-recognised arrangement; from Ch.06 also an intentional tool. Never "corruption", "evil". |
| `nar.term.echo` | echo | no | common noun | a remembered prior state (WR-3). |
| `nar.term.record` | record | no | common noun | any Weaver-left historical artefact. Never "log", "journal", "diary" (Architect anti-pattern). |
| `nar.term.relic` | relic | no | common noun | story-important item family (Equipment Bible). |
| `nar.term.keeper` | Keeper | no | title | Orin's role. |
| `nar.term.cartographer` | Cartographer | no | title | Mira's role. |
| `nar.term.quiet_architect` | the Quiet Architect | no | title (invented by cast) | the unknown builder(s). Cast-invented; must read as a nickname, not a name. |
| `nar.term.three_notch_mark` | the mark | no | common noun | the builders' note of intent. Characters just say "the mark". |
| `nar.term.hearthwild` | Hearthwild | yes | proper noun | biome 1 |
| `nar.term.glassroot` | Glassroot | yes | proper noun | biome 2 |
| `nar.term.sunken_grid` | the Sunken Grid | no | proper noun | biome 3 — translate "sunken", keep "Grid" sense |
| `nar.term.ember_hollow` | Ember Hollow | no | proper noun | biome 4 — translatable compound |
| `nar.term.verdant_archive` | the Verdant Archive | no | proper noun | biome 5 — translatable compound |
| `nar.term.quiet_engine` | the Quiet Engine | no | proper noun | biome 6 — translatable; must share the word "Quiet" with `quiet_architect` in every locale |
| `nar.term.hold` | Hold | no | finale option | `final_configuration = hold` — settle the Loom at rest |
| `nar.term.weave` | Weave | no | finale option | `final_configuration = weave` — keep the Loom changing under Weaver guidance |
| `nar.term.open` | Open | no | finale option | `final_configuration = open` — let the Loom compose without a Weaver |

Finale option terms are PROPOSED pending OD-04.

## 4. Translator rules per term class

- **proper noun, dnt:** transliterate to target script; never localise meaning.
- **translatable compounds** (Ember Hollow etc.): translate both parts; keep them as two-part names where the language allows.
- **titles** (Weaver, Keeper, Cartographer): capitalise as the target language capitalises titles; gender-neutral form where the language has one, otherwise use the form that matches the character (Mira f., Orin m.) and a neutral or default form for the player.
- **shared-word constraint:** `quiet_engine` and `quiet_architect` must share their adjective in every locale (the link is a clue).

## 5. Dialogue authoring rules

1. One idea per line. Max ~90 EN chars.
2. No line explains a control or mechanic the player has already performed.
3. Flag variants are written as *separate keys* with the flag value as the last segment; the non-variant key holds the default. Runtime selects `key.<value>` if present else `key` (proposed selection rule for AI-04/AI-07; recorded as OD-06).
4. Speaker is part of the key, never part of the string.
5. Nox has no dialogue keys. Vocalisations are audio events (AI-08), not text. If accessibility requires captions for Nox sounds, those are `loc.caption.*` keys owned jointly with AI-07 — OD-07.

## 6. Fixture format

`fixtures/loc/en.v0.1.0.json`:
```json
{
  "schema": "cc.loc.strings",
  "schema_version": "0.1.0",
  "locale": "en",
  "status": "DRAFT",
  "strings": { "<loc key>": "<source text>" }
}
```
Flat map, sorted keys, UTF-8, no comments. Adding keys = minor bump. Changing text of an existing key = patch bump. Removing/renaming a key = major bump + deprecation note. Other locales will use the identical shape with `locale` changed and **must not contain keys absent from `en`** (validator rule for AI-10/AI-12).

## 7. What the validator checks today (`tools/validate_narrative_registry.py`)

- every key in `en` matches the grammar;
- every `nar.term.*` in the canon registry has a `loc.term.*` string;
- every `nar.character.*` has `loc.char.<slug>.name`;
- every chapter has `loc.chapter.<nn>.title`; every act has title + question;
- every `nar.item_lore.*` has `.name` and `.lore`;
- dialogue keys referenced by `FIRST_TEN_MINUTES.md` exist;
- no duplicate keys; no non-ASCII in keys; no ASCII arrows in strings.

## 8. Not decided here (see `OPEN_DECISIONS_AI09.md`)

Public use of "Asterra"; target locale list; MessageFormat library; voice-over; caption ownership; finale option names.
