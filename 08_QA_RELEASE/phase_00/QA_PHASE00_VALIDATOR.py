#!/usr/bin/env python3
"""AI-10 Phase 00 — QA artifact validator.

Validates the QA-owned Phase 00 artifacts in 08_QA_RELEASE/phase_00/ so they
cannot silently drift from each other or from the product documents they trace.

Checks (deterministic, stdlib only, no network, read-only):
  A. Traceability register (QA_PHASE00_TRACEABILITY_REGISTER.json)
     A1 JSON parses; required top-level keys present.
     A2 Every item has all required fields; enum values valid; owners known.
     A3 QAT IDs unique, match ^QAT-[0-9]{3}$, contiguous from 001.
     A4 Every contractPrerequisite is a known contract family AND that family
        name appears in 06_CONTRACTS/*.md (no invented contracts).
     A5 Every sourceId referenced by an item is declared in sourceBaseline.
     A6 Status/method consistency (BLOCKED_ON_CONTRACT requires >= 1 contract;
        EXECUTABLE_NOW requires none; PLAYTEST items require a fixtureRequirement).
     A7 coverage.pdCovered / f10Covered / igmCovered are actually referenced by
        >= 1 item's traces, and no item traces a PD/F10/IGM outside the declared
        covered/not-testable sets.
  B. Traceability matrix markdown (QA_PHASE00_TRACEABILITY_MATRIX.md)
     B1 Every QAT in the register appears in the matrix and vice versa.
  C. Terminology rules (QA_IP_TERMINOLOGY_RULES.json)
     C1 Parses; QAR IDs unique and well-formed; scopes/severities consistent.
     C2 Scan: IDENTIFIER-scope files for affirmative rejected terms -> FAIL;
        DESIGN_DOC-scope files -> INFO listing only (human review).
        PLAYER_FACING_STRING scope reports SCOPE_EMPTY when no files match.
  D. Playtest session record schema + MOCK fixture
     D1 Schema parses; fixture validates against the schema (subset checker).
     D2 Fixture is explicitly labelled as MOCK and buildId == "UNKNOWN".
     D3 Privacy: schema has no field whose name suggests personal data.
  E. Product-document cross-check (only if the AI-01 documents are present in
     this checkout; otherwise reports SOURCE_NOT_PRESENT — never a pass).
     E1 Every PD/F10/IGM ID referenced by the register exists in the source doc.
     E2 Every PD acceptance-criterion bullet carries a method tag
        ([VALIDATOR]/[BUILD]/[PLAYTEST]/[EVIDENCE]) -> otherwise finding (QAT-031).
     E3 Source document version equals the version recorded in sourceBaseline.
  F. Self-test: negative cases on in-memory copies prove the checks can fail.

Exit code 0 = all FAIL-level checks passed; 1 = one or more FAIL findings.
INFO findings never change the exit code. Output lines are prefixed with a
stable token ([PASS]/[FAIL]/[INFO]/[SKIP]) for grepping in CI logs.

Usage (from repository root):
    python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py
    python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py --no-selftest
"""
from __future__ import annotations

import copy
import fnmatch
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
QA_DIR = REPO_ROOT / "08_QA_RELEASE" / "phase_00"
REGISTER = QA_DIR / "QA_PHASE00_TRACEABILITY_REGISTER.json"
MATRIX_MD = QA_DIR / "QA_PHASE00_TRACEABILITY_MATRIX.md"
TERM_RULES = QA_DIR / "QA_IP_TERMINOLOGY_RULES.json"
SESSION_SCHEMA = QA_DIR / "fixtures" / "playtest_session_record.schema.json"
SESSION_MOCK = QA_DIR / "fixtures" / "MOCK_playtest_session_record_v0.json"
CONTRACTS_DIR = REPO_ROOT / "06_CONTRACTS"
PRODUCT_DIR = REPO_ROOT / "01_PREPRODUCTION" / "PRODUCT"

REQUIRED_TOP = ["registerId", "registerVersion", "status", "owner", "phase", "sourceBaseline",
                "enums", "contractFamilies", "knownAccounts", "idPolicy", "items", "coverage"]
REQUIRED_ITEM = ["id", "title", "traces", "sourceIds", "criterionText", "method", "priority",
                 "earliestPhase", "contractPrerequisites", "fixtureRequirement", "fixOwner",
                 "status", "notes"]
