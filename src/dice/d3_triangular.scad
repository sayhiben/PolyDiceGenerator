// D3 Triangular Prism Die Module
// A three-sided die with rounded triangular prism shape

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D3 specific configuration parameters
d3_size = 16;
d3_text_size = 36;
d3_text_v_push = 30;
d3_text_h_push = 0;
d3_text = ["1", "2", "3", "1", "2", "3"];
d3_symbols = [undef, undef, undef, undef, undef, undef];
d3_symbol_size = 36;
d3_symbol_v_push = 0;
d3_symbol_h_push = 0;
d3_rotate = [0, 0, 0, 0, 0, 0];
d3_adj_size = [0, 0, 0, 0, 0, 0];
d3_adj_v_push = [0, 0, 0, 0, 0, 0];
d3_adj_h_push = [0, 0, 0, 0, 0, 0];
d3_adj_depth = [0, 0, 0, 0, 0, 0];

// Main D3 drawing module
module draw_d3() {
    // Prepare text and symbols
    txt_merged = merge_txt(d3_text, fix_quotes(d3_symbols));
    txt_mult = d3_text_size * d3_size / 100;
    adj_txt = adj_list(d3_adj_size, d3_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d3_symbol_size * d3_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    base_rotate = [0, 180, 0, 180, 0, 180];
    
    // Geometry calculations
    d3_side = d3_size * 2 / sqrt(3);
    d3_circum_rad = d3_side * sqrt(3) / 3;
    
    difference() {
        // Render triangular prism body
        up(edge_rounding)
        minkowski() {
            scale((d3_size - 2 * edge_rounding) / d3_size) {
                intersection() {
                    translate([0, 0, d3_circum_rad / 2])
                        sphere(r = d3_circum_rad);
                    translate([0, 0, 0]) 
                    rotate([0, 0, 90])
                        prismoid(size1 = [d3_side, d3_side * 1.4], 
                                size2 = [0, d3_side * 1.4], 
                                h = d3_size);
                }
            }
            if (edge_rounding > 0) 
                sphere(r = edge_rounding);
        }
        
        // Render numbers & symbols on faces
        for (j = [0:2]) {
            translate([0, 0, d3_circum_rad / 2])
            for (i = [0:1]) {
                rotate([120 * j, 0, 0])
                translate([0, 0, -d3_circum_rad / 2])
                rotate([0, 180, 0])
                zrot(d3_rotate[j * 2 + i] + base_rotate[j * 2 + i])
                down(text_depth + d3_adj_depth[j * 2 + i])
                linear_extrude(height = 2 * text_depth + d3_adj_depth[j * 2 + i])
                move([
                    (d3_text_h_push + d3_adj_h_push[j * 2 + i]) * d3_size / 100,
                    (d3_text_v_push + d3_adj_v_push[j * 2 + i]) * d3_size / 100
                ])
                render_d3_face_text(j * 2 + i);
            }
        }
    }
}

// Helper module for face text rendering
module render_d3_face_text(face_idx) {
    txt_merged = merge_txt(d3_text, fix_quotes(d3_symbols));
    txt_mult = d3_text_size * d3_size / 100;
    adj_txt = adj_list(d3_adj_size, d3_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d3_symbol_size * d3_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    if (is_list(txt_merged[face_idx])) { // Symbol
        move([d3_symbol_h_push * d3_size / 100, d3_symbol_v_push * d3_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[face_idx][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else { // Number
        offset(delta = txt_stroke)
        text(txt_merged[face_idx], size = txt_mult + adj_txt[face_idx], 
             font = text_font, halign = "center", valign = "center");
    }
}