# MASTER ROADMAP — CraftCube v7

## New pre-production gate
Before Phase 00, run `01_PREPRODUCTION/INVESTMENT_GATE.md`. This protects time and capital by validating product value, technical feasibility, experience quality, scope, and business assumptions before expensive parallel production.

## چشم‌انداز تولید
CraftCube یک بازی موبایلی puzzle/relaxation با یک هسته‌ی twisting-cube، رشد بایوم، موجودات واکنش‌پذیر، Bloom/Collapse، روایت محیطی، collection، و لایه‌ی meta است. هدف، محصولی است که حس «بازی جهانی» داشته باشد، نه صرفاً یک نمونه‌ی فنی.

## مدل اجرایی
پروژه به 13 حساب/Track مستقل تقسیم می‌شود. هر Track در branch و workspace جدا کار می‌کند و فقط مسیرهای مالکیت خودش را تغییر می‌دهد. همه Trackها به Contract Pack نسخه‌دار، Mock/Stub و Integration Gate مشترک متصل‌اند.

### 13 Track مستقل
- AI-01 — Product / Game Direction
- AI-02 — Core Simulation / Systems Architecture
- AI-03 — Puzzle Design / Level & Content Logic
- AI-04 — Gameplay / Camera / Touch / Interaction
- AI-05 — Environment Art / World / Materials / Lighting
- AI-06 — Characters / Creatures / Animation / VFX
- AI-07 — UI/UX / Motion / Accessibility
- AI-08 — Audio / Music / Adaptive Sound
- AI-09 — Narrative / Lore / Localization
- AI-10 — QA / Automation / Quality Engineering
- AI-11 — Performance / Android / Device Optimization
- AI-12 — Build / CI/CD / Release / Store
- AI-13 — Integration / Technical Production / Architecture Governance

### سه لایه مشترک
1. **Contracts/Governance:** interface, event, schema, save schema, content IDs, asset IDs
2. **Integration:** merge queue، compatibility checks، nightly build، vertical-slice assembly
3. **Quality:** automated tests + device QA + human playtest gates

## فازهای اصلی

### v7 cross-cutting rule
## v7.1 world-class cross-cutting layer

Before any phase closes, verify the additional safeguards in `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` and `01_PREPRODUCTION/CRAFTCUBE_WORLDCLASS_CONTENT_RULES.md`. Story, quest, item, equipment, economy, analytics/privacy, competitive integrity, localization, accessibility and remote-content safety are treated as production concerns from the beginning—not as post-launch patches.

The first production slice must prove: puzzle fun, puzzle→world causality, narrative curiosity, memorable character/companion interaction, meaningful equipment choice, one upgrade decision, one discovery, persistent world memory, save/recovery, comfort/accessibility, and Android performance.

Story, world-memory, item/equipment, discovery, companion and progression foundations begin early and remain parallelizable through mocks/stubs. They must not be postponed to late content production.

### Phase 0 — Product/IP Lock
خروجی: scope نهایی، مسیر IP، مخاطب، platform, product principles، naming، core fantasy، story premise، three-act outline، item/equipment philosophy، discovery philosophy، cut list.
گیت: هویت بازی، هویت داستان، نقش تجهیزات، مرزهای IP و معیارهای ارزش محصول روشن باشند.

### Phase 1 — Contract & Architecture Freeze
خروجی: folder ownership، interfaces، schemas، events، coding conventions، data schemas، performance budgets، narrative/world/item/equipment contracts، save-state requirements.
گیت: همه Trackها بتوانند بدون یکدیگر build stub کنند و وابستگی‌های story/world/item/puzzle نسخه‌دار باشند.

### Phase 2 — Foundation / Project Bootstrap
خروجی: Unity project، package baseline، URP baseline، Android build، CI smoke build.
گیت: clean clone → successful build.

### Phase 3 — Core Simulation MVP
خروجی: puzzle topology، permutations، moves، scramble، undo/redo، deterministic replay، world-state hooks، item/reward state hooks، save-domain foundations.
گیت: unit coverage/property tests برای هسته و state transitions.

### Phase 4 — Presentation & Input
خروجی: cube renderer، touch gestures، camera، animation timing، ghost preview، haptics.
گیت: کنترل‌ها طبیعی و بدون accidental input.

