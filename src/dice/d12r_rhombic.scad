// D12R Rhombic Dodecahedron Die Module
// A twelve-sided die with rhombic (diamond-shaped) faces

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D12R specific configuration parameters
d12r_size = 18;
d12r_text_size = 34;
d12r_text_v_push = 0;
d12r_text_h_push = 0;
d12r_text = ["1", "6", "2", "8", "10", "4", "3", "7", "9", "5", "12", "11"];
d12r_text_spacing = 1;
d12r_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef];
d12r_symbol_size = 34;
d12r_symbol_v_push = 0;
d12r_symbol_h_push = 0;
d12r_underscores = [" ", "_", " ", " ", " ", " ", " ", " ", "_", " ", " ", " "];
d12r_underscore_size = 28;
d12r_underscore_v_push = -19;
d12r_underscore_h_push = 0;
d12r_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d12r_num_4_h_push = -3;
d12r_bumpers = [true, false, false, false, true, false, true, false, false, true, false, false];
d12r_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d12r_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d12r_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d12r_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d12r_adj_spacing = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D12R drawing module
module draw_d12r() {
    // Prepare text and symbols
    txt_merged = merge_txt(d12r_text, fix_quotes(d12r_symbols));
    txt_mult = d12r_text_size * d12r_size / 100;
    adj_txt = adj_list(d12r_adj_size, d12r_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d12r_symbol_size * d12r_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d12r_bumpers);
    under_mult = d12r_underscore_size * d12r_size / 100;
    space_mult = d12r_text_spacing > 1 ? (d12r_text_spacing - 1) * txt_mult / 3.15 : 
                 d12r_text_spacing < 1 ? (-1 + d12r_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [145, -145, 145, -35, 35, -145, 35, -145, 35, 145, 145, -35];
    
    // Geometry calculations
    circumsphere_dia = d12r_size * (1 / sqrt(2)) * 2;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 2;
    corner_clip_mult = circumsphere_dia / 2 - (corner_clipping * circumsphere_dia / 100 / 2) / 2;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM);
                regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d12r_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d12r_size / 2])
                        rotate([0, 45, 0])
                            regular_polyhedron("cuboctahedron", ir = corner_clip_mult);
                }
            }
        } else {
            // Standard rhombic dodecahedron with optional edge rounding
            regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d12r_face_content();
    }
}

// Helper module to render face content
module render_d12r_face_content() {
    // Prepare variables
    base_rotate = [145, -145, 145, -35, 35, -145, 35, -145, 35, 145, 145, -35];
    txt_stroke = text_stroke * (d12r_text_size * d12r_size / 100);
    under_mult = d12r_underscore_size * d12r_size / 100;
    
    // Numbers and symbols
    regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM, draw = false)
        zrot(d12r_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d12r_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d12r_adj_depth[$faceindex])
        move([
            (d12r_text_h_push + d12r_adj_h_push[$faceindex]) * d12r_size / 100,
            (d12r_text_v_push + d12r_adj_v_push[$faceindex]) * d12r_size / 100
        ])
        render_d12r_face_text();
        
    // Underscores
    regular_polyhedron("rhombic dodecahedron", ir = d12r_size / 2, anchor = BOTTOM, draw = false)
        if (d12r_underscores[$faceindex] != "") {
            zrot(d12r_rotate[$faceindex] + base_rotate[$faceindex])
            down(text_depth + d12r_adj_depth[$faceindex])
            linear_extrude(height = 2 * text_depth + d12r_adj_depth[$faceindex])
            move([d12r_underscore_h_push * d12r_size / 100, d12r_underscore_v_push * d12r_size / 100])
            offset(delta = txt_stroke)
            text(d12r_underscores[$faceindex], size = under_mult, font = underscore_font, 
                 halign = "center", valign = "center");
        }
}

// Helper module for face text rendering
module render_d12r_face_text() {
    txt_merged = merge_txt(d12r_text, fix_quotes(d12r_symbols));
    txt_mult = d12r_text_size * d12r_size / 100;
    adj_txt = adj_list(d12r_adj_size, d12r_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d12r_symbol_size * d12r_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d12r_text_spacing > 1 ? (d12r_text_spacing - 1) * txt_mult / 3.15 : 
                 d12r_text_spacing < 1 ? (-1 + d12r_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [145, -145, 145, -35, 35, -145, 35, -145, 35, 145, 145, -35];
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d12r_symbol_h_push * d12r_size / 100, d12r_symbol_v_push * d12r_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d12r_num_4_h_push * d12r_size / 100)
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
             font = text_font, spacing = d12r_text_spacing + d12r_adj_spacing[$faceindex], 
             halign = "center", valign = "center");
    }
}