QAT_RE = re.compile(r"^QAT-[0-9]{3}$")
QAR_RE = re.compile(r"^QAR-[0-9]{3}$")
TRACE_ID_RE = re.compile(r"^(PD|F10|IGM|CUT)-[0-9]{3}[a-z]?$")
PII_HINTS = ["name", "email", "phone", "address", "ip", "imei", "advertisingid", "deviceid",
             "birth", "age", "gender", "location", "gps", "quote", "transcript"]
PII_ALLOWED = {"sessionid", "buildid"}  # pseudonymous by construction; documented in schema.

findings: list[tuple[str, str]] = []  # (level, message)


def emit(level: str, msg: str) -> None:
    findings.append((level, msg))
    print(f"[{level}] {msg}")


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        emit("FAIL", f"{path.relative_to(REPO_ROOT)}: file missing")
    except json.JSONDecodeError as exc:
        emit("FAIL", f"{path.relative_to(REPO_ROOT)}: invalid JSON ({exc})")
    return None


# --------------------------------------------------------------------------- A
def check_register(reg: dict, label: str = "register") -> list[str]:
    """Return list of FAIL messages (so the self-test can assert on them)."""
    fails: list[str] = []
    for key in REQUIRED_TOP:
        if key not in reg:
            fails.append(f"A1 {label}: missing top-level key '{key}'")
    if fails:
        return fails

    enums = reg["enums"]
    accounts = set(reg["knownAccounts"])
    families = set(reg["contractFamilies"])
    source_ids = {s["sourceId"] for s in reg["sourceBaseline"]["sources"]}
    items = reg["items"]

    # A2 / A3
    ids = []
    for it in items:
        for f in REQUIRED_ITEM:
            if f not in it:
                fails.append(f"A2 {label}: {it.get('id','?')} missing field '{f}'")
        iid = it.get("id", "")
        ids.append(iid)
        if not QAT_RE.match(iid):
            fails.append(f"A3 {label}: bad id '{iid}'")
        if it.get("method") not in enums["method"]:
            fails.append(f"A2 {label}: {iid} invalid method '{it.get('method')}'")
        if it.get("priority") not in enums["priority"]:
            fails.append(f"A2 {label}: {iid} invalid priority '{it.get('priority')}'")
        if it.get("earliestPhase") not in enums["earliestPhase"]:
            fails.append(f"A2 {label}: {iid} invalid earliestPhase '{it.get('earliestPhase')}'")
        if it.get("status") not in enums["status"]:
            fails.append(f"A2 {label}: {iid} invalid status '{it.get('status')}'")
        if it.get("fixOwner") not in accounts:
            fails.append(f"A2 {label}: {iid} unknown fixOwner '{it.get('fixOwner')}'")
        if not it.get("traces"):
            fails.append(f"A2 {label}: {iid} has no traces")
        # A4
        for fam in it.get("contractPrerequisites", []):
            if fam not in families:
                fails.append(f"A4 {label}: {iid} references unknown contract family '{fam}'")
        # A5
        for sid in it.get("sourceIds", []):
            if sid not in source_ids:
                fails.append(f"A5 {label}: {iid} references undeclared sourceId '{sid}'")
        # A6
        st = it.get("status")
        if st == "BLOCKED_ON_CONTRACT" and not it.get("contractPrerequisites"):
            fails.append(f"A6 {label}: {iid} BLOCKED_ON_CONTRACT but no contract prerequisites")
        if st == "EXECUTABLE_NOW" and it.get("contractPrerequisites"):
            fails.append(f"A6 {label}: {iid} EXECUTABLE_NOW but lists contract prerequisites")
        if it.get("method") == "PLAYTEST" and not it.get("fixtureRequirement"):
            fails.append(f"A6 {label}: {iid} PLAYTEST item without fixtureRequirement")

    if len(ids) != len(set(ids)):
        dup = sorted({i for i in ids if ids.count(i) > 1})
        fails.append(f"A3 {label}: duplicate ids {dup}")
    expected = [f"QAT-{n:03d}" for n in range(1, len(ids) + 1)]
    if sorted(ids) != expected:
        fails.append(f"A3 {label}: ids are not contiguous QAT-001..QAT-{len(ids):03d}")

    # A4b: contract family names must appear in 06_CONTRACTS/*.md
    contract_text = ""
    if CONTRACTS_DIR.is_dir():
        for p in sorted(CONTRACTS_DIR.glob("*.md")):
            contract_text += p.read_text(encoding="utf-8")
    for fam in sorted(families):
        if fam not in contract_text:
            fails.append(f"A4 {label}: contract family '{fam}' not found in 06_CONTRACTS/*.md")

    # A7 coverage consistency
    traced = {t for it in items for t in it.get("traces", []) if TRACE_ID_RE.match(t)}
    cov = reg["coverage"]
    declared = (set(cov.get("pdCovered", [])) | set(cov.get("f10Covered", [])) |
                set(cov.get("igmCovered", [])))
    not_testable = set(cov.get("pdNotTestable", {})) | set(cov.get("igmNotTestable", {}))
    for d in sorted(declared):
        if d not in traced:
            fails.append(f"A7 {label}: coverage declares {d} but no item traces it")
    for t in sorted(traced):
        if t.startswith("CUT-"):
            continue  # CUT items are enforced structurally; not part of coverage claim
        if t not in declared and t not in not_testable:
            fails.append(f"A7 {label}: item traces {t} which is neither covered nor declared not-testable")
    for nt in sorted(not_testable):
        if nt in declared:
            fails.append(f"A7 {label}: {nt} is both covered and not-testable")
    return fails


