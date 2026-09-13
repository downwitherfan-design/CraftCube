#!/usr/bin/env python3
"""Negative/positive tests for validate_phase00_content.py (stdlib unittest, deterministic).

Each negative test copies the good fixtures into a temp dir, injects exactly one design-rule violation, and asserts
the validator reports it. This proves the validator enforces the rules in phase_00/*.md rather than merely passing.

Run:  python3 -m unittest tracks/ai-03-puzzle-content/validators/test_validate_phase00_content.py -v
"""
from __future__ import annotations

import copy
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import validate_phase00_content as v  # noqa: E402

GOOD = HERE.parent / "fixtures" / "phase00"
FILES = ["chapters.draft.json", "levels.slice.draft.json", "rewards.draft.json", "discoveries.draft.json"]


class FixtureCase(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="ai03_p00_"))
        for f in FILES:
            shutil.copy(GOOD / f, self.tmp / f)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def mutate(self, fname: str, fn) -> None:
        p = self.tmp / fname
        doc = json.loads(p.read_text(encoding="utf-8"))
        fn(doc)
        p.write_text(json.dumps(doc), encoding="utf-8")

    def assert_error(self, needle: str) -> None:
        rep = v.run(self.tmp)
        joined = "\n".join(rep.errors)
        self.assertIn(needle, joined, msg=f"expected an error containing {needle!r}; got:\n{joined}")

    # ---------------- positive ----------------
    def test_good_fixtures_pass(self) -> None:
        rep = v.run(GOOD)
        self.assertEqual(rep.errors, [], "\n".join(rep.errors))
        self.assertEqual(rep.metrics["chapters"], 7)
        self.assertEqual(rep.metrics["levels"], 6)
        self.assertEqual(rep.metrics["rewards"], 9)
        self.assertEqual(rep.metrics["discoveries"], 4)
        self.assertEqual(rep.metrics["reachability_unverified"], 6, "Phase 00 must not claim reachability")

    def test_validator_is_deterministic(self) -> None:
        a = v.run(GOOD)
        b = v.run(GOOD)
        self.assertEqual((a.errors, a.warnings, a.metrics), (b.errors, b.warnings, b.metrics))

    # ---------------- envelope ----------------
    def test_released_status_rejected_in_phase00(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d.__setitem__("status", "RELEASED"))
        self.assert_error("status must be DRAFT")

    # ---------------- chapter rules ----------------
    def test_r1_reintroducing_existing_element(self) -> None:
        def fn(d):
            d["chapters"][3]["signature"]["introduces"]["tile_types"] = ["tile.anchor"]  # ch.04 re-introduces ch.02's tile
        self.mutate("chapters.draft.json", fn)
        self.assert_error("R1 violated - re-introduces")

    def test_r1_chapter_introduces_nothing(self) -> None:
        def fn(d):
            d["chapters"][4]["signature"]["introduces"] = {"objective_families": [], "tile_types": [], "level_rules": [], "topologies": []}
        self.mutate("chapters.draft.json", fn)
        self.assert_error("R1 violated - chapter introduces nothing new")

    def test_r2_consecutive_identical_pair(self) -> None:
        def fn(d):
            # make ch.05 identical in (family, signature) to ch.04 by copying ch.04 and removing ch.05's own novelty
            d["chapters"][4]["primary_family"] = d["chapters"][3]["primary_family"]
            d["chapters"][4]["signature"]["introduces"] = copy.deepcopy(d["chapters"][3]["signature"]["introduces"])
        self.mutate("chapters.draft.json", fn)
        # this also trips R1 (re-introduce); assert R2 message specifically is present too
        self.assert_error("R2 violated")

    def test_r3_recombines_unknown(self) -> None:
        self.mutate("chapters.draft.json", lambda d: d["chapters"][1]["signature"].__setitem__("recombines", ["tile.veiled"]))
        self.assert_error("R3 violated - recombines 'tile.veiled'")

    def test_r4_two_new_families(self) -> None:
        self.mutate("chapters.draft.json", lambda d: d["chapters"][4]["signature"]["introduces"].__setitem__("objective_families", ["objective.sequence", "objective.plan"]))
        self.assert_error("R4 violated - introduces 2 objective families")

    def test_duplicate_chapter_id(self) -> None:
        self.mutate("chapters.draft.json", lambda d: d["chapters"][1].__setitem__("chapter_id", d["chapters"][0]["chapter_id"]))
        self.assert_error("DUPLICATE chapter_id")

    # ---------------- level grammar ----------------
    def test_tile_used_before_introduced(self) -> None:
        def fn(d):
            lv = d["levels"][1]  # level.01.seed_bed (chapter 01)
            lv["tile_placement"].append({"tile_type": "tile.veiled", "home_face": "U", "home_index": 1})
        self.mutate("levels.slice.draft.json", fn)
        self.assert_error("uses tile.veiled before any chapter")

    def test_family_used_before_introduced(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0]["objective"].__setitem__("family", "objective.compose"))
        self.assert_error("uses objective.compose before any chapter")

    def test_missing_standard_challenge(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0].__setitem__("challenge_conditions", [{"condition_id": "challenge.time", "params": {}}]))
        self.assert_error("challenge.standard must always be present")

    def test_t0_with_pressure_condition(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0]["challenge_conditions"].append({"condition_id": "challenge.time", "params": {"time_budget_ms": 1}}))
        self.assert_error("T0 (Teach) level must not carry pressure conditions")

    def test_protected_mastery_with_relaxable_rule(self) -> None:
        def fn(d):
            span = next(l for l in d["levels"] if l["level_id"] == "level.02.span")
            span["level_rules"][0]["relaxable"] = True
        self.mutate("levels.slice.draft.json", fn)
        self.assert_error("protected_mastery level cannot have relaxable rules")

    def test_fabricated_reachability_rejected(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0].__setitem__("reachability_verified", True))
        self.assert_error("do not fabricate evidence")

    def test_all_axes_locked(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0]["level_rules"][0]["params"].__setitem__("axes", ["X", "Y", "Z"]))
        self.assert_error("locks all three axes")

    def test_layer_lock_without_anchor(self) -> None:
        def fn(d):
            lv = next(l for l in d["levels"] if l["level_id"] == "level.02.first_anchor")
            lv["tile_placement"] = [{"tile_type": "tile.seed", "home_face": "U", "home_index": 0}]
        self.mutate("levels.slice.draft.json", fn)
        self.assert_error("rule.layer_lock requires at least one tile.anchor")

    def test_embedded_text_instead_of_loc_key(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0].__setitem__("title_key", "First Light"))
        self.assert_error("must be a LocalizationKey name starting with 'loc.'")

    def test_chapter_not_opening_with_t0(self) -> None:
        self.mutate("levels.slice.draft.json", lambda d: d["levels"][0].__setitem__("tier", "T1"))
        self.assert_error("chapter must open with a T0")

    def test_duplicate_level_tuple(self) -> None:
        def fn(d):
            clone = copy.deepcopy(d["levels"][0])
            clone["level_id"] = "level.01.awaken_copy"
            clone["ordinal"] = 4
            clone["tier"] = "T2"
            d["levels"].insert(3, clone)
        self.mutate("levels.slice.draft.json", fn)
        self.assert_error("identical (objective, rules, tiles, scramble) tuple")

    # ---------------- rewards ----------------
    def test_dd006_protected_reward_gated_by_mastery(self) -> None:
        def fn(d):
            rw = next(r for r in d["rewards"] if r["reward_id"] == "reward.02.path_restored")
            rw["reward_condition"] = {"condition_id": "challenge.move_efficiency", "params": {"tolerance": 2}}
        self.mutate("rewards.draft.json", fn)
        self.assert_error("DD-006 violated")

    def test_idempotent_constant(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d["rewards"][0].__setitem__("idempotent", False))
        self.assert_error("idempotent must be the constant true")

    def test_resource_class_forbidden(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d["rewards"][3].__setitem__("reward_class", "reward_class.resource"))
        self.assert_error("reward_class.resource is not permitted in Phase 00")

    def test_invented_cross_track_id_rejected(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d["rewards"][0]["payload_ref"].__setitem__("ref", "world.event.mechanism_awakens"))
        self.assert_error("must be PLACEHOLDER:")

    def test_reward_condition_not_on_level(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d["rewards"][0].__setitem__("reward_condition", {"condition_id": "challenge.time", "params": {}}))
        self.assert_error("is not declared on level")

    def test_orphan_reward(self) -> None:
        def fn(d):
            clone = copy.deepcopy(d["rewards"][0])
            clone["reward_id"] = "reward.01.orphan"
            d["rewards"].append(clone)
        self.mutate("rewards.draft.json", fn)
        self.assert_error("not referenced by any level's reward_refs (orphan)")

    def test_duplicate_reward_id(self) -> None:
        self.mutate("rewards.draft.json", lambda d: d["rewards"][1].__setitem__("reward_id", d["rewards"][0]["reward_id"]))
        self.assert_error("DUPLICATE reward_id")

    # ---------------- discoveries ----------------
    def test_blocks_progression_constant(self) -> None:
        self.mutate("discoveries.draft.json", lambda d: d["discoveries"][0].__setitem__("blocks_progression", True))
        self.assert_error("blocks_progression must be the constant false")

    def test_discovery_trigger_tile_not_placed(self) -> None:
        def fn(d):
            x = next(i for i in d["discoveries"] if i["discovery_id"] == "discovery.02.under_span")
            x["trigger_condition"]["params"]["tile_type"] = "tile.resonant"
        self.mutate("discoveries.draft.json", fn)
        self.assert_error("trigger requires tile.resonant but level level.02.span places none")

    def test_unknown_discovery_category(self) -> None:
        self.mutate("discoveries.draft.json", lambda d: d["discoveries"][0].__setitem__("category", "loot_drop"))
        self.assert_error("unknown category 'loot_drop'")

    def test_level_references_undefined_discovery(self) -> None:
        self.mutate("discoveries.draft.json", lambda d: d["discoveries"].pop(0))
        self.assert_error("level references undefined discovery")

    # ---------------- load errors ----------------
    def test_missing_fixture_is_exit_2(self) -> None:
        (self.tmp / "rewards.draft.json").unlink()
        rc = v.main(["--fixtures", str(self.tmp), "--json"])
        self.assertEqual(rc, 2)

    def test_invalid_json_is_exit_2(self) -> None:
        (self.tmp / "levels.slice.draft.json").write_text("{not json", encoding="utf-8")
        rc = v.main(["--fixtures", str(self.tmp), "--json"])
        self.assertEqual(rc, 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
