//------------------------------------------
// PolyDiceGenerator v0.27.5 - Modular Edition
//   A customizable Polyhedral Dice Generator for OpenSCAD.
//   https://github.com/charmaur/PolyDiceGenerator
//   Please support PolyDiceGenerator https://ko-fi.com/charmaur
//
// Requirements
//   OpenSCAD http://www.openscad.org
//   BOSL2 library https://github.com/revarbat/BOSL2
//      included with PolyDiceGenerator
//
// PolyDiceGenerator and the included BOSL2 library
//   are licensed under the BSD 2-Clause License
//------------------------------------------

echo(pdg_version="0.27.5-modular");

// BOSL2 Library includes
include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>
echo(bosl_version=bosl_version_str());
bosl_required("2.0.716");

// Configuration includes
include <src/config/rendering.scad>
include <src/config/fonts.scad>
include <src/config/global_settings.scad>
include <src/config/dice_selection.scad>

// Library includes
include <src/lib/utilities.scad>
include <src/lib/die_base.scad>
include <src/lib/pip_drawing.scad>
include <src/lib/layout_manager.scad>

// Dice module includes
include <src/dice/d2_coin.scad>
include <src/dice/d3_triangular.scad>
include <src/dice/d4_tetrahedron.scad>
include <src/dice/d4c_crystal.scad>
include <src/dice/d4i_infinite.scad>
include <src/dice/d4p_pentagonal.scad>
include <src/dice/d6_cube.scad>
include <src/dice/d8_octahedron.scad>
include <src/dice/d10_pentagonal.scad>
include <src/dice/d00_percentile.scad>
include <src/dice/d12_dodecahedron.scad>
include <src/dice/d12r_rhombic.scad>
include <src/dice/d16_hexadecimal.scad>
include <src/dice/d20_icosahedron.scad>

//------------------------------------------
// Main Rendering Section
//------------------------------------------

// Render all selected dice in standard layout
standard_dice_layout(
    d2, d3, d4, d4c, d4i, d4p,
    d6, d8, d10, d00, d12, d12r,
    d16, d20
) {
    if (d2) draw_d2();
    if (d3) draw_d3();
    if (d4c) draw_d4c();
    if (d4) draw_d4();
    if (d6) draw_d6();
    if (d10) draw_d10();
    if (d4i) draw_d4i();
    if (d8) draw_d8();
    if (d12) draw_d12();
    if (d4p) draw_d4p();
    if (d12r) draw_d12r();
    if (d20) draw_d20();
    if (d00) draw_d00();
    if (d16) draw_d16();
}

// Alternative: Use compact layout
// compact_dice_layout([d2, d3, d4, d4c, d4i, d4p, d6, d8, d10, d00, d12, d12r, d16, d20]) {
//     if (d2) draw_d2();
//     // ... additional dice
// }

// Alternative: Custom layout with explicit positions
// custom_dice_layout([
//     [0, 0, 0],      // d2 position
//     [-40, 0, 0],    // d3 position
//     [40, 0, 0],     // d4 position
//     // ... additional positions
// ]) {
//     if (d2) draw_d2();
//     // ... additional dice
// }