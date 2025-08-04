// D4I Infinite Die Module
// A four-sided die with truncated edges (infinite-sided appearance)

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../lib/pip_drawing.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D4I specific configuration parameters
d4i_size = 14;
d4i_text_size = 70;
d4i_text_v_push = 10;
d4i_text_h_push = 0;
d4i_text = ["1", " ", "3", " ", "4", "2"];
d4i_symbols = [undef, undef, undef, undef, undef, undef];
d4i_symbol_size = 72;
d4i_symbol_v_push = 0;
d4i_symbol_h_push = 0;
d4i_rotate = [0, 0, 0, 0, 0, 0];
d4i_num_4_h_push = -3;
d4i_adj_size = [0, 0, 0, 0, 0, 0];
d4i_adj_v_push = [0, 0, 0, 0, 0, 0];
d4i_adj_h_push = [0, 0, 0, 0, 0, 0];
d4i_adj_depth = [0, 0, 0, 0, 0, 0];

// Geometry parameters
d4i_body_length = 1.4;  // Body length multiplier

// Pip-specific parameters
d4i_pips = [" ", " ", " ", " ", " ", " "];
d4i_pip_size = 20;
d4i_pip_offset = 2.5;
d4i_pip_sides = 6; //[0,3,4,5,6,8,10,12]
d4i_pip_symbols = [undef, undef, undef, undef, undef, undef];
d4i_pip_symbol_pos = ["1", " ", "3", " ", "4", "2"];
d4i_pip_symbol_rotate = [0, 0, 0, 0, 0, 0];

// Main D4I drawing module
module draw_d4i() {
    // Prepare text and symbols
    txt_merged = merge_txt(d4i_text, fix_quotes(d4i_symbols));
    txt_mult = d4i_text_size * d4i_size / 100;
    adj_txt = adj_list(d4i_adj_size, d4i_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4i_symbol_size * d4i_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    base_rotate = [0, 0, 90, 0, 180, -90];
    d4i_pip_fn = d4i_pip_sides == 0 ? 128 : d4i_pip_sides;
    body_length = d4i_body_length * d4i_size;
    
    difference() {
        // Render truncated cube body
        up(edge_rounding)
        minkowski() {
            scale((d4i_size - 2 * edge_rounding) / d4i_size) {
                difference() {
                    // Main body
                    cuboid([d4i_size, body_length, d4i_size], anchor = BOTTOM);
                    
                    // Truncate corners to create infinite-sided appearance
                    translate([d4i_size / 2, body_length / 2, 0])
                    rotate([0, 0, 180])
                        rounding_edge_mask(d4i_size, d4i_size / 2, anchor = BOTTOM);
                    
                    translate([-d4i_size / 2, body_length / 2, 0])
                    rotate([0, 0, 270])
                        rounding_edge_mask(d4i_size, d4i_size / 2, anchor = BOTTOM);
                    
                    translate([-d4i_size / 2, -body_length / 2, 0])
                    rotate([270, 180, -90])
                        rounding_edge_mask(d4i_size, d4i_size / 2, anchor = BOTTOM);
                    
                    translate([-d4i_size / 2, -body_length / 2, d4i_size])
                    rotate([0, 90, 0])
                        rounding_edge_mask(d4i_size, d4i_size / 2, anchor = BOTTOM);
                }
            }
            if (edge_rounding > 0) 
                sphere(r = edge_rounding);
        }
        
        // Render face content
        render_d4i_faces();
    }
}

// Helper module to render face content
module render_d4i_faces() {
    base_rotate = [0, 0, 90, 0, 180, -90];
    d4i_pip_fn = d4i_pip_sides == 0 ? 128 : d4i_pip_sides;
    
    // Numbers and symbols
    regular_polyhedron("cube", side = d4i_size, anchor = BOTTOM, draw = false)
        zrot(d4i_rotate[$faceindex] + base_rotate[$faceindex])
        down(text_depth + d4i_adj_depth[$faceindex])
        linear_extrude(height = 2 * text_depth + d4i_adj_depth[$faceindex])
        move([
            (d4i_text_h_push + d4i_adj_h_push[$faceindex]) * d4i_size / 100,
            (d4i_text_v_push + d4i_adj_v_push[$faceindex]) * d4i_size / 100
        ])
        render_d4i_face_text($faceindex);
        
    // Pips
    regular_polyhedron("cube", side = d4i_size, anchor = BOTTOM, draw = false)
        if (d4i_pips[$faceindex] != "") {
            zrot(d4i_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pips("d4i", d4i_pips[$faceindex], d4i_adj_depth[$faceindex], 
                     d4i_pip_fn, [d4i_pip_size * d4i_size, d4i_pip_offset]);
        }
    
    // Pip symbols
    d4i_pip_syms = fix_quotes(d4i_pip_symbols);
    regular_polyhedron("cube", side = d4i_size, anchor = BOTTOM, draw = false)
        if (d4i_pip_symbol_pos[$faceindex] != "" && d4i_pip_syms[$faceindex] != undef) {
            zrot(d4i_rotate[$faceindex] + base_rotate[$faceindex])
            draw_pip_symbols("d4i", d4i_pip_symbol_pos[$faceindex], 
                           d4i_pip_syms[$faceindex], d4i_pip_symbol_rotate[$faceindex], 
                           d4i_adj_depth[$faceindex], [d4i_pip_size * d4i_size, d4i_pip_offset]);
        }
}

// Helper module for face text rendering
module render_d4i_face_text(face_idx) {
    txt_merged = merge_txt(d4i_text, fix_quotes(d4i_symbols));
    txt_mult = d4i_text_size * d4i_size / 100;
    adj_txt = adj_list(d4i_adj_size, d4i_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d4i_symbol_size * d4i_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    if (is_list(txt_merged[face_idx])) { // Symbol
        move([d4i_symbol_h_push * d4i_size / 100, d4i_symbol_v_push * d4i_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[face_idx][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else if (txt_merged[face_idx] == "4") { // Special handling for number 4
        right(d4i_num_4_h_push * d4i_size / 100)
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    } else { // Other numbers
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    }
}