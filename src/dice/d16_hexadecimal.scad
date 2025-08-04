// D16 Hexadecimal Die Module
// A sixteen-sided die often used for hexadecimal values

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../lib/special_shapes.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D16 specific configuration parameters
d16_size = 16;
d16_text_size = 48;  // Note: Uses d16_size/200 instead of /100
d16_text_v_push = 0;
d16_text_h_push = 0;
d16_text = ["1", "9", "12", "7", "4", "11", "14", "5", "2", "13", 
            "16", "3", "8", "15", "10", "6"];
d16_text_spacing = 1;
d16_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, 
               undef, undef, undef, undef, undef, undef, undef, undef];
d16_symbol_size = 48;
d16_symbol_v_push = 0;
d16_symbol_h_push = 0;
d16_underscores = [" ", "_", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "_"];
d16_underscore_size = 37;
d16_underscore_v_push = -17;
d16_underscore_h_push = 0;
d16_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d16_num_4_h_push = 0;
d16_length_mod = 0;
d16_bumpers = [true, true, true, true, true, true, true, true, true, true, 
               undef, undef, undef, undef, undef, undef];
d16_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d16_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d16_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d16_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D16 drawing module
module draw_d16() {
    // Prepare text and symbols
    txt_merged = merge_txt(d16_text, fix_quotes(d16_symbols));
    txt_mult = d16_text_size * d16_size / 200;  // Note: Different scaling factor
    adj_txt = adj_list(d16_adj_size, d16_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d16_symbol_size * d16_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d16_bumpers);
    under_mult = d16_underscore_size * d16_size / 100;
    space_mult = d16_text_spacing > 1 ? (d16_text_spacing - 1) * txt_mult / 3.15 : 
                 d16_text_spacing < 1 ? (-1 + d16_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [16.813, 16.813, 253.682, 343.682, 253.682, 343.682, 253.682, 254.289, 
                   106.318, 254.289, 16.318, 254.289, 343.682, 106.289, 343.682, 343.682];
    
    // Geometry calculations
    d16_height = sqrt(0.5 * pow(d16_size, 2)) - d16_length_mod / d16_size;
    circumsphere_dia = regular_polyhedron_info("out_radius", "trapezohedron", 
                                             faces = 16, h = d16_height, 
                                             longside = d16_size, anchor = BOTTOM) * 2;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.6;
    corner_clip_mult = d16_size - (corner_clipping * d16_size / 100) / 1.2;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                                 longside = d16_size, anchor = BOTTOM);
                regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                                 longside = d16_size, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                                 longside = d16_size, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d16_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d16_size / 2])
                        rotate([0, -48, 36]) 
                        rotate([0, 0, 54])
                            pentagonal_antiprism(corner_clip_mult);
                }
            }
        } else {
            // Standard trapezohedron with optional edge rounding
            regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                             longside = d16_size, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d16_face_content();
    }
}

// Helper module to render face content
module render_d16_face_content() {
    d16_height = sqrt(0.5 * pow(d16_size, 2)) - d16_length_mod / d16_size;
    base_rotate = [16.813, 16.813, 253.682, 343.682, 253.682, 343.682, 253.682, 254.289, 
                   106.318, 254.289, 16.318, 254.289, 343.682, 106.289, 343.682, 343.682];
    txt_stroke = text_stroke * (d16_text_size * d16_size / 200);
    under_mult = d16_underscore_size * d16_size / 100;
    
    // Numbers and symbols
    regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                     longside = d16_size, anchor = BOTTOM, draw = false)
        zrot(d16_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d16_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d16_adj_depth[$faceindex])
        move([
            (d16_text_h_push + d16_adj_h_push[$faceindex]) * d16_size / 100,
            (d16_text_v_push + d16_adj_v_push[$faceindex]) * d16_size / 100
        ])
        render_d16_face_text();
        
    // Underscores
    regular_polyhedron("trapezohedron", faces = 16, h = d16_height, 
                     longside = d16_size, anchor = BOTTOM, draw = false)
        if (d16_underscores[$faceindex] != "") {
            zrot(d16_rotate[$faceindex] + base_rotate[$faceindex])
            down(text_depth + d16_adj_depth[$faceindex])
            linear_extrude(height = 2 * text_depth + d16_adj_depth[$faceindex])
            move([d16_underscore_h_push * d16_size / 100, d16_underscore_v_push * d16_size / 100])
            offset(delta = txt_stroke)
            text(d16_underscores[$faceindex], size = under_mult, font = underscore_font, 
                 halign = "center", valign = "center");
        }
}

// Helper module for face text rendering
module render_d16_face_text() {
    txt_merged = merge_txt(d16_text, fix_quotes(d16_symbols));
    txt_mult = d16_text_size * d16_size / 200;  // Note: Different scaling factor
    adj_txt = adj_list(d16_adj_size, d16_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d16_symbol_size * d16_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d16_text_spacing > 1 ? (d16_text_spacing - 1) * txt_mult / 3.15 : 
                 d16_text_spacing < 1 ? (-1 + d16_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d16_symbol_h_push * d16_size / 100, d16_symbol_v_push * d16_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[$faceindex] == "4") { // Special handling for number 4
        right(d16_num_4_h_push * d16_size / 100)
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
             font = text_font, spacing = d16_text_spacing, 
             halign = "center", valign = "center");
    }
}