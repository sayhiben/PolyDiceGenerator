// D10 Pentagonal Trapezohedron Die Module
// A ten-sided die with kite-shaped faces

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../lib/special_shapes.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D10 specific configuration parameters
d10_size = 16;
d10_text_size = 48;
d10_text_v_push = 7.5;
d10_text_h_push = 0;
d10_text = ["9", "1", "6", "7", "4", "3", "0", "5", "8", "2"];
d10_text_spacing = 1;
d10_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, undef, undef];
d10_symbol_size = 48;
d10_symbol_v_push = 0;
d10_symbol_h_push = 0;
d10_underscores = ["_", " ", "_", " ", " ", " ", " ", " ", " ", " "];
d10_underscore_size = 37;
d10_underscore_v_push = -17;
d10_underscore_h_push = 0;
d10_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d10_num_4_h_push = -3;
d10_length_mod = 0;
d10_bumpers = [true, true, false, true, false, true, false, true, false, false];
d10_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d10_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d10_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d10_adj_spacing = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d10_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D10 drawing module
module draw_d10() {
    // Prepare text and symbols
    txt_merged = merge_txt(d10_text, fix_quotes(d10_symbols));
    txt_mult = d10_text_size * d10_size / 100;
    adj_txt = adj_list(d10_adj_size, d10_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d10_symbol_size * d10_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d10_bumpers);
    under_mult = d10_underscore_size * d10_size / 100;
    space_mult = d10_text_spacing > 1 ? (d10_text_spacing - 1) * txt_mult / 3.15 : 
                 d10_text_spacing < 1 ? (-1 + d10_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [25, -25, -115, -25, -115, -115, 25, -115, -25, -25];
    
    // Geometry calculations
    d10_sside = sqrt(sqrt(5) - 2) * d10_size - d10_length_mod / d10_size;
    separation = 2 * sqr(sin(90/5)) * sqrt((sqr(d10_sside) + 2 * sqr(d10_size) * (cos(180/5) - 1)) / (cos(180/5) - 1) / (cos(180/5) + cos(360/5)));
    circumsphere_dia = separation / sqr(tan(90/5));
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.6;
    corner_clip_mult = d10_size - (corner_clipping * d10_size / 100) / 1.2;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                                 longside = d10_size, anchor = BOTTOM);
                regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                                 longside = d10_size, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                                 longside = d10_size, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d10_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d10_size / 2])
                        rotate([0, -48, 36]) 
                        rotate([0, 0, 54])
                            pentagonal_antiprism(corner_clip_mult);
                }
            }
        } else {
            // Standard trapezohedron with optional edge rounding
            regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                             longside = d10_size, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d10_face_content();
    }
}

// Helper module to render face content
module render_d10_face_content() {
    base_rotate = [25, -25, -115, -25, -115, -115, 25, -115, -25, -25];
    d10_sside = sqrt(sqrt(5) - 2) * d10_size - d10_length_mod / d10_size;
    txt_stroke = text_stroke * (d10_text_size * d10_size / 100);
    under_mult = d10_underscore_size * d10_size / 100;
    
    // Numbers and symbols
    regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                     longside = d10_size, anchor = BOTTOM, draw = false)
        zrot(d10_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d10_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d10_adj_depth[$faceindex])
        move([
            (d10_text_h_push + d10_adj_h_push[$faceindex]) * d10_size / 100,
            (d10_text_v_push + d10_adj_v_push[$faceindex]) * d10_size / 100
        ])
        render_d10_face_text();
        
    // Underscores
    regular_polyhedron("trapezohedron", faces = 10, side = d10_sside, 
                     longside = d10_size, anchor = BOTTOM, draw = false)
        if (d10_underscores[$faceindex] != "") {
            zrot(d10_rotate[$faceindex] + base_rotate[$faceindex])
            down(text_depth + d10_adj_depth[$faceindex])
            linear_extrude(height = 2 * text_depth + d10_adj_depth[$faceindex])
            move([d10_underscore_h_push * d10_size / 100, d10_underscore_v_push * d10_size / 100])
            offset(delta = txt_stroke)
            text(d10_underscores[$faceindex], size = under_mult, font = underscore_font, 
                 halign = "center", valign = "center");
        }
}

// Helper module for face text rendering
module render_d10_face_text() {
    txt_merged = merge_txt(d10_text, fix_quotes(d10_symbols));
    txt_mult = d10_text_size * d10_size / 100;
    adj_txt = adj_list(d10_adj_size, d10_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d10_symbol_size * d10_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d10_text_spacing > 1 ? (d10_text_spacing - 1) * txt_mult / 3.15 : 
                 d10_text_spacing < 1 ? (-1 + d10_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d10_symbol_h_push * d10_size / 100, d10_symbol_v_push * d10_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d10_num_4_h_push * d10_size / 100)
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
             font = text_font, spacing = d10_text_spacing, 
             halign = "center", valign = "center");
    }
}

// Helper function from the original code
function sqr(x) = x * x;