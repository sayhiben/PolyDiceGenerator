// D4P Pentagonal Die Module
// A four-sided pentagonal die (double pyramid shape)

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D4P specific configuration parameters
d4p_size = 14;
d4p_text_size = 50;
d4p_text_v_push = 48;
d4p_text_h_push = 0;
d4p_text = ["3", "4", "2", "1"];
d4p_symbols = [undef, undef, undef, undef];
d4p_symbol_size = 55;
d4p_symbol_v_push = 0;
d4p_symbol_h_push = 0;
d4p_rotate = [0, 0, 0, 0];
d4p_num_4_h_push = -3;
d4p_adj_size = [0, 0, 0, 0];
d4p_adj_v_push = [0, 0, 0, 0];
d4p_adj_h_push = [0, 0, 0, 0];
d4p_adj_depth = [0, 0, 0, 0];

// Geometry parameters
d4p_body_length = 17.5;  // Body length parameter
d4p_base_length = 4.8;  // Base length parameter

// Main D4P drawing module
module draw_d4p() {
    // Prepare text and symbols
    txt_merged = merge_txt(d4p_text, fix_quotes(d4p_symbols));
    txt_mult = d4p_text_size * d4p_size / 100;
    adj_txt = adj_list(d4p_adj_size, d4p_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4p_symbol_size * d4p_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    base_rotate = [180, 180, 180, 180];
    
    // Calculate dimensions
    body_length = d4p_body_length * d4p_size / 10;
    base_length = d4p_base_length * d4p_size / 10;
    circumsphere_dia = body_length + base_length;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.9;
    corner_clip_mult = circumsphere_dia - (corner_clipping * circumsphere_dia / 100) / 1.9;
    d4p_diag = d4p_size * sqrt(2);
    diag_clip_mult = d4p_diag - (corner_clipping * d4p_diag / 100) / 1.9;
    d4p_side_length = sqrt(sqr(d4p_size / 2) + sqr(body_length));
    d4p_face_angle = atan(body_length / (d4p_size / 2));
    d4p_up_length = d4p_size / 2 * cos(90 - d4p_face_angle);
    d4p_up_rounding = edge_rounding * cos(90 - d4p_face_angle);
    
    // Position die on face
    translate([0, 0, d4p_up_length])
    rotate([180 - d4p_face_angle, 0, 0])
    
    difference() {
        intersection() {
            // Render clipping objects for corner modifications
            if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
                if (corner_rounding > 0) {
                    translate([0, 0, body_length / 2 + base_length / 2 - base_length])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    rotate([0, 0, 45])
                    translate([0, 0, body_length / 2 + base_length / 2 - base_length])
                        cuboid([diag_clip_mult, diag_clip_mult, corner_clip_mult]);
                }
            }
            
            // Render double pyramid shape
            minkowski() {
                scale((d4p_size - 2 * edge_rounding) / d4p_size) {
                    // Top pyramid
                    prismoid([d4p_size, d4p_size], [0, 0], h = body_length, anchor = BOTTOM);
                    // Bottom pyramid
                    prismoid([0, 0], [d4p_size, d4p_size], h = base_length, anchor = TOP);
                }
                if (edge_rounding > 0) 
                    sphere(r = edge_rounding);
            }
        }
        
        // Render numbers & symbols on faces
        for (i = [0:3]) {
            rotate([90, 0, 0]) 
            rotate([0, 90 * i, 0])
            translate([d4p_size / 2, 0, 0])
            rotate([0, 90, 90 - d4p_face_angle])
            move([
                (d4p_text_h_push + d4p_adj_h_push[i]) * d4p_size / 100,
                (d4p_text_v_push + d4p_adj_v_push[i]) * d4p_size / 100
            ])
            zrot(d4p_rotate[i] + base_rotate[i])
            down(text_depth + d4p_adj_depth[i])
            linear_extrude(height = 2 * text_depth + d4p_adj_depth[i])
            render_d4p_face_text(i);
        }
    }
}

// Helper module for face text rendering
module render_d4p_face_text(face_idx) {
    txt_merged = merge_txt(d4p_text, fix_quotes(d4p_symbols));
    txt_mult = d4p_text_size * d4p_size / 100;
    adj_txt = adj_list(d4p_adj_size, d4p_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4p_symbol_size * d4p_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    if (is_list(txt_merged[face_idx])) { // Symbol
        move([d4p_symbol_h_push * d4p_size / 100, d4p_symbol_v_push * d4p_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[face_idx][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[face_idx] == "4") { // Special handling for number 4
        right(d4p_num_4_h_push * d4p_size / 100)
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    } else { // Other numbers
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    }
}

// Helper function
function sqr(x) = x * x;