// D20 Icosahedron Die Module
// A twenty-sided die with triangular faces

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D20 specific configuration parameters
d20_size = 20;
d20_text_size = 23;
d20_text_v_push = 0;
d20_text_h_push = 0;
d20_text = ["1", "19", "11", "13", "9", "7", "17", "3", "18", "5", 
            "4", "15", "12", "10", "6", "16", "2", "8", "14", "20"];
d20_text_spacing = 1;
d20_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, undef, undef,
               undef, undef, undef, undef, undef, undef, undef, undef, undef, undef];
d20_symbol_size = 23;
d20_symbol_v_push = 0;
d20_symbol_h_push = 0;
d20_underscores = [" ", " ", " ", " ", "_", " ", " ", " ", " ", " ",
                   " ", " ", " ", " ", "_", " ", " ", " ", " ", " "];
d20_underscore_size = 18;
d20_underscore_v_push = -12;
d20_underscore_h_push = 0;
d20_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d20_num_4_h_push = -3;
d20_bumpers = [true, true, true, false, true, true, false, false, false, false,
               false, false, false, false, false, false, false, false, false, false];
d20_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d20_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d20_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d20_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d20_adj_spacing = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D20 drawing module
module draw_d20() {
    // Prepare text and symbols
    txt_merged = merge_txt(d20_text, fix_quotes(d20_symbols));
    txt_mult = d20_text_size * d20_size / 100;
    adj_txt = adj_list(d20_adj_size, d20_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d20_symbol_size * d20_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d20_bumpers);
    under_mult = d20_underscore_size * d20_size / 100;
    space_mult = d20_text_spacing > 1 ? (d20_text_spacing - 1) * txt_mult / 3.15 : 
                 d20_text_spacing < 1 ? (-1 + d20_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [120, 120, -120, -120, 120, 120, 120, -120, 0, -120, 
                   0, 120, 0, 0, 0, 0, 0, 0, -120, 0];
    
    // Geometry calculations
    d20_side = d20_size / 2 * 12 / (sqrt(3) * (3 + sqrt(5)));
    circumsphere_dia = d20_side * sin(72) * 2;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 2.5;
    corner_clip_mult = circumsphere_dia / 2 - (corner_clipping * circumsphere_dia / 100 / 2) / 2.5;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM);
                regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d20_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d20_size / 2])
                        rotate([36, -10.81, -6.42])
                            regular_polyhedron("dodecahedron", ir = corner_clip_mult);
                }
            }
        } else {
            // Standard icosahedron with optional edge rounding
            regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d20_face_content();
    }
}

// Helper module to render face content
module render_d20_face_content() {
    // Prepare variables
    base_rotate = [152, 96, -96, 96, -40, -40, -40, -40, -152, 40, 40, 40, 40, -152, -96, 96, -152, -96, 152, 152];
    txt_stroke = text_stroke * (d20_text_size * d20_size / 100);
    under_mult = d20_underscore_size * d20_size / 100;
    
    // Numbers and symbols
    regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM, draw = false)
        zrot(d20_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d20_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d20_adj_depth[$faceindex])
        move([
            (d20_text_h_push + d20_adj_h_push[$faceindex]) * d20_size / 100,
            (d20_text_v_push + d20_adj_v_push[$faceindex]) * d20_size / 100
        ])
        render_d20_face_text();
        
    // Underscores
    regular_polyhedron("icosahedron", ir = d20_size / 2, anchor = BOTTOM, draw = false)
        if (d20_underscores[$faceindex] != "") {
            zrot(d20_rotate[$faceindex] + base_rotate[$faceindex])
            down(text_depth + d20_adj_depth[$faceindex])
            linear_extrude(height = 2 * text_depth + d20_adj_depth[$faceindex])
            move([d20_underscore_h_push * d20_size / 100, d20_underscore_v_push * d20_size / 100])
            offset(delta = txt_stroke)
            text(d20_underscores[$faceindex], size = under_mult, font = underscore_font, 
                 halign = "center", valign = "center");
        }
}

// Helper module for face text rendering
module render_d20_face_text() {
    txt_merged = merge_txt(d20_text, fix_quotes(d20_symbols));
    txt_mult = d20_text_size * d20_size / 100;
    adj_txt = adj_list(d20_adj_size, d20_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d20_symbol_size * d20_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d20_text_spacing > 1 ? (d20_text_spacing - 1) * txt_mult / 3.15 : 
                 d20_text_spacing < 1 ? (-1 + d20_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d20_symbol_h_push * d20_size / 100, d20_symbol_v_push * d20_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d20_num_4_h_push * d20_size / 100)
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
             font = text_font, spacing = d20_text_spacing + d20_adj_spacing[$faceindex], 
             halign = "center", valign = "center");
    }
}