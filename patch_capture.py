#!/usr/bin/env python3
"""Extend capture_frames.gd with EPIC 0.5 evidence: app shell screens and the 3x3 topology."""

p = "game/tests/capture_frames.gd"
s = open(p).read()

anchor = (
    '\t# Milestone D: the journal\'s equipment panel (item use loop).\n'
    '\tapp.game.game_state.grant_equipment("equipment.rootweave_gauntlet")\n'
    '\tapp._open_journal()\n'
    '\tawait _capture("session13_equipment.png")\n'
)
add = (
    '\t# Milestone D: the journal\'s equipment panel (item use loop).\n'
    '\tapp.game.game_state.grant_equipment("equipment.rootweave_gauntlet")\n'
    '\tapp._open_journal()\n'
    '\tawait _capture("session13_equipment.png")\n'
    '\t# EPIC 0.5 Milestone D: the application shell screens, to check readability and that the\n'
    '\t# opaque menu backdrop is correct (and hidden over gameplay).\n'
    '\tapp._open_title()\n'
    '\tawait _capture("session15_title.png")\n'
    '\tapp._open_map()\n'
    '\tawait _capture("session15_map.png")\n'
    '\tapp._open_settings()\n'
    '\tawait _capture("session15_settings.png")\n'
    '\t# EPIC 0.5 Milestone B: the newly exposed 3x3 topology (Chapter 01 levels 4-6), from a\n'
    '\t# fresh campaign so the rendered cube is the 3x3 state and its face mapping is checked.\n'
    '\tapp._play_level(3)\n'
    '\tawait _capture("session15_cube3x3.png")\n'
    '\tapp.game.camera.orbit(0.6, -0.15)\n'
    '\tfor _i in range(30):\n'
    '\t\tapp.game.camera._process(0.05)\n'
    '\tawait _capture("session15_cube3x3_orbit.png")\n'
)
assert anchor in s
s = s.replace(anchor, add)
open(p, "w").write(s)
print("capture harness extended")
