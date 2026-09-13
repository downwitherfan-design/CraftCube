#!/usr/bin/env python3
"""AI-13 governance validator for CraftCube integration artifacts.

Deterministic, dependency-free (stdlib only). Exit code 0 = all gates pass.

Checks
  1. registry/contract_registry.json parses and matches its declared schema.
  2. Every contract ID matches the declared id_format and is unique.
  3. Every alias is unique across the registry and never equal to an ID.
  4. owner / governance / consumers reference known accounts.
  5. status is in status_vocabulary; a consumable status requires a version.
  6. RISK-/CR-/OD- IDs referenced anywhere in 11_INTEGRATION/ are defined
     exactly once in RISK_REGISTER.md / CHANGE_REQUESTS.md /
     PHASE00_INTEGRATION_GATE.md respectively, and are numbered without gaps.
  7. --render regenerates CONTRACT_REGISTRY.md from the JSON and --check-render
     fails if the committed markdown is stale.

Usage
  python3 11_INTEGRATION/scripts/validate_registry.py
  python3 11_INTEGRATION/scripts/validate_registry.py --render
  python3 11_INTEGRATION/scripts/validate_registry.py --check-render
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "registry" / "contract_registry.json"
RENDERED = ROOT / "CONTRACT_REGISTRY.md"
ID_SOURCES = {
    "RISK": ROOT / "RISK_REGISTER.md",
    "CR": ROOT / "CHANGE_REQUESTS.md",
    "OD": ROOT / "PHASE00_INTEGRATION_GATE.md",
}
DEFINITION_RE = {
    "RISK": re.compile(r"^###\s+(RISK-\d{4})\b", re.M),
    "CR": re.compile(r"^###\s+(CR-\d{4})\b", re.M),
    "OD": re.compile(r"^###\s+(OD-\d{4})\b", re.M),
}
REFERENCE_RE = re.compile(r"\b(RISK|CR|OD)-(\d{4})\b")

RENDER_HEADER = (
    "# Contract Registry (rendered view)\n\n"
    "**GENERATED FILE — do not hand-edit.** Source of truth: "
    "`11_INTEGRATION/registry/contract_registry.json`. Regenerate with "
    "`python3 11_INTEGRATION/scripts/validate_registry.py --render`.\n\n"
)


class Failure(Exception):
    pass


def load_registry() -> dict:
    try:
        data = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise Failure(f"registry unreadable: {exc}") from exc
    for key in (
        "registry_schema_version", "registry_owner", "status_vocabulary",
        "consumable_statuses", "id_format", "accounts", "contracts",
    ):
        if key not in data:
            raise Failure(f"registry missing top-level key '{key}'")
    return data


def validate_contracts(data: dict, errors: list[str]) -> None:
    id_re = re.compile(data["id_format"])
    accounts = set(data["accounts"])
    statuses = set(data["status_vocabulary"])
    consumable = set(data["consumable_statuses"])
    seen_ids: dict[str, int] = {}
    seen_aliases: dict[str, str] = {}
    required = (
        "id", "display_name", "owner", "owner_evidence", "governance",
        "consumers", "status", "version", "aliases", "sources",
        "fixture_required", "freeze_target_phase",
    )
    for idx, c in enumerate(data["contracts"]):
        where = f"contracts[{idx}]"
        for key in required:
            if key not in c:
                errors.append(f"{where}: missing key '{key}'")
        cid = c.get("id", "")
        where = f"{cid or where}"
        if not id_re.match(cid):
            errors.append(f"{where}: id does not match {data['id_format']}")
        if cid in seen_ids:
            errors.append(f"{where}: duplicate id (also at index {seen_ids[cid]})")
        seen_ids[cid] = idx
        if c.get("owner") not in accounts:
            errors.append(f"{where}: owner '{c.get('owner')}' not a known account")
        if c.get("governance") != "AI-13":
            errors.append(f"{where}: governance must be AI-13")
        for consumer in c.get("consumers", []):
            if consumer not in accounts:
                errors.append(f"{where}: consumer '{consumer}' not a known account")
        if c.get("owner_evidence") not in {"VERIFIED", "INFERRED", "UNKNOWN"}:
            errors.append(f"{where}: owner_evidence must be VERIFIED/INFERRED/UNKNOWN")
        status = c.get("status")
        if status not in statuses:
            errors.append(f"{where}: status '{status}' not in vocabulary")
        if status in consumable and not c.get("version"):
            errors.append(f"{where}: status {status} requires a version")
        if status not in consumable and c.get("version") is not None:
            errors.append(f"{where}: DRAFT/DEPRECATED contract must not carry a version")
        if not c.get("sources"):
            errors.append(f"{where}: at least one source document is required")
        for src in c.get("sources", []):
            if not (ROOT.parent / src.split(" ")[0]).exists():
                errors.append(f"{where}: source path '{src}' does not exist")
        for alias in c.get("aliases", []):
            if alias in seen_aliases and seen_aliases[alias] != cid:
                errors.append(
                    f"{where}: alias '{alias}' already claimed by {seen_aliases[alias]}"
                )
            seen_aliases[alias] = cid
    for alias, owner_id in seen_aliases.items():
        if alias in seen_ids and alias != owner_id:
            errors.append(f"alias '{alias}' of {owner_id} collides with a contract id")


def collect_governance_ids(errors: list[str]) -> None:
    defined: dict[str, set[str]] = {k: set() for k in ID_SOURCES}
    for prefix, path in ID_SOURCES.items():
        if not path.exists():
            errors.append(f"{path.name}: missing (defines {prefix}-nnnn IDs)")
            continue
        text = path.read_text(encoding="utf-8")
        found = DEFINITION_RE[prefix].findall(text)
        for fid in found:
            if fid in defined[prefix]:
                errors.append(f"{path.name}: {fid} defined more than once")
            defined[prefix].add(fid)
        numbers = sorted(int(f.split("-")[1]) for f in defined[prefix])
        if numbers and numbers != list(range(1, len(numbers) + 1)):
            errors.append(f"{path.name}: {prefix} numbering has gaps or does not start at 0001: {numbers}")
    referenced: dict[str, set[str]] = {k: set() for k in ID_SOURCES}
    for path in sorted(ROOT.rglob("*")):
        if path.is_dir() or path.suffix not in {".md", ".json", ".py", ".txt"}:
            continue
        if path.name == "validate_registry.py":
            continue
        # evidence/ holds captured command output (including deliberately invalid
        # IDs used in negative tests); it is not a governance artifact.
        if "evidence" in path.relative_to(ROOT).parts:
            continue
        for prefix, num in REFERENCE_RE.findall(path.read_text(encoding="utf-8", errors="replace")):
            referenced[prefix].add(f"{prefix}-{num}")
    for prefix in ID_SOURCES:
        for rid in sorted(referenced[prefix] - defined[prefix]):
            errors.append(f"{rid} is referenced but never defined in {ID_SOURCES[prefix].name}")


def render(data: dict) -> str:
    rows = [RENDER_HEADER]
    rows.append(
        f"Registry schema `{data['registry_schema_version']}` · owner `{data['registry_owner']}` · "
        f"phase `{data.get('phase')}` · baseline `{data.get('baseline_commit')}` · "
        f"{len(data['contracts'])} contracts · statuses consumable by downstream tracks: "
        + ", ".join(f"`{s}`" for s in data["consumable_statuses"])
        + "\n\n"
    )
    rows.append("## Contracts\n\n")
    rows.append("| ID | Display name | Owner | Evidence | Consumers | Status | Version | Freeze target | Aliases | Linked CR/OD |\n")
    rows.append("|---|---|---|---|---|---|---|---|---|---|\n")
    for c in sorted(data["contracts"], key=lambda x: x["id"]):
        links = ", ".join(v for v in (c.get("change_request"), c.get("open_decision")) if v) or "—"
        consumers = ", ".join(c["consumers"]) if c["consumers"] else "UNKNOWN"
        rows.append(
            f"| `{c['id']}` | {c['display_name']} | {c['owner']} | {c['owner_evidence']} | {consumers} | "
            f"{c['status']} | {c['version'] or '—'} | Phase {c['freeze_target_phase']} | "
            f"{', '.join(c['aliases']) or '—'} | {links} |\n"
        )
    notes = [c for c in sorted(data["contracts"], key=lambda x: x["id"]) if c.get("note") or c.get("protected_rule")]
    if notes:
        rows.append("\n## Notes and protected rules\n\n")
        for c in notes:
            rows.append(f"### `{c['id']}`\n")
            if c.get("protected_rule"):
                rows.append(f"- Protected rule: {c['protected_rule']}\n")
            if c.get("note"):
                rows.append(f"- Note: {c['note']}\n")
            rows.append("\n")
    if data.get("unregistered_families"):
        rows.append("## Contract families named in policy docs but not yet registered\n\n")
        rows.append("| Family | Proposed owner | Evidence | Action |\n|---|---|---|---|\n")
        for u in data["unregistered_families"]:
            rows.append(
                f"| {u['family']} | {u['proposed_owner'] or 'UNKNOWN'} | {u['owner_evidence']} | {u['action']} |\n"
            )
    rows.append("\n## Alias policy\n\n")
    rows.append(
        "Three overlapping contract vocabularies exist on the baseline "
        "(`V7_MASTER_CONTRACT_REGISTER.md` PascalCase families, `NARRATIVE_ITEM_CONTRACTS.md` "
        "`CC.*` IDs, `PROGRESS.md` baseline names). The `CC.<DOMAIN>.<NAME>` form is canonical "
        "because it already existed and is machine-safe. Every other name is an alias of exactly "
        "one canonical ID. Aliases are for human lookup only and must never appear in code, "
        "schemas, save data or events.\n"
    )
    rows.append("\n## Notes from source\n\n")
    for n in data.get("notes", []):
        rows.append(f"- {n}\n")
    return "".join(rows)


def main(argv: list[str]) -> int:
    errors: list[str] = []
    try:
        data = load_registry()
    except Failure as exc:
        print(f"FAIL: {exc}")
        return 2
    validate_contracts(data, errors)
    collect_governance_ids(errors)

    if "--render" in argv:
        RENDERED.write_text(render(data), encoding="utf-8")
        print(f"rendered {RENDERED.relative_to(ROOT.parent)}")
    if "--check-render" in argv:
        if not RENDERED.exists() or RENDERED.read_text(encoding="utf-8") != render(data):
            errors.append("CONTRACT_REGISTRY.md is stale; run --render")

    if errors:
        print(f"FAIL ({len(errors)} finding(s)):")
        for e in errors:
            print(f"  - {e}")
        return 1
    print(
        f"PASS: {len(data['contracts'])} contracts, "
        f"{sum(1 for c in data['contracts'] if c['status'] == 'DRAFT')} DRAFT, "
        f"{sum(1 for c in data['contracts'] if c['status'] in data['consumable_statuses'])} consumable; "
        "governance IDs consistent."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
