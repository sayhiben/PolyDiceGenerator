// Pip drawing functions for dice with pip-style faces
// Used for d4c, d4i, and d6 dice types

include <../config/fonts.scad>
include <../config/global_settings.scad>

// Draw circular pips on a die face
module draw_pips(die_type, pip_number, adj_depth, pip_fn, die_params) {
    pip_size = die_params[0];
    pip_offset = die_params[1];
    pip_mult = pip_size / 100;
    pipr = pip_mult / 2;
    
    if (pip_number == "1") {
        down(text_depth + adj_depth) 
            cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
    }
    if (pip_number == "2") {
        translate([-pipr * pip_offset, pipr * pip_offset, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
        translate([pipr * pip_offset, -pipr * pip_offset, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
    }
    if (pip_number == "3") {
        draw_pips(die_type, "1", adj_depth, pip_fn, die_params);
        draw_pips(die_type, "2", adj_depth, pip_fn, die_params);
    }
    if (pip_number == "4") {
        draw_pips(die_type, "2", adj_depth, pip_fn, die_params);
        translate([pipr * pip_offset, pipr * pip_offset, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
        translate([-pipr * pip_offset, -pipr * pip_offset, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
    }
    if (pip_number == "5" && die_type == "d6") {
        draw_pips(die_type, "1", adj_depth, pip_fn, die_params);
        draw_pips(die_type, "4", adj_depth, pip_fn, die_params);
    }
    if (pip_number == "6" && die_type == "d6") {
        draw_pips(die_type, "4", adj_depth, pip_fn, die_params);
        translate([pipr * pip_offset, 0, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
        translate([-pipr * pip_offset, 0, 0])
            down(text_depth + adj_depth) 
                cylinder(r = pipr, h = 2 * text_depth + adj_depth, $fn = pip_fn);
    }
}

// Draw symbol-based pips on a die face
module draw_pip_symbols(die_type, pip_number, pip_symbol, rotation, adj_depth, die_params) {
    pip_size = die_params[0];
    pip_offset = die_params[1];
    pip_mult = pip_size / 100;
    sym_stroke = symbol_stroke * pip_mult;
    pipr = pip_mult / 2;
    
    if (pip_number == "1") {
        zrot(rotation) down(text_depth + adj_depth) 
            linear_extrude(height = 2 * text_depth + adj_depth)
                offset(delta = sym_stroke)
                    text(pip_symbol, size = pip_mult, font = symbol_font, 
                         halign = "center", valign = "center");
    }
    if (pip_number == "2") {
        translate([-pipr * pip_offset, pipr * pip_offset, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
        translate([pipr * pip_offset, -pipr * pip_offset, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
    }
    if (pip_number == "3") {
        draw_pip_symbols(die_type, "1", pip_symbol, rotation, adj_depth, die_params);
        draw_pip_symbols(die_type, "2", pip_symbol, rotation, adj_depth, die_params);
    }
    if (pip_number == "4") {
        draw_pip_symbols(die_type, "2", pip_symbol, rotation, adj_depth, die_params);
        translate([pipr * pip_offset, pipr * pip_offset, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
        translate([-pipr * pip_offset, -pipr * pip_offset, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
    }
    if (pip_number == "5" && die_type == "d6") {
        draw_pip_symbols(die_type, "1", pip_symbol, rotation, adj_depth, die_params);
        draw_pip_symbols(die_type, "4", pip_symbol, rotation, adj_depth, die_params);
    }
    if (pip_number == "6" && die_type == "d6") {
        draw_pip_symbols(die_type, "4", pip_symbol, rotation, adj_depth, die_params);
        translate([pipr * pip_offset, 0, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
        translate([-pipr * pip_offset, 0, 0])
            zrot(rotation) down(text_depth + adj_depth) 
                linear_extrude(height = 2 * text_depth + adj_depth)
                    offset(delta = sym_stroke)
                        text(pip_symbol, size = pip_mult, font = symbol_font, 
                             halign = "center", valign = "center");
    }
}