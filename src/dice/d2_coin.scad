// D2 Coin Die Module
// A customizable two-sided coin die

include <../lib/utilities.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// D2 specific configuration parameters
d2_size = 24;
d2_sides = 10; //[0,3,4,5,6,8,10,12]
d2_height = 3;
d2_text_size = 45;
d2_text_v_push = 0;
d2_text_h_push = 0;
d2_text = ["1", "2"];
d2_symbols = [undef, undef];
d2_symbol_size = 34;
d2_symbol_v_push = 0;
d2_symbol_h_push = 0;
d2_rotate = [0, 0];
d2_adj_size = [0, 0];
d2_adj_v_push = [0, 0];
d2_adj_h_push = [0, 0];
d2_adj_depth = [0, 0];

// Main D2 drawing module
module draw_d2() {
    // Prepare text and symbols
    txt_merged = merge_txt(d2_text, fix_quotes(d2_symbols));
    txt_mult = d2_text_size * d2_size / 100;
    adj_txt = adj_list(d2_adj_size, d2_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = d2_symbol_size * d2_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    base_rotate = [180, 180];
    d2_fn = d2_sides == 0 ? 128 : d2_sides;
    
    difference() {
        // Render cylinder body
        up(edge_rounding)
        minkowski() {
            scale((d2_size - 2 * edge_rounding) / d2_size) {
                linear_extrude(height = d2_height)
                    circle(d = d2_size, $fn = d2_fn);
            }
            if (edge_rounding > 0) 
                sphere(r = edge_rounding);
        }
        
        // Render face content (numbers & symbols)
        for (i = [0, 1]) {
            rotate([180, 0, 0]) 
            rotate([180 * i, 0, 0])
            translate([0, 0, d2_height * i + edge_rounding * 2 * i])
            down(text_depth + d2_adj_depth[i])
            linear_extrude(height = 2 * text_depth + d2_adj_depth[i])
            move([
                (d2_text_h_push + d2_adj_h_push[i]) * d2_size / 100,
                (d2_text_v_push + d2_adj_v_push[i]) * d2_size / 100
            ])
            if (is_list(txt_merged[i])) { // Symbol
                move([d2_symbol_h_push * d2_size / 100, d2_symbol_v_push * d2_size / 100])
                zrot(d2_rotate[i] + base_rotate[i])
                offset(delta = sym_stroke)
                text(txt_merged[i][0], size = sym_mult, font = symbol_font, 
                     halign = "center", valign = "center");
            } else { // Number
                zrot(d2_rotate[i] + base_rotate[i])
                offset(delta = txt_stroke)
                text(txt_merged[i], size = txt_mult + adj_txt[i], font = text_font, 
                     halign = "center", valign = "center");
            }
        }
    }
}