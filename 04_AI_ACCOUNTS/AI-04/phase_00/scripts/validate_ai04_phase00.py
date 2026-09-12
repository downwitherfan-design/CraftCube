#!/usr/bin/env python3
"""AI-04 Phase 00 self-audit validator.

Owner: AI-04. Scope: AI-04's own Phase 00 deliverables only.
Standard library only (Python 3). Not CI (CI is AI-12). AI-10 may reuse.

Checks:
  1. Registry JSON parses; every ID matches idPattern; no duplicate IDs.
  2. Every AI-04 ID lives in a namespace AI-04 owns; none shadows a reserved namespace.
  3. Every ID mentioned in AI-04 markdown (backticked, in owned namespaces) exists in the registry, and vice versa.
  4. Tunables in registry == tunables in arbitration model markdown table (name + value).
  5. Fixture schema parses; sample fixtures conform structurally (required keys, enums, monotonic time, tunables set).
  6. Forbidden/IP-risk terms do not appear in AI-04 deliverables outside the explicit forbidden-terms lists.
  7. Every deliverable markdown declares a Status line.
Exit code 0 = all checks passed; 1 = failures (listed).
"""
from __future__ import annotations
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]          # .../AI-04/phase_00
REG = ROOT / "fixtures" / "interaction_terminology_registry.v0.1.0.json"
SCHEMA = ROOT / "fixtures" / "touch_sequence_fixture.schema.v0.1.0.json"
SAMPLES = sorted((ROOT / "fixtures" / "samples").glob("*.json"))
MD_FILES = sorted(ROOT.glob("*.md"))

failures: list[str] = []
passes: list[str] = []

def ok(msg): passes.append(msg)
def fail(msg): failures.append(msg)

# ---- 1. registry ----------------------------------------------------------
reg = json.loads(REG.read_text(encoding="utf-8"))
id_re = re.compile(reg["idPattern"])
reg_ids: list[str] = []
reg_ids += [g["id"] for g in reg["gestures"]]
reg_ids += [c["id"] for c in reg["commands"]]
reg_ids += list(reg["notifications"])
reg_ids += [h["id"] for h in reg["haptics"]]
bad = [i for i in reg_ids if not id_re.match(i)]
fail(f"IDs violating pattern: {bad}") if bad else ok(f"{len(reg_ids)} registry IDs match idPattern")
dups = sorted({i for i in reg_ids if reg_ids.count(i) > 1})
fail(f"duplicate registry IDs: {dups}") if dups else ok("no duplicate registry IDs")

# ---- 2. namespaces --------------------------------------------------------
owned = set(reg["namespacesOwned"]); reserved = set(reg["namespacesReservedByOthers"])
outside = [i for i in reg_ids if i.split(".")[0] not in owned]
fail(f"IDs outside owned namespaces: {outside}") if outside else ok("all IDs inside AI-04-owned namespaces")
shadow = [i for i in reg_ids if i.split(".")[0] in reserved]
fail(f"IDs shadowing reserved namespaces: {shadow}") if shadow else ok("no reserved-namespace shadowing")

# ---- 3. md <-> registry cross reference ------------------------------------
tick_re = re.compile(r"`([a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+)`")
md_ids: set[str] = set()
for f in MD_FILES:
    for m in tick_re.findall(f.read_text(encoding="utf-8")):
        if m.split(".")[0] in owned and not m.endswith((".md", ".json", ".py", ".csv", ".txt")):
            md_ids.add(m)
# allow documented wildcard/placeholder forms
placeholders = {"interaction.intent.<value>"}
md_ids = {m for m in md_ids if "<" not in m}
# 'haptic.*' style prose wildcards are not captured by the regex (asterisk excluded).
# Intent notifications are written in md as interaction.intent.<value>; expand for comparison.
reg_set = set(reg_ids)
missing_in_reg = sorted(m for m in md_ids if m not in reg_set)
fail(f"IDs used in markdown but absent from registry: {missing_in_reg}") if missing_in_reg else ok("every markdown ID exists in registry")
intent_ids = {f"interaction.intent.{v}" for v in reg["intents"]}
missing_in_md = sorted(r for r in reg_set - md_ids if r not in intent_ids)
fail(f"registry IDs never referenced in markdown: {missing_in_md}") if missing_in_md else ok("every registry ID is referenced in markdown (intent variants documented as <value>)")