# --------------------------------------------------------------------------- B
def check_matrix(reg: dict) -> list[str]:
    fails: list[str] = []
    if not MATRIX_MD.exists():
        return [f"B1 matrix markdown missing: {MATRIX_MD.relative_to(REPO_ROOT)}"]
    text = MATRIX_MD.read_text(encoding="utf-8")
    in_md = set(re.findall(r"\bQAT-[0-9]{3}\b", text))
    in_reg = {it["id"] for it in reg["items"]}
    for missing in sorted(in_reg - in_md):
        fails.append(f"B1 matrix: {missing} present in register but absent from markdown")
    for extra in sorted(in_md - in_reg):
        fails.append(f"B1 matrix: {extra} present in markdown but absent from register")
    ver = re.search(r"registerVersion[`\s|:]*([0-9]+\.[0-9]+\.[0-9]+)", text)
    if not ver or ver.group(1) != reg["registerVersion"]:
        fails.append(f"B1 matrix: registerVersion in markdown != {reg['registerVersion']}")
    return fails


# --------------------------------------------------------------------------- C
def _globs_match(rel: str, globs: list[str]) -> bool:
    return any(fnmatch.fnmatch(rel, g) or fnmatch.fnmatch(rel, g.replace("**/", "")) for g in globs)


def _term_regex(term: str, mode: str) -> re.Pattern:
    esc = re.escape(term)
    if mode in ("word", "phrase"):
        return re.compile(rf"(?<![A-Za-z0-9_]){esc}(?![A-Za-z0-9_])", re.IGNORECASE)
    return re.compile(esc, re.IGNORECASE)


def check_term_rules(rules: dict) -> tuple[list[str], list[str]]:
    fails: list[str] = []
    infos: list[str] = []
    ids = [r["id"] for r in rules.get("rules", [])]
    if len(ids) != len(set(ids)):
        fails.append("C1 term rules: duplicate QAR ids")
    for r in rules.get("rules", []):
        if not QAR_RE.match(r["id"]):
            fails.append(f"C1 term rules: bad id {r['id']}")
        if r.get("matchMode") not in ("word", "phrase", "substring"):
            fails.append(f"C1 term rules: {r['id']} bad matchMode")
        if not r.get("terms"):
            fails.append(f"C1 term rules: {r['id']} has no terms")
    for scope in rules.get("scopes", {}):
        if scope not in rules.get("severityByScope", {}):
            fails.append(f"C1 term rules: scope {scope} has no severity")

    # C2 scan
    own_prefix = "08_QA_RELEASE/phase_00/"
    all_files = [p for p in REPO_ROOT.rglob("*") if p.is_file() and ".git" not in p.parts]
    for scope_name, scope in rules["scopes"].items():
        severity = rules["severityByScope"][scope_name]
        matched_files = 0
        for p in all_files:
            rel = p.relative_to(REPO_ROOT).as_posix()
            if not _globs_match(rel, scope["pathGlobs"]):
                continue
            if _globs_match(rel, scope.get("excludePathGlobs", [])):
                continue
            if scope_name == "IDENTIFIER" and rel.startswith(own_prefix):
                continue  # QA's own rule/register files quote the terms by design
            matched_files += 1
            try:
                text = p.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            for rule in rules["rules"]:
                for term in rule["terms"]:
                    rx = _term_regex(term, rule["matchMode"])
                    for m in rx.finditer(text):
                        line_no = text.count("\n", 0, m.start()) + 1
                        msg = f"C2 {scope_name} {rule['id']} '{term}' in {rel}:{line_no}"
                        if severity == "FAIL":
                            fails.append(msg)
                        else:
                            infos.append(msg)
        if matched_files == 0:
            infos.append(f"C2 {scope_name}: SCOPE_EMPTY (no files match yet)")
    return fails, infos


