class_name CraftPalette
extends RefCounted

## Shared art direction - "The Living Mineral Garden" (EPIC 0.5, Milestones A/D).
##
## One restrained palette for the whole product so the world, the cube, the companion and the
## application chrome read as parts of one place. Everything is defined here and referenced by
## name; screens never hardcode a slightly different value of the same idea.
##
## A quiet, ancient mineral garden: dormant stone warms to amber/teal as the cube's laws
## restore structures and reveal traces of a vanished intelligence. Mysterious and tactile,
## not aggressive or overtly science-fictional.
##
## Readability rules baked into these values:
##   * dormant stone stays close to the background so lit structures clearly read as "restored";
##   * restored accents are emissive so they stay visible under low ambient light;
##   * the sky and ground never out-brighten the cube or an active world target.

# --- environment -------------------------------------------------------------------------
const SKY_TOP := Color(0.055, 0.07, 0.11)
const SKY_HORIZON := Color(0.14, 0.17, 0.22)
const SKY_GROUND := Color(0.07, 0.08, 0.1)
## Ambient fill - high enough that dormant stone is legible, low enough that emissive
## restoration and the cube face colours stay dominant.
const AMBIENT := Color(0.62, 0.66, 0.72)
const AMBIENT_ENERGY := 0.85
const SUN_COLOUR := Color(0.92, 0.9, 0.85)
const SUN_ENERGY := 1.05
const FILL_COLOUR := Color(0.45, 0.62, 0.85)
const FILL_ENERGY := 0.35

# --- mineral garden (world) --------------------------------------------------------------
const GROUND_BASE := Color(0.115, 0.13, 0.145)
const GROUND_GARDEN := Color(0.15, 0.165, 0.175)
const GROUND_RIM := Color(0.2, 0.22, 0.235)
const STONE_DORMANT := Color(0.185, 0.2, 0.215)
const STONE_DORMANT_CAP := Color(0.16, 0.17, 0.185)
const PATH_DORMANT := Color(0.17, 0.185, 0.2)
const PATH_RESTORED := Color(0.42, 0.72, 0.68)
const GROWTH_DORMANT := Color(0.2, 0.23, 0.21)
const GROWTH_LIVING := Color(0.36, 0.62, 0.4)
const GROUND_WARM := Color(0.24, 0.215, 0.165)

# --- revealed marks ----------------------------------------------------------------------
const MARK_GLOW := Color(0.52, 0.85, 0.95)
const MARK_STONE := Color(0.3, 0.33, 0.35)

# --- companion (Nox) ---------------------------------------------------------------------
const NOX_BODY := Color(0.5, 0.5, 0.58)
const NOX_GLOW := Color(0.62, 0.9, 1.0)

# --- restoration accents (one per ward / level) ------------------------------------------
const ACCENTS := [
	Color(0.45, 0.8, 0.95),  # 1 - cool "mechanism awakens"
	Color(0.52, 0.86, 0.55), # 2 - green "seed grows"
	Color(0.95, 0.76, 0.4),  # 3 - amber "stone marks awaken"
	Color(0.55, 0.72, 0.95), # 4 - "resonance deepens"
	Color(0.72, 0.6, 0.92),  # 5 - "paths converge"
	Color(0.95, 0.86, 0.58), # 6 - "chapter sealed"
]

# --- cube face colours -------------------------------------------------------------------
## Face order matches CubeState.Face: U D L R F B. Slightly deepened from pure web colours so
## the unshaded facelets read as painted material, with white kept clearly distinct.
const FACE_COLOURS := [
	Color(0.92, 0.93, 0.9),  # U - warm white
	Color(0.96, 0.78, 0.2),  # D - amber
	Color(0.22, 0.58, 0.92), # L - blue
	Color(0.3, 0.8, 0.42),   # R - green
	Color(0.9, 0.31, 0.29),  # F - red
	Color(0.97, 0.55, 0.22), # B - orange
]
const CUBE_BODY := Color(0.12, 0.13, 0.15)
const CUBE_EDGE := Color(0.06, 0.07, 0.08)

# --- application chrome (app.gd / HUD) ---------------------------------------------------
const UI_BG := Color(0.07, 0.08, 0.1)
const UI_CARD := Color(0.13, 0.15, 0.18)
const UI_CARD_DONE := Color(0.15, 0.21, 0.17)
const UI_CARD_LOCKED := Color(0.11, 0.12, 0.13)
const UI_ACCENT := Color(0.55, 0.85, 0.95)
const UI_MUTED := Color(0.62, 0.66, 0.7)
const UI_STAR := Color(0.98, 0.82, 0.35)

## Accent for a 0-based level index, clamped to the palette length.
static func accent_for(index: int) -> Color:
	if ACCENTS.is_empty():
		return UI_ACCENT
	return ACCENTS[clampi(index, 0, ACCENTS.size() - 1)]

## Emissive material for a restored element: the accent glows at a controlled fraction so a
## lit ward reads as "restored" without blooming over the cube.
static func restored_material(accent: Color, emission: float = 0.42) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = accent
	m.roughness = 0.6
	m.emission_enabled = true
	m.emission = accent * emission
	return m

## Dormant material: flat mineral stone with no emission.
static func dormant_material(base: Color = STONE_DORMANT) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = base
	m.roughness = 0.9
	return m
