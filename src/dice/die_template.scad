// DX Name Die Module Template
// Description of the die type

include <../lib/utilities.scad>
include <../lib/die_base.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// DX specific configuration parameters
dx_size = 15;                     // Base size of the die
dx_text_size = 40;                // Text size percentage
dx_text_v_push = 0;               // Vertical text adjustment
dx_text_h_push = 0;               // Horizontal text adjustment
dx_text = ["1", "2", "3", ...];  // Face text/numbers
dx_symbols = [undef, undef, ...]; // Optional symbols per face
dx_symbol_size = 50;              // Symbol size percentage
dx_symbol_v_push = 0;             // Vertical symbol adjustment
dx_symbol_h_push = 0;             // Horizontal symbol adjustment
dx_rotate = [0, 0, 0, ...];       // Per-face rotation adjustments
dx_bumpers = [undef, undef, ...]; // Bumper flags per face
dx_adj_size = [0, 0, 0, ...];     // Per-face size adjustments
dx_adj_v_push = [0, 0, 0, ...];   // Per-face vertical adjustments
dx_adj_h_push = [0, 0, 0, ...];   // Per-face horizontal adjustments
dx_adj_depth = [0, 0, 0, ...];    // Per-face depth adjustments

// Additional die-specific parameters
// dx_special_param = value;

// Main DX drawing module
module draw_dx() {
    // Prepare text and symbols
    txt_merged = merge_txt(dx_text, fix_quotes(dx_symbols));
    txt_mult = dx_text_size * dx_size / 100;
    adj_txt = adj_list(dx_adj_size, dx_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = dx_symbol_size * dx_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    bumpers = fix_quotes(dx_bumpers);
    
    // Die-specific calculations
    base_rotate = [0, 0, 0, ...];  // Base rotation for each face
    // Add geometry calculations here
    
    difference() {
        // Render die body
        render_dx_body();
        
        // Render face content
        render_dx_faces();
    }
}

// Helper module to render die body
module render_dx_body() {
    if (add_bumpers && edge_rounding == 0 && corner_rounding == 0 && corner_clipping == 0) {
        // Render with bumpers
        union() {
            // Base polyhedron
            regular_polyhedron("shape", side = dx_size, anchor = BOTTOM);
            // Add bumpers
            regular_polyhedron("shape", side = dx_size, anchor = BOTTOM, 
                             rotate_children = false, draw = false)
                if (bumpers[$faceindex]) 
                    stroke($face, width = bumper_size, closed = true);
        }
    } else if (edge_rounding == 0 && (corner_rounding > 0 || corner_clipping > 0)) {
        // Render with corner modifications
        apply_corner_modifications("shape", dx_size, corner_rounding, corner_clipping) {
            regular_polyhedron("shape", side = dx_size, anchor = BOTTOM);
        }
    } else {
        // Standard polyhedron with optional edge rounding
        regular_polyhedron("shape", side = dx_size, anchor = BOTTOM, 
                         rounding = edge_rounding);
    }
}

// Helper module to render face content
module render_dx_faces() {
    regular_polyhedron("shape", side = dx_size, anchor = BOTTOM, draw = false) {
        // Calculate face-specific values
        face_rotation = dx_rotate[$faceindex] + base_rotate[$faceindex];
        face_depth = text_depth + dx_adj_depth[$faceindex];
        h_offset = (dx_text_h_push + dx_adj_h_push[$faceindex]) * dx_size / 100;
        v_offset = (dx_text_v_push + dx_adj_v_push[$faceindex]) * dx_size / 100;
        
        // Render content
        zrot(face_rotation)
        down(face_depth)
        linear_extrude(height = 2 * face_depth)
        move([h_offset, v_offset])
        render_dx_face_text();
    }
}

// Helper module for face text rendering
module render_dx_face_text() {
    txt_merged = merge_txt(dx_text, fix_quotes(dx_symbols));
    txt_mult = dx_text_size * dx_size / 100;
    adj_txt = adj_list(dx_adj_size, dx_size / 100);
    txt_stroke = text_stroke * txt_mult;
    sym_mult = dx_symbol_size * dx_size / 100;
    sym_stroke = symbol_stroke * sym_mult;
    
    if (is_list(txt_merged[$faceindex])) { // Symbol
        move([dx_symbol_h_push * dx_size / 100, dx_symbol_v_push * dx_size / 100])
        offset(delta = sym_stroke)
        text(txt_merged[$faceindex][0], size = sym_mult, font = symbol_font, 
             halign = "center", valign = "center");
    } else { // Text/Number
        offset(delta = txt_stroke)
        text(txt_merged[$faceindex], size = txt_mult + adj_txt[$faceindex], 
             font = text_font, halign = "center", valign = "center");
    }
}