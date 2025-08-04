// D8 Octahedron Die Module
// An eight-sided die with triangular faces

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D8 specific configuration parameters
d8_size = 15;
d8_text_size = 55;
d8_text_v_push = 2;
d8_text_h_push = 0;
d8_text = ["1", "3", "7", "5", "4", "2", "8", "6"];
d8_text_spacing = 1;
d8_symbols = [undef, undef, undef, undef, undef, undef, undef, undef];
d8_symbol_size = 55;
d8_symbol_v_push = 0;
d8_symbol_h_push = 0;
d8_underscores = [" ", " ", " ", " ", " ", " ", " ", "_"];
d8_underscore_size = 42;
d8_underscore_v_push = -26;
d8_underscore_h_push = 0;
d8_rotate = [0, 0, 0, 0, 0, 0, 0, 0];
d8_num_4_h_push = -3;
d8_bumpers = [false, false, false, false, true, true, true, true];
d8_adj_size = [0, 0, 0, 0, 0, 0, 0, 0];
d8_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0];
d8_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0];
d8_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0];

// Main D8 drawing module
module draw_d8() {
    // Prepare text and symbols
    txt_merged = merge_txt(d8_text, fix_quotes(d8_symbols));
    txt_mult = d8_text_size * d8_size / 100;
    adj_txt = adj_list(d8_adj_size, d8_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d8_symbol_size * d8_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d8_bumpers);
    under_mult = d8_underscore_size * d8_size / 100;
    space_mult = d8_text_spacing > 1 ? (d8_text_spacing - 1) * txt_mult / 3.15 : 
                 d8_text_spacing < 1 ? (-1 + d8_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [0, 0, 0, 0, 120, -120, -120, 0];
    
    // Geometry calculations
    d8_side = sqrt(3/2) * d8_size;
    circumsphere_dia = d8_side * sqrt(2);
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.4;
    corner_clip_mult = circumsphere_dia - (corner_clipping * circumsphere_dia / 100) / 1.4;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM);
                regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d8_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d8_size / 2])
                        rotate([45, 35, -15])
                            cube(corner_clip_mult, center = true);
                }
            }
        } else {
            // Standard octahedron with optional edge rounding
            regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d8_face_content();
    }
}

// Helper module to render face content
module render_d8_face_content() {
    d8_side = sqrt(3/2) * d8_size;
    base_rotate = [0, 0, 0, 0, 120, -120, -120, 0];
    txt_stroke = text_stroke * (d8_text_size * d8_size / 100);
    under_mult = d8_underscore_size * d8_size / 100;
    
    // Numbers and symbols
    regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM, draw = false)
        zrot(d8_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d8_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d8_adj_depth[$faceindex])
        move([
            (d8_text_h_push + d8_adj_h_push[$faceindex]) * d8_size / 100,
            (d8_text_v_push + d8_adj_v_push[$faceindex]) * d8_size / 100
        ])
        render_d8_face_text();
        
    // Underscores
    regular_polyhedron("octahedron", side = d8_side, anchor = BOTTOM, draw = false)
        if (d8_underscores[$faceindex] != "") {
            zrot(d8_rotate[$faceindex] + base_rotate[$faceindex])
            down(text_depth + d8_adj_depth[$faceindex])
            linear_extrude(height = 2 * text_depth + d8_adj_depth[$faceindex])
            move([d8_underscore_h_push * d8_size / 100, d8_underscore_v_push * d8_size / 100])
            offset(delta = txt_stroke)
            text(d8_underscores[$faceindex], size = under_mult, font = underscore_font, 
                 halign = "center", valign = "center");
        }
}

// Helper module for face text rendering
module render_d8_face_text() {
    txt_merged = merge_txt(d8_text, fix_quotes(d8_symbols));
    txt_mult = d8_text_size * d8_size / 100;
    adj_txt = adj_list(d8_adj_size, d8_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d8_symbol_size * d8_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d8_text_spacing > 1 ? (d8_text_spacing - 1) * txt_mult / 3.15 : 
                 d8_text_spacing < 1 ? (-1 + d8_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d8_symbol_h_push * d8_size / 100, d8_symbol_v_push * d8_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d8_num_4_h_push * d8_size / 100)
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
             font = text_font, spacing = d8_text_spacing, 
             halign = "center", valign = "center");
    }
}