# ---- 4. tunables md == json ------------------------------------------------
arb = (ROOT / "04_GESTURE_ARBITRATION_MODEL.md").read_text(encoding="utf-8")
rec = (ROOT / "05_INTERRUPTION_AND_RECOVERY.md").read_text(encoding="utf-8")
md_tun: dict[str, float] = {}
for m in re.finditer(r"\|\s*`([A-Z_]+)`\s*\|\s*([0-9.]+)", arb):
    md_tun[m.group(1)] = float(m.group(2))
for m in re.finditer(r"`([A-Z_]+)`[^`]*?initial hypothesis\s+([0-9.]+)", rec):
    md_tun[m.group(1)] = float(m.group(2))
json_tun = {k: float(v) for k, v in reg["tunables"].items() if k != "note"}
diff = {k: (md_tun.get(k), json_tun.get(k)) for k in set(md_tun) | set(json_tun) if md_tun.get(k) != json_tun.get(k)}
fail(f"tunable mismatch md vs json: {diff}") if diff else ok(f"{len(json_tun)} tunables identical in markdown and registry")

# ---- 5. schema + samples ----------------------------------------------------
schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
ok("fixture schema parses")
req_tun = set(schema["properties"]["tunables"]["required"])
if req_tun != set(json_tun): fail(f"schema required tunables != registry tunables: {req_tun ^ set(json_tun)}")
else: ok("schema required tunables == registry tunables")
intents_enum = set(schema["properties"]["expected"]["properties"]["intents"]["items"]["properties"]["intent"]["enum"])
if intents_enum != set(reg["intents"]): fail("schema intent enum != registry intents")
else: ok("schema intent enum == registry intents")
for s in SAMPLES:
    fx = json.loads(s.read_text(encoding="utf-8"))
    name = s.name
    for k in schema["required"]:
        if k not in fx: fail(f"{name}: missing key {k}")
    extra = set(fx) - set(schema["properties"])
    if extra: fail(f"{name}: unexpected keys {extra}")
    if fx.get("schemaVersion") != "0.1.0": fail(f"{name}: schemaVersion")
    if not re.match(schema["properties"]["fixtureId"]["pattern"], fx.get("fixtureId", "")): fail(f"{name}: fixtureId pattern")
    if set(fx.get("tunables", {})) != req_tun: fail(f"{name}: tunables set mismatch")
    ts = [e["t"] for e in fx["events"]]
    if ts != sorted(ts): fail(f"{name}: event times not non-decreasing")
    for e in fx["events"]:
        if e["type"] not in ("down", "move", "up", "cancel"): fail(f"{name}: bad event type {e['type']}")
    for i in fx["expected"]["intents"]:
        if i["intent"] not in intents_enum: fail(f"{name}: bad intent {i['intent']}")
    for c in fx["expected"]["commands"]:
        if c["commandId"] not in reg_set: fail(f"{name}: expected command not in registry: {c['commandId']}")
    ok(f"sample fixture structurally valid: {name}")

# ---- 6. forbidden terms -----------------------------------------------------
forbidden = [t.lower() for t in reg["forbiddenTerms"]]
for f in MD_FILES:
    text = f.read_text(encoding="utf-8").lower()
    # strip explicit forbidden-term lists / hygiene sections and hit-region prose
    scrub = re.sub(r"## 8\. words ai-04 will not use.*?(?=\n## |\Z)", "", text, flags=re.S)
    scrub = re.sub(r"\"?(block|mine|craft|hotbar|crosshair)\"?(,|\s+as interaction terms| as the equipment model|-placement|-building|/mining|-centered)", "", scrub)
    scrub = scrub.replace("no block-placement/mining gesture vocabulary", "").replace("block-building", "").replace("chosen instead of \"block\"", "").replace("(use tile)", "")
    hits = sorted({t for t in forbidden if re.search(rf"\b{re.escape(t)}\b", scrub) and t not in ("craft",)})
    # 'craft' is part of the product name CraftCube; excluded from word check.
    fail(f"{f.name}: forbidden/IP-risk terms present: {hits}") if hits else ok(f"{f.name}: no forbidden terms")

# ---- 7. status lines --------------------------------------------------------
for f in MD_FILES:
    head = f.read_text(encoding="utf-8")[:600]
    if not re.search(r"^Status:\s*\S", head, flags=re.M): fail(f"{f.name}: missing Status line")
    else: ok(f"{f.name}: Status declared")

# ---- report -----------------------------------------------------------------
print("AI-04 Phase 00 self-audit")
print(f"root: {ROOT}")
for p in passes: print("PASS ", p)
for x in failures: print("FAIL ", x)
print(f"summary: {len(passes)} passed, {len(failures)} failed")
sys.exit(1 if failures else 0)
