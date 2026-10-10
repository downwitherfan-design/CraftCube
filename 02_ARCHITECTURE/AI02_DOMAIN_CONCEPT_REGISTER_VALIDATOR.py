#!/usr/bin/env python3
"""AI-02 Phase 00 — Domain Concept Register validator.

Validates 02_ARCHITECTURE/AI02_DOMAIN_CONCEPT_REGISTER_PHASE00.json against the
repository so that the register cannot silently drift from its sources.

Checks (all deterministic, stdlib only, no network):
  1. JSON parses and required top-level keys exist.
  2. Every concept has all required fields; enum values are valid.
  3. Concept keys are unique and follow the `concept.<segment>.<name>` policy.
  4. Every concept's boundedContext exists; every bounded context has >= 1 concept.
  5. stateOwner / meaningOwner are known accounts.
  6. Every contract family referenced by a bounded context is in knownContractFamilies,
     and every knownContractFamily string actually appears in 06_CONTRACTS/*.md.
  7. Every sourceFiles path exists in the repository.
  8. Every openItems reference on a concept is defined in the openItems map, and
     every defined open item (U-/C-/D-) is mentioned in the audit markdown.
  9. Every bullet in 10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md is covered by at least
     one concept's gddSource (exact bullet text).
 10. No Minecraft-specific proprietary terminology appears in concept keys
     (IP-safety rule from SOURCE_GDD_NOTES.md).

Exit code 0 = all checks passed; 1 = one or more findings. Findings are printed
with a stable prefix so they can be grepped in CI logs.

Usage (from repository root):
    python3 02_ARCHITECTURE/AI02_DOMAIN_CONCEPT_REGISTER_VALIDATOR.py
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
REGISTER = REPO_ROOT / "02_ARCHITECTURE" / "AI02_DOMAIN_CONCEPT_REGISTER_PHASE00.json"
AUDIT_MD = REPO_ROOT / "02_ARCHITECTURE" / "AI02_CORE_DOMAIN_BOUNDARY_AUDIT_PHASE00.md"
GDD_NOTES = REPO_ROOT / "10_SOURCE_REFERENCE" / "SOURCE_GDD_NOTES.md"
CONTRACTS_DIR = REPO_ROOT / "06_CONTRACTS"

REQUIRED_TOP = [
    "registerId", "registerVersion", "status", "owner", "phase", "enums",
    "boundedContexts", "knownContractFamilies", "concepts", "openItems",
]
REQUIRED_CONCEPT_FIELDS = [
    "key", "gddSource", "classification", "boundedContext", "stateOwner",
    "meaningOwner", "determinismClass", "persistenceClass", "evidence",
    "sourceFiles", "openItems",
]
KEY_PATTERN = re.compile(r"^concept\.[a-z_]+\.[a-z_]+$")
OPEN_ITEM_PATTERN = re.compile(r"^[UCD]-\d{2}$")

# Terms the domain must not carry (IP-safety; see SOURCE_GDD_NOTES.md).
# Kept generic and lower-case; matched against concept keys only.
FORBIDDEN_KEY_TERMS = ["minecraft", "creeper", "enderman", "redstone", "netherite", "steve"]

# Concepts whose gddSource legitimately does not map to a GDD bullet.
NON_GDD_SOURCE_LABELS = {"v7 addition", "v7.1 addition"}


class Findings:
    def __init__(self) -> None:
        self.items: list[str] = []

    def add(self, check: str, msg: str) -> None:
        self.items.append(f"FINDING [{check}] {msg}")

    def ok(self) -> bool:
        return not self.items


def load_register(f: Findings) -> dict | None:
    try:
        data = json.loads(REGISTER.read_text(encoding="utf-8"))
    except FileNotFoundError:
        f.add("C01-parse", f"register missing: {REGISTER}")
        return None
    except json.JSONDecodeError as exc:
        f.add("C01-parse", f"invalid JSON: {exc}")
        return None
    for key in REQUIRED_TOP:
        if key not in data:
            f.add("C01-parse", f"missing top-level key '{key}'")
    return data


def check_concepts(data: dict, f: Findings) -> None:
    enums = data["enums"]
    contexts = {c["id"] for c in data["boundedContexts"]}
    accounts = set(enums["accounts"])
    seen_keys: set[str] = set()
    context_usage = {cid: 0 for cid in contexts}

    for idx, concept in enumerate(data["concepts"]):
        label = concept.get("key", f"<index {idx}>")
        for field in REQUIRED_CONCEPT_FIELDS:
            if field not in concept:
                f.add("C02-fields", f"{label}: missing field '{field}'")
        key = concept.get("key", "")
        if not KEY_PATTERN.match(key):
            f.add("C03-keys", f"{label}: key violates policy concept.<segment>.<name>")
        if key in seen_keys:
            f.add("C03-keys", f"{label}: duplicate key")
        seen_keys.add(key)

        if concept.get("classification") not in enums["domainClassification"]:
            f.add("C02-enums", f"{label}: invalid classification '{concept.get('classification')}'")
        if concept.get("determinismClass") not in enums["determinismClass"]:
            f.add("C02-enums", f"{label}: invalid determinismClass '{concept.get('determinismClass')}'")
        if concept.get("persistenceClass") not in enums["persistenceClass"]:
            f.add("C02-enums", f"{label}: invalid persistenceClass '{concept.get('persistenceClass')}'")
        if concept.get("evidence") not in enums["evidenceLabel"]:
            f.add("C02-enums", f"{label}: invalid evidence label '{concept.get('evidence')}'")

        ctx = concept.get("boundedContext")
        if ctx not in contexts:
            f.add("C04-contexts", f"{label}: unknown boundedContext '{ctx}'")
        else:
            context_usage[ctx] += 1

        for owner_field in ("stateOwner", "meaningOwner"):
            if concept.get(owner_field) not in accounts:
                f.add("C05-owners", f"{label}: {owner_field} '{concept.get(owner_field)}' not a known account")

        for src in concept.get("sourceFiles", []):
            if not (REPO_ROOT / src).is_file():
                f.add("C07-sources", f"{label}: sourceFiles path does not exist: {src}")

        for item in concept.get("openItems", []):
            if not OPEN_ITEM_PATTERN.match(item):
                f.add("C08-openitems", f"{label}: malformed open item id '{item}'")
            elif item not in data["openItems"]:
                f.add("C08-openitems", f"{label}: open item '{item}' not defined in openItems map")

        lowered = key.lower()
        for term in FORBIDDEN_KEY_TERMS:
            if term in lowered:
                f.add("C10-ipsafety", f"{label}: forbidden proprietary term '{term}' in key")

    for cid, count in context_usage.items():
        if count == 0:
            f.add("C04-contexts", f"bounded context '{cid}' has no concepts")


def check_contract_families(data: dict, f: Findings) -> None:
    known = set(data["knownContractFamilies"]["families"])
    for ctx in data["boundedContexts"]:
        for fam in ctx.get("contractFamilies", []):
            if fam not in known:
                f.add("C06-contracts", f"bounded context '{ctx['id']}' references unknown contract family '{fam}'")

    contract_text = ""
    for md in sorted(CONTRACTS_DIR.glob("*.md")):
        contract_text += md.read_text(encoding="utf-8") + "\n"
    for fam in sorted(known):
        if fam not in contract_text:
            f.add("C06-contracts", f"knownContractFamily '{fam}' not found in any 06_CONTRACTS/*.md")


def check_open_items_in_audit(data: dict, f: Findings) -> None:
    try:
        audit = AUDIT_MD.read_text(encoding="utf-8")
    except FileNotFoundError:
        f.add("C08-openitems", f"audit markdown missing: {AUDIT_MD}")
        return
    for item_id in data["openItems"]:
        if not OPEN_ITEM_PATTERN.match(item_id):
            f.add("C08-openitems", f"openItems map has malformed id '{item_id}'")
        if item_id not in audit:
            f.add("C08-openitems", f"open item '{item_id}' defined in register but not mentioned in audit markdown")


def check_gdd_coverage(data: dict, f: Findings) -> list[str]:
    try:
        notes = GDD_NOTES.read_text(encoding="utf-8")
    except FileNotFoundError:
        f.add("C09-gdd", f"GDD notes missing: {GDD_NOTES}")
        return []
    bullets = [line[2:].strip() for line in notes.splitlines() if line.startswith("- ")]
    covered = {c["gddSource"] for c in data["concepts"]}
    for bullet in bullets:
        if bullet not in covered:
            f.add("C09-gdd", f"GDD bullet not covered by any concept: '{bullet}'")
    for src in covered:
        if src not in bullets and src not in NON_GDD_SOURCE_LABELS:
            f.add("C09-gdd", f"concept gddSource '{src}' matches neither a GDD bullet nor an allowed label")
    return bullets


def main() -> int:
    f = Findings()
    data = load_register(f)
    if data is None or not f.ok():
        for line in f.items:
            print(line)
        return 1

    check_concepts(data, f)
    check_contract_families(data, f)
    check_open_items_in_audit(data, f)
    bullets = check_gdd_coverage(data, f)

    print(f"register: {REGISTER.relative_to(REPO_ROOT)}")
    print(f"registerVersion: {data['registerVersion']}  status: {data['status']}  owner: {data['owner']}")
    print(f"boundedContexts: {len(data['boundedContexts'])}")
    print(f"concepts: {len(data['concepts'])}")
    print(f"knownContractFamilies: {len(data['knownContractFamilies']['families'])}")
    print(f"openItems: {len(data['openItems'])}")
    print(f"gddBulletsCovered: {len(bullets)}")

    if f.ok():
        print("RESULT: PASS (10 check groups, 0 findings)")
        return 0
    for line in f.items:
        print(line)
    print(f"RESULT: FAIL ({len(f.items)} findings)")
    return 1


if __name__ == "__main__":
    sys.exit(main())
