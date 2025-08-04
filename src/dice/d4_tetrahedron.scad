// D4 Tetrahedron Die Module
// A customizable four-sided die

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D4 specific configuration parameters
d4_size = 20;
d4_text_size = 34;
d4_text_v_push = 30;
d4_text_h_push = 0;
d4_text = ["3", "4", "3", "3", "2", "2", "4", "4", "1", "1", "1", "2"];
d4_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef];
d4_symbol_size = 34;
d4_symbol_v_push = 0;
d4_symbol_h_push = 0;
d4_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d4_num_4_h_push = -3;
d4_bumpers = [true, true, true, false];
d4_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d4_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d4_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d4_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D4 drawing module
module draw_d4() {
    // Prepare text and symbols
    txt_merged = merge_txt(d4_text, fix_quotes(d4_symbols));
    txt_mult = d4_text_size * d4_size / 100;
    adj_txt = adj_list(d4_adj_size, d4_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4_symbol_size * d4_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d4_bumpers);
    base_rotate = [0, -120, -120, 0, 120, 120, 120, 120, -120, 0, 0, -120];
    
    // Geometry calculations
    d4_side = d4_size / sqrt(2/3);
    circumsphere_dia = d4_side * sqrt(3/8) * 2;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100);
    dual_mult = d4_side * 3;
    corner_clip_mult = dual_mult - (corner_clipping * dual_mult / 100);
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("tetrahedron", side = d4_side, anchor = BOTTOM);
                regular_polyhedron("tetrahedron", side = d4_side, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("tetrahedron", side = d4_side, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d4_size / 4])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d4_size / 4])
                        rotate([0, 180, -30])
                            regular_polyhedron("tetrahedron", side = corner_clip_mult);
                }
            }
        } else {
            // Standard tetrahedron with optional edge rounding
            regular_polyhedron("tetrahedron", side = d4_side, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render numbers & symbols on each edge (3 numbers per face)
        for (i = [0, 1, 2]) {
            regular_polyhedron("tetrahedron", side = d4_side, anchor = BOTTOM, draw = false)
                zrot(d4_rotate[$faceindex + i * 4] + base_rotate[$faceindex + i * 4])
                down(text_depth + d4_adj_depth[$faceindex + i * 4])
                linear_extrude(height = 2 * text_depth + d4_adj_depth[$faceindex + i * 4])
                move([
                    (d4_text_h_push + d4_adj_h_push[$faceindex + i * 4]) * d4_size / 100,
                    (d4_text_v_push + d4_adj_v_push[$faceindex + i * 4]) * d4_size / 100
                ])
                render_d4_face_text(i);
        }
    }
}

// Helper module for face text rendering
module render_d4_face_text(edge_index) {
    txt_merged = merge_txt(d4_text, fix_quotes(d4_symbols));
    txt_mult = d4_text_size * d4_size / 100;
    adj_txt = adj_list(d4_adj_size, d4_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4_symbol_size * d4_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    idx = $faceindex + edge_index * 4;
    
    if (is_list(txt_merged[idx])) { // Symbol
        move([d4_symbol_h_push * d4_size / 100, d4_symbol_v_push * d4_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[idx][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[idx] == "4") { // Special handling for number 4
        right(d4_num_4_h_push * d4_size / 100)
        offset(delta = txt_stroke)
        text(txt_merged[idx], size = txt_mult + adj_txt[idx], 
             font = text_font, halign = "center", valign = "center");
    } else { // Other numbers
        offset(delta = txt_stroke)
        text(txt_merged[idx], size = txt_mult + adj_txt[idx], 
             font = text_font, halign = "center", valign = "center");
    }
}