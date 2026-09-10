# Multi-AI Operating Model

## اصل 1 — استقلال واقعی
هر یک از 13 حساب AI دارای:
- branch اختصاصی
- workspace مجزا یا worktree مجزا
- owner file paths
- task IDs مستقل
- prompt مستقل
- acceptance criteria مستقل

AI نباید branch دیگری را edit کند.

## اصل 2 — هماهنگی از طریق قرارداد است
به‌جای shared coding، shared contracts داریم:
- Interfaces
- DTO/Schema
- Events
- Serialized data
- Save schema
- Content IDs
- Asset IDs
- Error codes

## اصل 3 — Interface First
هر dependency قبل از implementation نهایی یک contract می‌گیرد.
نسخه‌گذاری: `MAJOR.MINOR.PATCH`
- MAJOR: breaking change
- MINOR: backward-compatible addition
- PATCH: bug/clarification

## اصل 4 — Stable IDs
هیچ AI نباید ID موجود را برای سلیقه شخصی rename کند. IDها semantic و stable هستند.
نمونه:
`biome.overworld.meadow`
`creature.pollinator.bee`
`chapter.01.meadow`
`event.bloom`

## اصل 5 — Protected Zones
این مسیرها فقط با RFC/ADR تغییر می‌کنند:
- `ProjectSettings/`
- `Packages/manifest.json`
- `ProjectSettings/ProjectVersion.txt`
- `Contracts/`
- `SaveSchema/`
- `.github/workflows/`
- release signing configuration
- localization master keys

## اصل 6 — No Silent Changes
هر PR باید بگوید:
- چه قراردادهایی استفاده شد؟
- چه قراردادهایی تغییر کرد؟
- آیا backward compatibility حفظ شد؟
- چه تستی برای integration دارد؟

## اصل 7 — Merge is a gate, not a reward
PR فقط وقتی merge می‌شود که CI + ownership + contract + manual review pass باشد.

## اصل 8 — No "works on my branch"
هر Track باید خروجی را روی clone تمیز یا CI reproducibly اثبات کند.

## پروتکل روزانه AI
1. Read `PROGRESS.md` و contract versions.
2. Read task card.
3. Implement only owned scope.
4. Run local checks.
5. Create changelog and test evidence.
6. Push branch.
7. Open PR against integration branch.
8. Stop؛ ادغام توسط integration gate انجام می‌شود.

## 13-Track rule
The 13 tracks are independent producers. Dependency is expressed only through released contracts, sample data, mocks, or versioned asset manifests. AI-13 is the integration/governance owner and is not a hidden 14th implementation team.
