// D00 Percentile Die Module
// A ten-sided die showing 00, 10, 20, 30, 40, 50, 60, 70, 80, 90

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../lib/special_shapes.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D00 specific configuration parameters
d00_size = 16;
d00_text_size = 48;
d00_text_v_push = 0;
d00_text_h_push = -4;
d00_text = ["90", "10", "60", "70", "40", "30", "00", "50", "80", "20"];
d00_text_spacing = 1;
d00_symbols = [undef, undef, undef, undef, undef, undef, undef, undef, undef, undef];
d00_symbol_size = 48;
d00_symbol_v_push = 0;
d00_symbol_h_push = 0;
d00_rotate = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d00_length_mod = 0;
d00_angle_text = true;
d00_0_size = 65;  // Size of second "0" when angle_text is true
d00_0_padding = 60;  // Padding for second "0"
d00_10_h_push = 2;  // Horizontal push for "10"
d00_10_0_padding = 52;  // Padding for "0" in "10"
d00_bumpers = [true, true, false, true, false, true, false, true, false, false];
d00_adj_size = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d00_adj_v_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d00_adj_h_push = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d00_adj_depth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
d00_adj_spacing = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Main D00 drawing module
module draw_d00() {
    // Prepare text and symbols
    txt_merged = merge_txt(d00_text, fix_quotes(d00_symbols));
    txt_mult = d00_text_size * d00_size / 100;
    adj_txt = adj_list(d00_adj_size, d00_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d00_symbol_size * d00_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(d00_bumpers);
    space_mult = d00_text_spacing > 1 ? (d00_text_spacing - 1) * txt_mult / 3.15 : 
                 d00_text_spacing < 1 ? (-1 + d00_text_spacing) * txt_mult / 2.8 : 0;
    base_rotate = [25, -25, -115, -25, -115, -115, 25, -115, -25, -25];
    rotate_mod = d00_angle_text ? 90 : 0;
    
    // Geometry calculations
    d00_sside = sqrt(sqrt(5) - 2) * d00_size - d00_length_mod / d00_size;
    separation = 2 * sqr(sin(90/5)) * sqrt((sqr(d00_sside) + 2 * sqr(d00_size) * (cos(180/5) - 1)) / (cos(180/5) - 1) / (cos(180/5) + cos(360/5)));
    circumsphere_dia = separation / sqr(tan(90/5));
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.6;
    corner_clip_mult = d00_size - (corner_clipping * d00_size / 100) / 1.2;
    
    difference() {
        // Render die body
        if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
            // Render with bumpers
            union() {
                regular_polyhedron("trapezohedron", faces = 10, side = d00_sside, 
                                 longside = d00_size, anchor = BOTTOM);
                regular_polyhedron("trapezohedron", faces = 10, side = d00_sside, 
                                 longside = d00_size, anchor = BOTTOM, 
                                 rotate_children = false, draw = false)
                    if (bumpers[$faceindex]) 
                        stroke($face, width = bumper_size, closed = true);
            }
        } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
            // Render with corner modifications
            intersection() {
                regular_polyhedron("trapezohedron", faces = 10, side = d00_sside, 
                                 longside = d00_size, anchor = BOTTOM);
                if (corner_rounding > 0) {
                    translate([0, 0, d00_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d00_size / 2])
                        rotate([0, -48, 36]) 
                        rotate([0, 0, 54])
                            pentagonal_antiprism(corner_clip_mult);
                }
            }
        } else {
            // Standard trapezohedron with optional edge rounding
            regular_polyhedron("trapezohedron", faces = 10, side = d00_sside, 
                             longside = d00_size, anchor = BOTTOM, 
                             rounding = edge_rounding);
        }
        
        // Render face content
        render_d00_face_content();
    }
}

// Helper module to render face content
module render_d00_face_content() {
    base_rotate = [25, -25, -115, -25, -115, -115, 25, -115, -25, -25];
    rotate_mod = d00_angle_text ? 90 : 0;
    d00_sside = sqrt(sqrt(5) - 2) * d00_size - d00_length_mod / d00_size;
    
    // Numbers and symbols
    regular_polyhedron("trapezohedron", faces = 10, side = d00_sside, 
                     longside = d00_size, anchor = BOTTOM, draw = false)
        zrot(d00_rotate[$faceindex] + base_rotate[$faceindex] + rotate_mod)
        down(text_depth + d00_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d00_adj_depth[$faceindex])
        move([
            (d00_text_h_push + d00_adj_h_push[$faceindex]) * d00_size / 100,
            (d00_text_v_push + d00_adj_v_push[$faceindex]) * d00_size / 100
        ])
        render_d00_face_text();
}

// Helper module for face text rendering
module render_d00_face_text() {
    txt_merged = merge_txt(d00_text, fix_quotes(d00_symbols));
    txt_mult = d00_text_size * d00_size / 100;
    adj_txt = adj_list(d00_adj_size, d00_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d00_symbol_size * d00_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    space_mult = d00_text_spacing > 1 ? (d00_text_spacing - 1) * txt_mult / 3.15 : 
                 d00_text_spacing < 1 ? (-1 + d00_text_spacing) * txt_mult / 2.8 : 0;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([d00_symbol_h_push * d00_size / 100, d00_symbol_v_push * d00_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else { // Double digit number
        if (d00_angle_text) { // Special handling for angled text
            if (txt_merged[$faceindex] == "10") {
                right(d00_10_h_push * d00_size / 100)
                offset(delta = txt_stroke)
                text(txt_merged[$faceindex][0], size = txt_mult + adj_txt[$faceindex], 
                     font = text_font, halign = "center", valign = "center");
                right(txt_mult * d00_10_0_padding / 100)
                offset(delta = txt_stroke)
                text(txt_merged[$faceindex][1], size = txt_mult * d00_0_size / 100, 
                     font = text_font, halign = "center", valign = "center");
            } else {
                offset(delta = txt_stroke)
                text(txt_merged[$faceindex][0], size = txt_mult + adj_txt[$faceindex], 
                     font = text_font, halign = "center", valign = "center");
                right(txt_mult * d00_0_padding / 100)
                offset(delta = txt_stroke)
                text(txt_merged[$faceindex][1], size = txt_mult * d00_0_size / 100, 
                     font = text_font, spacing = d00_text_spacing - d00_adj_spacing[$faceindex], 
                     halign = "center", valign = "center");
            }
        } else { // Normal double digit display
            right(space_mult)
            offset(delta = txt_stroke)
            text(txt_merged[$faceindex], size = txt_mult + adj_txt[$faceindex], 
                 font = text_font, spacing = d00_text_spacing + d00_adj_spacing[$faceindex], 
                 halign = "center", valign = "center");
        }
    }
}

// Helper function
function sqr(x) = x * x;