# --------------------------------------------------------------------------- D
class SchemaError(Exception):
    pass


def validate_subset(instance, schema, root, path="$") -> list[str]:
    """Minimal JSON-Schema subset: $ref(#/$defs), type, const, enum, required,
    properties, additionalProperties(false), pattern, minimum, maximum,
    maxLength, items, uniqueItems."""
    errs: list[str] = []
    if "$ref" in schema:
        ref = schema["$ref"]
        if not ref.startswith("#/$defs/"):
            return [f"{path}: unsupported $ref {ref}"]
        schema = root["$defs"][ref[len("#/$defs/"):]]
    typ = schema.get("type")
    if typ is not None:
        types = typ if isinstance(typ, list) else [typ]
        ok = False
        for t in types:
            if t == "null" and instance is None: ok = True
            elif t == "object" and isinstance(instance, dict): ok = True
            elif t == "array" and isinstance(instance, list): ok = True
            elif t == "string" and isinstance(instance, str): ok = True
            elif t == "integer" and isinstance(instance, int) and not isinstance(instance, bool): ok = True
            elif t == "number" and isinstance(instance, (int, float)) and not isinstance(instance, bool): ok = True
            elif t == "boolean" and isinstance(instance, bool): ok = True
        if not ok:
            return [f"{path}: expected type {types}, got {type(instance).__name__}"]
    if instance is None:
        return errs
    if "const" in schema and instance != schema["const"]:
        errs.append(f"{path}: expected const {schema['const']!r}")
    if "enum" in schema and instance not in schema["enum"]:
        errs.append(f"{path}: {instance!r} not in enum")
    if isinstance(instance, str):
        if "pattern" in schema and not re.search(schema["pattern"], instance):
            errs.append(f"{path}: {instance!r} does not match {schema['pattern']}")
        if "maxLength" in schema and len(instance) > schema["maxLength"]:
            errs.append(f"{path}: string longer than {schema['maxLength']}")
    if isinstance(instance, (int, float)) and not isinstance(instance, bool):
        if "minimum" in schema and instance < schema["minimum"]:
            errs.append(f"{path}: {instance} < minimum {schema['minimum']}")
        if "maximum" in schema and instance > schema["maximum"]:
            errs.append(f"{path}: {instance} > maximum {schema['maximum']}")
    if isinstance(instance, dict):
        props = schema.get("properties", {})
        for req in schema.get("required", []):
            if req not in instance:
                errs.append(f"{path}: missing required '{req}'")
        for k, v in instance.items():
            if k in props:
                errs += validate_subset(v, props[k], root, f"{path}.{k}")
            elif schema.get("additionalProperties") is False and not k.startswith("_"):
                errs.append(f"{path}: additional property '{k}' not allowed")
    if isinstance(instance, list):
        if schema.get("uniqueItems") and len(instance) != len({json.dumps(i, sort_keys=True) for i in instance}):
            errs.append(f"{path}: items not unique")
        if "items" in schema:
            for i, v in enumerate(instance):
                errs += validate_subset(v, schema["items"], root, f"{path}[{i}]")
    return errs


def check_session_fixture(schema: dict, fixture: dict) -> list[str]:
    fails: list[str] = []
    errs = validate_subset(fixture, schema, schema)
    fails += [f"D1 fixture: {e}" for e in errs]
    try:  # optional cross-check with a full implementation when available
        import jsonschema  # type: ignore
        inst = {k: v for k, v in fixture.items() if not k.startswith("_")}
        try:
            jsonschema.validate(inst, schema)
        except jsonschema.ValidationError as exc:  # pragma: no cover
            fails.append(f"D1 fixture (jsonschema cross-check): {exc.message}")
    except ImportError:
        pass
    if "_MOCK" not in fixture or "MOCK" not in str(fixture.get("_MOCK", "")):
        fails.append("D2 fixture: not labelled as _MOCK")
    if fixture.get("buildId") != "UNKNOWN":
        fails.append("D2 fixture: MOCK fixture must not claim a real buildId")
    return fails


