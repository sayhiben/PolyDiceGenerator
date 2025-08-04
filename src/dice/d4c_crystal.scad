// D4C Crystal Die Module
// A four-sided crystal-shaped die with elongated body

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../lib/pip_drawing.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D4C specific configuration parameters
d4c_size = 13;
d4c_text_size = 72;
d4c_text_v_push = 0;
d4c_text_h_push = 0;
d4c_text = ["1", " ", "3", " ", "4", "2"];
d4c_symbols = [undef, undef, undef, undef, undef, undef];
d4c_symbol_size = 72;
d4c_symbol_v_push = 0;
d4c_symbol_h_push = 0;
d4c_rotate = [0, 0, 0, 0, 0, 0];
d4c_num_4_h_push = -3;
d4c_adj_size = [0, 0, 0, 0, 0, 0];
d4c_adj_v_push = [0, 0, 0, 0, 0, 0];
d4c_adj_h_push = [0, 0, 0, 0, 0, 0];
d4c_adj_depth = [0, 0, 0, 0, 0, 0];

// Geometry parameters
d4c_body_length = 1.4;  // Body length multiplier
d4c_point_length = 0.4;   // Point length multiplier

// Pip-specific parameters
d4c_pips = [" ", " ", " ", " ", " ", " "];
d4c_pip_size = 20;
d4c_pip_offset = 2.5;
d4c_pip_sides = 6; //[0,3,4,5,6,8,10,12]
d4c_pip_symbols = [undef, undef, undef, undef, undef, undef];
d4c_pip_symbol_pos = ["1", " ", "3", " ", "4", "2"];
d4c_pip_symbol_rotate = [0, 0, 0, 0, 0, 0];

// Main D4C drawing module
module draw_d4c() {
    // Prepare text and symbols
    txt_merged = merge_txt(d4c_text, fix_quotes(d4c_symbols));
    txt_mult = d4c_text_size * d4c_size / 100;
    adj_txt = adj_list(d4c_adj_size, d4c_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4c_symbol_size * d4c_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    base_rotate = [180, 0, 90, 0, 0, -90];
    d4c_pip_fn = d4c_pip_sides == 0 ? 128 : d4c_pip_sides;
    
    // Calculate dimensions
    body_length = d4c_body_length * d4c_size;
    point_length = d4c_point_length * d4c_size;
    circumsphere_dia = body_length + point_length * 2;
    corner_round_mult = circumsphere_dia - (corner_rounding * circumsphere_dia / 100) / 1.9;
    corner_clip_mult = circumsphere_dia - (corner_clipping * circumsphere_dia / 100) / 1.9;
    
    difference() {
        intersection() {
            // Render clipping objects for corner modifications
            if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
                if (corner_rounding > 0) {
                    translate([0, 0, d4c_size / 2])
                        sphere(d = corner_round_mult);
                } else if (corner_clipping > 0) {
                    translate([0, 0, d4c_size / 2])
                        cube(corner_clip_mult, center = true);
                }
            }
            
            // Render crystal body
            up(edge_rounding)
            minkowski() {
                scale((d4c_size - 2 * edge_rounding) / d4c_size) {
                    // Main body
                    cuboid([d4c_size, body_length, d4c_size], anchor = BOTTOM);
                    // Front point
                    translate([0, -body_length / 2, d4c_size / 2])
                    rotate([90, 90, 0])
                        prismoid([d4c_size, d4c_size], [0, 0], h = point_length);
                    // Back point
                    mirror([1, 0, 0])
                    translate([0, body_length / 2, d4c_size / 2])
                    rotate([-90, -90, 0])
                        prismoid([d4c_size, d4c_size], [0, 0], h = point_length);
                }
                if (edge_rounding > 0) 
                    sphere(r = edge_rounding);
            }
        }
        
        // Render face content
        render_d4c_faces();
    }
}

// Helper module to render face content
module render_d4c_faces() {
    base_rotate = [180, 0, 90, 0, 0, -90];
    txt_stroke = text_stroke * (d4c_text_size * d4c_size / 100);
    d4c_pip_fn = d4c_pip_sides == 0 ? 128 : d4c_pip_sides;
    
    // Numbers and symbols
    regular_polyhedron("cube", side = d4c_size, anchor = BOTTOM, draw = false)
        zrot(d4c_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d4c_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d4c_adj_depth[$faceindex])
        move([
            (d4c_text_h_push + d4c_adj_h_push[$faceindex]) * d4c_size / 100,
            (d4c_text_v_push + d4c_adj_v_push[$faceindex]) * d4c_size / 100
        ])
        render_d4c_face_text($faceindex);
        
    // Pips
    regular_polyhedron("cube", side = d4c_size, anchor = BOTTOM, draw = false)
        if (d4c_pips[$faceindex] != "") {
            zrot(d4c_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pips("d4c", d4c_pips[$faceindex], d4c_adj_depth[$faceindex], 
                     d4c_pip_fn, [d4c_pip_size * d4c_size, d4c_pip_offset]);
        }
    
    // Pip symbols
    d4c_pip_syms = fix_quotes(d4c_pip_symbols);
    regular_polyhedron("cube", side = d4c_size, anchor = BOTTOM, draw = false)
        if (d4c_pip_symbol_pos[$faceindex] != "" && d4c_pip_syms[$faceindex] != undef) {
            zrot(d4c_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pip_symbols("d4c", d4c_pip_symbol_pos[$faceindex], 
                           d4c_pip_syms[$faceindex], d4c_pip_symbol_rotate[$faceindex], 
                           d4c_adj_depth[$faceindex], [d4c_pip_size * d4c_size, d4c_pip_offset]);
        }
}

// Helper module for face text rendering
module render_d4c_face_text(face_idx) {
    txt_merged = merge_txt(d4c_text, fix_quotes(d4c_symbols));
    txt_mult = d4c_text_size * d4c_size / 100;
    adj_txt = adj_list(d4c_adj_size, d4c_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4c_symbol_size * d4c_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    if (is_list(txt_merged[face_idx])) { // Symbol
        move([d4c_symbol_h_push * d4c_size / 100, d4c_symbol_v_push * d4c_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[face_idx][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[face_idx] == "4") { // Special handling for number 4
        right(d4c_num_4_h_push * d4c_size / 100)
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    } else { // Other numbers
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    }
}