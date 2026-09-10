# CraftCube — Parallel Phase Kickoff Procedure

برای شروع هر فاز:
1. نسخه فعلی `PROGRESS.md` و contract versions را ثبت کنید.
2. هشت branch مستقل را از integration baseline بگیرید.
3. هر AI فقط prompt مسیر خودش را اجرا کند.
4. در صورت نبود dependency، Mock/Stub/Fixture بسازید.
5. هر AI باید tests/evidence و handoff بدهد.
6. Integrator ابتدا contract checks و سپس targeted integration tests و در نهایت full integration build را اجرا کند.
7. در صورت conflict، به جای اصلاح مستقیم branch دیگری Change Request ایجاد شود.

### ترتیب Merge
- Contract/schema changes
- Core/domain
- Runtime adapters
- UI/UX
- Art/VFX
- Audio
- QA validation
- Build/release

این ترتیب به معنی blocking بودن توسعه نیست؛ فقط ترتیب امن integration است.