def check_schema_privacy(schema: dict) -> list[str]:
    fails: list[str] = []

    def tokens(name: str) -> set[str]:
        # split camelCase and snake_case into lower-case word tokens
        parts = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name).replace("_", " ").lower().split()
        joined = {"".join(parts)}
        return set(parts) | joined

    def walk(node, path):
        if isinstance(node, dict):
            for k, v in node.get("properties", {}).items():
                if k.lower() not in PII_ALLOWED and tokens(k) & set(PII_HINTS):
                    fails.append(f"D3 schema: field '{path}.{k}' looks like personal data")
                walk(v, f"{path}.{k}")
            for sub in ("items",):
                if sub in node:
                    walk(node[sub], path)
    walk(schema, "$")
    return fails


# --------------------------------------------------------------------------- E
def check_product_docs(reg: dict) -> tuple[list[str], list[str], list[str]]:
    fails: list[str] = []
    infos: list[str] = []
    skips: list[str] = []
    traced = {t for it in reg["items"] for t in it["traces"] if TRACE_ID_RE.match(t)}
    for src in reg["sourceBaseline"]["sources"]:
        path = REPO_ROOT / src["path"]
        if not path.exists():
            skips.append(f"E SOURCE_NOT_PRESENT {src['sourceId']} ({src['path']}) — expected on branch "
                         f"{src['branch']}@{src['commit']}; cross-check not performed")
            continue
        text = path.read_text(encoding="utf-8")
        # E3 version
        if src.get("version") and src.get("documentId"):
            m = re.search(r"\|\s*Version\s*\|\s*([0-9]+\.[0-9]+\.[0-9]+)\s*\|", text)
            if not m:
                infos.append(f"E3 {src['sourceId']}: version table row not found")
            elif m.group(1) != src["version"]:
                fails.append(f"E3 {src['sourceId']}: document version {m.group(1)} != baseline {src['version']}")
        # E1 IDs
        prefix = {"SRC-PD": "PD", "SRC-F10": "F10", "SRC-IGM": "IGM", "SRC-CUT": "CUT"}.get(src["sourceId"])
        if prefix:
            defined = set(re.findall(rf"\b{prefix}-[0-9]{{3}}[a-z]?\b", text))
            for t in sorted(traced):
                if t.startswith(prefix + "-") and t not in defined:
                    fails.append(f"E1 {src['sourceId']}: register traces {t} which is not defined in the document")
        # E2 method tags on PD acceptance criteria
        if src["sourceId"] == "SRC-PD":
            in_ac = False
            current = None
            for ln in text.splitlines():
                h = re.match(r"^## (PD-[0-9]{3})", ln)
                if h:
                    current, in_ac = h.group(1), False
                if ln.strip().startswith("**Acceptance criteria"):
                    in_ac = True
                    continue
                if in_ac and ln.startswith("- "):
                    if not re.search(r"`\[(VALIDATOR|BUILD|PLAYTEST|EVIDENCE)\]`", ln):
                        infos.append(f"E2 {current}: acceptance bullet without method tag -> {ln[:70]}")
                elif in_ac and ln.strip() and not ln.startswith("- "):
                    in_ac = False
    return fails, infos, skips


