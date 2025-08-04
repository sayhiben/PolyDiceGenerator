// D6 Cube Die Module
// A customizable six-sided die with various options

include <../lib/utilities.scad>
include <../lib/pip_drawing.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D6 specific configuration parameters
d6_size = 15;
d6_text_size = 62;
d6_text_v_push = 0;
d6_text_h_push = 0;
d6_text = ["1", "2", "4", "5", "6", "3"];
d6_text_spacing = 1;
d6_symbols = [undef, undef, undef, undef, undef, undef];
d6_symbol_size = 62;
d6_symbol_v_push = 0;
d6_symbol_h_push = 0;
d6_underscores = [" ", " ", " ", " ", "_", " "];
d6_underscore_size = 48;
d6_underscore_v_push = -32;
d6_underscore_h_push = 0;
d6_rotate = [0, 0, 0, 0, 0, 0];
d6_angle_text = false;
d6_num_4_h_push = -3;
d6_bumpers = [false, true, true, false, false, true];
d6_adj_size = [0, 0, 0, 0, 0, 0];
d6_adj_v_push = [0, 0, 0, 0, 0, 0];
d6_adj_h_push = [0, 0, 0, 0, 0, 0];
d6_adj_depth = [0, 0, 0, 0, 0, 0];

// Pip-specific parameters
d6_pips = [" ", " ", " ", " ", " ", " "];
d6_pip_size = 20;
d6_pip_offset = 2.5;
d6_pip_sides = 6; //[0,3,4,5,6,8,10,12]
d6_pip_symbols = [undef, undef, undef, undef, undef, undef];
d6_pip_symbol_pos = ["1", "2", "4", "5", "6", "3"];
d6_pip_symbol_rotate = [0, 0, 0, 0, 0, 0];

// Main D6 drawing module
module draw_d6() {
    // Prepare text and symbols
    txt_merged = merge_txt(d6_text, fix_quotes(d6_symbols));
    txt_mult = d6_text_size * d6_size / 100;
    adj_txt = adj_list(d6_adj_size, d6_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d6_symbol_size * d6_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d6_bumpers);
    under_mult = d6_underscore_size * d6_size / 100;
    space_mult = d6_text_spacing > 1 ? (d6_text_spacing - 1) * txt_mult / 3.15 : 
                 d6_text_spacing < 1 ? (-1 + d6_text_spacing) * txt_mult / 2.8 : 0;
    rotate_mod = d6_angle_text ? 45 : 0;
    base_rotate = [0, -90, 90, 180, -90, 0];
    d6_pip_fn = d6_pip_sides == 0 ? 128 : d6_pip_sides;
    
    // Geometry calculations
    circumsphere_dia = d6_size * sqrt(3);
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.8;
    dual_mult = d6_size * (3 * sqrt(2) / 2);
    corner_clip_mult = dual_mult - (corner_clipping * dual_mult / 100) / 1.8;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("cube", side = d6_size, anchor = BOTTOM);
                regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("cube", side = d6_size, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d6_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d6_size / 2])
                        regular_polyhedron("octahedron", side = corner_clip_mult, 
                                         facedown = false);
                }
            }
        } else {
            // Standard cube with optional edge rounding
            regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d6_face_content();
    }
}

// Helper module to render face content
module render_d6_face_content() {
    // Prepare variables inside the module
    txt_merged = merge_txt(d6_text, fix_quotes(d6_symbols));
    txt_mult = d6_text_size * d6_size / 100;
    adj_txt = adj_list(d6_adj_size, d6_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d6_symbol_size * d6_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    under_mult = d6_underscore_size * d6_size / 100;
    rotate_mod = d6_angle_text ? 45 : 0;
    base_rotate = [0, -90, 90, 180, -90, 0];
    
    // Numbers and symbols
    regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, draw = false)
        zrot(d6_rotate[$faceindex] + base_rotate[$faceindex] + rotate_mod)
        down(text_depth + d6_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d6_adj_depth[$faceindex])
        move([
            (d6_text_h_push + d6_adj_h_push[$faceindex]) * d6_size / 100,
            (d6_text_v_push + d6_adj_v_push[$faceindex]) * d6_size / 100
        ])
        render_d6_face_text();
        
    // Underscores
    regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, draw = false)
        zrot(d6_rotate[$faceindex] + base_rotate[$faceindex] + rotate_mod)
        down(text_depth + d6_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d6_adj_depth[$faceindex])
        move([d6_underscore_h_push * d6_size / 100, d6_underscore_v_push * d6_size / 100])
        offset(delta = txt_stroke)
        text(d6_underscores[$faceindex], size = under_mult, font = underscore_font, 
             halign = "center", valign = "center");
        
    // Pips
    d6_pip_fn = d6_pip_sides == 0 ? 128 : d6_pip_sides;
    regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, draw = false)
        if (d6_pips[$faceindex] != "") {
            zrot(d6_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pips("d6", d6_pips[$faceindex], d6_adj_depth[$faceindex], 
                     d6_pip_fn, [d6_pip_size * d6_size, d6_pip_offset]);
        }
    
    // Pip symbols
    d6_pip_syms = fix_quotes(d6_pip_symbols);
    regular_polyhedron("cube", side = d6_size, anchor = BOTTOM, draw = false)
        if (d6_pip_symbol_pos[$faceindex] != "" && d6_pip_syms[$faceindex] != undef) {
            zrot(d6_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pip_symbols("d6", d6_pip_symbol_pos[$faceindex], 
                           d6_pip_syms[$faceindex], d6_pip_symbol_rotate[$faceindex], 
                           d6_adj_depth[$faceindex], [d6_pip_size * d6_size, d6_pip_offset]);
        }
}

// Helper module for face text rendering
module render_d6_face_text() {
    txt_merged = merge_txt(d6_text, fix_quotes(d6_symbols));
    txt_mult = d6_text_size * d6_size / 100;
    adj_txt = adj_list(d6_adj_size, d6_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d6_symbol_size * d6_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d6_text_spacing > 1 ? (d6_text_spacing - 1) * txt_mult / 3.15 : 
                 d6_text_spacing < 1 ? (-1 + d6_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d6_symbol_h_push * d6_size / 100, d6_symbol_v_push * d6_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d6_num_4_h_push * d6_size / 100)
        offset(delta = txt_stroke)
        text(txt_merged[$faceindex], size = txt_mult + adj_txt[$faceindex], 
             font = text_font, halign = "center", valign = "center");
    } else if (len(txt_merged[$faceindex]) == 1) { // Single digit
        offset(delta = txt_stroke)
        text(txt_merged[$faceindex], size = txt_mult + adj_txt[$faceindex], 
             font = text_font, halign = "center", valign = "center");
    } else { // Double digit
        right(space_mult)
        offset(delta = txt_stroke)
        text(txt_merged[$faceindex], size = txt_mult + adj_txt[$faceindex], 
             font = text_font, spacing = d6_text_spacing, 
             halign = "center", valign = "center");
    }
}