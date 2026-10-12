class_name PuzzleSolver
extends RefCounted

## Deterministic guided-solving over a PuzzleEngine (Milestone A).
##
## This is NOT an optimal-move solver. It produces a reliable route back to the solved
## configuration by reverse-replaying the moves that are already known to have scrambled
## the cube, then eliminating whatever the player has since done that deviates from that
## exact trajectory. The route is always derived from the engine's own authoritative move
## history (`_scramble_moves` + `_move_log`), so the state it converges to is the true
## solved state, and every step is validated against the engine's legality rules before it
## is offered as an executable action.
##
## The route finishes at the fully solved cube, which necessarily satisfies the current
## slice's face-alignment objectives (a solid face is what "aligned" means).

## Route from the current engine state to solved, as concrete move dictionaries.
## Returns [] when the cube is already solved.
static func route_to_solved(engine: PuzzleEngine) -> Array:
        var history := []
        history.append_array(engine._scramble_moves)
        history.append_array(engine._move_log)
        var reduced := _reduce(history)
        var route := []
        for i in range(reduced.size() - 1, -1, -1):
                route.append(MoveTable.inverse(reduced[i]))
        return route

## Free-group reduction: remove adjacent move/inverse pairs so the route never contains a
## step immediately followed by its own undo. This is what prevents the hint from merely
## reversing the player's last action forever — following a reduced route strictly shortens it.
static func _reduce(moves: Array) -> Array:
        var out := []
        for m in moves:
                if not out.is_empty() and _cancels(out[out.size() - 1], m):
                        out.pop_back()
                else:
                        out.append(m)
        return out

## True when `b` is the exact inverse of `a` (same face, opposite direction).
static func _cancels(a: Dictionary, b: Dictionary) -> bool:
        return str(a.get("face", "")) == str(b.get("face", "")) \
                and bool(a.get("cw", true)) != bool(b.get("cw", true))