### Phase 5 — Game Loop Systems
خروجی: Vitality/Bloom/Collapse، special tiles، companion framework، assist levels، pulse/trail، first narrative event, first item acquisition/equip flow, first discovery flow.
گیت: core story→puzzle→world→reward loop کامل و قابل بازی.

### Phase 6 — Vertical Slice Gold
خروجی: یک chapter با کیفیت نهایی شامل gameplay + art + UI + VFX + audio + onboarding + story beat + meaningful item/equipment + companion reaction + discovery + persistent world consequence.
گیت: بازیکن در یک نشست کوتاه باید رابطه Puzzle→World→Story را درک کند؛ آیتم‌ها باید عمق بدهند نه منوی اضافی.

### Phase 7 — Content Authoring Pipeline
خروجی: Biome/Creature/Chapter tools، previewer، validators، content schemas.
گیت: طراح محتوا بدون تغییر کد بتواند محتوای جدید بسازد.

### Phase 8 — Content Production A
خروجی: Chapters 2–4، difficulty curve، new biome mechanics، collection growth.
گیت: content complete برای بخش A.

### Phase 9 — Meta / Narrative / Collection
خروجی: narrative arc expansion، Guardian Garden/collection، item/equipment progression، upgrades، discoveries، achievements، world memory.
گیت: meta، story، items و collection بدون grind یا menu overload ارزشمند باشند.

### Phase 10 — Content Production B
خروجی: Chapters 5–10 یا roadmap-ready modular packs، بسته به scope نهایی.
گیت: همه محتوا با pipeline یکسان validate شده باشد.

### Phase 11 — UX Polish / Accessibility / Save
خروجی: tutorial refinement، onboarding، settings، accessibility، local save، migration.
گیت: save corruption test + recovery test + accessibility audit.

### Phase 12 — Performance & Device Lab
خروجی: profiling، batching، memory، thermal، battery، low-end fallback.
گیت پیشنهادی: 60 FPS target mid-tier؛ 30 FPS safe mode؛ no blocking spikes.

### Phase 13 — Services / Optional Online
خروجی: daily seed، leaderboard، remote config، analytics با حداقل‌گرایی حریم خصوصی.
گیت: بازی core بدون اینترنت باید قابل بازی بماند مگر feature صریحاً online باشد.

### Phase 14 — Monetization / Store Package
خروجی: monetization یا premium model، store screenshots، icon، legal texts، privacy pages، localization.
گیت: monetization نباید core experience را خراب کند.

### Phase 15 — Closed Alpha / Soft Launch
خروجی: device cohort، telemetry، bug triage، onboarding metrics، economy tuning.
گیت: crash/ANR و retention و qualitative feedback در محدوده‌ی قابل‌قبول تیم.

### Phase 16 — Release Candidate
خروجی: signed APK + signed AAB، release notes، versioning، rollback artifact، store upload package.
گیت: صفر blocker/critical؛ تمامی automated suites green.

### Phase 17 — Launch & Post-Launch
خروجی: staged rollout، hotfix lane، event pipeline، content cadence، post-launch analytics.
گیت: release monitoring و rollback آماده باشد.

## وابستگی‌ها
فقط قراردادها و integration gateها blocking هستند؛ implementation Trackها تا جای ممکن با Stub/Mock موازی‌اند.

مثال:
- AI-02 قرارداد `IPuzzleEngine` را با version 1.0 freeze می‌کند.
- AI-03 بدون منتظر ماندن برای implementation نهایی، Adapter و FakeEngine خودش را می‌سازد.
- AI-05 UI را با Sample State JSON می‌سازد.
- AI-07 تست‌ها را با deterministic fixtures اجرا می‌کند.
- بعد از آماده شدن implementation، فقط Adapter و fixture swap می‌شوند.

## Definition of Done کلی
- همه قابلیت‌ها مستند و testable.
- تمام assets دارای source/license metadata.
- هیچ asset یا کدی خارج از مالکیت بدون قرارداد وارد branch نمی‌شود.
- Build reproducible است.
- Save migration تست شده است.
- Performance budget ثبت و اندازه‌گیری شده.
- release artifact hash و manifest دارد.