# --------------------------------------------------------------------------- F
def selftest(reg: dict, schema: dict, fixture: dict) -> list[str]:
    """Negative cases on in-memory copies. Returns FAIL messages if a check
    that should have failed did not."""
    problems: list[str] = []

    def expect_fail(name, fails_list):
        if not fails_list:
            problems.append(f"F selftest '{name}' did not produce a failure")

    r = copy.deepcopy(reg); r["items"][0]["id"] = r["items"][1]["id"]
    expect_fail("duplicate QAT id", check_register(r, "selftest"))
    r = copy.deepcopy(reg); r["items"][0]["contractPrerequisites"] = ["InventedContract"]
    expect_fail("invented contract family", check_register(r, "selftest"))
    r = copy.deepcopy(reg); r["items"][0]["fixOwner"] = "AI-99"
    expect_fail("unknown owner", check_register(r, "selftest"))
    r = copy.deepcopy(reg); r["items"][0]["sourceIds"] = ["SRC-NOPE"]
    expect_fail("undeclared sourceId", check_register(r, "selftest"))
    r = copy.deepcopy(reg); r["items"][0]["traces"] = ["PD-999"]
    expect_fail("uncovered trace", check_register(r, "selftest"))
    r = copy.deepcopy(reg); r["items"][0]["status"] = "EXECUTABLE_NOW"; r["items"][0]["contractPrerequisites"] = ["SaveSchema"]
    expect_fail("status/contract inconsistency", check_register(r, "selftest"))
    r = copy.deepcopy(reg); del r["items"][0]["fixtureRequirement"]
    expect_fail("missing item field", check_register(r, "selftest"))

    f = copy.deepcopy(fixture); f["exitAnswers"]["q9_solveOwnership"] = "ROBOT"
    expect_fail("fixture bad enum", validate_subset(f, schema, schema))
    f = copy.deepcopy(fixture); f["interruption"]["atMs"] = 10
    expect_fail("fixture interruption outside 2:00-6:00", validate_subset(f, schema, schema))
    f = copy.deepcopy(fixture); f["participantName"] = "x"
    expect_fail("fixture additional property", validate_subset(f, schema, schema))
    f = copy.deepcopy(fixture); del f["continuation"]
    expect_fail("fixture missing required", validate_subset(f, schema, schema))
    f = copy.deepcopy(fixture); f["buildId"] = "cc-1.0.0-build42"
    expect_fail("mock claiming real build", check_session_fixture(schema, f))

    s = copy.deepcopy(schema); s["properties"]["participantEmail"] = {"type": "string"}
    expect_fail("schema PII field", check_schema_privacy(s))

    rx = _term_regex("crafter", "phrase")
    if rx.search("CraftCube crafters unite"):
        problems.append("F selftest term regex matched inside 'CraftCube' / plural")
    if not rx.search("the crafter walks"):
        problems.append("F selftest term regex failed to match standalone word")
    return problems


# --------------------------------------------------------------------------- main
def main(argv: list[str]) -> int:
    run_selftest = "--no-selftest" not in argv
    print(f"QA Phase 00 validator — repo root {REPO_ROOT}")

    reg = load_json(REGISTER)
    rules = load_json(TERM_RULES)
    schema = load_json(SESSION_SCHEMA)
    fixture = load_json(SESSION_MOCK)
    if None in (reg, rules, schema, fixture):
        print("[FAIL] required artifact missing or unparsable; aborting")
        return 1

    # A
    a = check_register(reg)
    for m in a: emit("FAIL", m)
    if not a: emit("PASS", f"A register: {len(reg['items'])} items, ids contiguous, enums/owners/contracts/sources/coverage consistent")

    # B
    b = check_matrix(reg)
    for m in b: emit("FAIL", m)
    if not b: emit("PASS", "B matrix markdown in sync with register")

    # C
    c_f, c_i = check_term_rules(rules)
    for m in c_f: emit("FAIL", m)
    for m in c_i: emit("INFO", m)
    if not c_f: emit("PASS", f"C terminology: {len(rules['rules'])} rules; no affirmative rejected term in IDENTIFIER/PLAYER_FACING scopes ({len(c_i)} INFO lines for human review)")

    # D
    d = check_session_fixture(schema, fixture) + check_schema_privacy(schema)
    for m in d: emit("FAIL", m)
    if not d: emit("PASS", "D session schema/fixture: MOCK fixture validates; no personal-data fields")

    # E
    e_f, e_i, e_s = check_product_docs(reg)
    for m in e_s: emit("SKIP", m)
    for m in e_f: emit("FAIL", m)
    for m in e_i: emit("INFO", m)
    present = len(reg["sourceBaseline"]["sources"]) - len(e_s)
    if not e_f: emit("PASS", f"E product-doc cross-check: {present} source(s) present and consistent, {len(e_s)} not present in this checkout")

    # F
    if run_selftest:
        f = selftest(reg, schema, fixture)
        for m in f: emit("FAIL", m)
        if not f: emit("PASS", "F selftest: all 14 negative cases produced failures as expected")

    n_fail = sum(1 for lvl, _ in findings if lvl == "FAIL")
    n_info = sum(1 for lvl, _ in findings if lvl == "INFO")
    n_skip = sum(1 for lvl, _ in findings if lvl == "SKIP")
    print(f"SUMMARY fail={n_fail} info={n_info} skip={n_skip}")
    return 1 if n_fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
