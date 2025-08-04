// Base die functionality for PolyDiceGenerator
// Common functions and modules shared by all die types

include <utilities.scad>
include <../config/fonts.scad>
include <../config/global_settings.scad>

// Render text on a die face with proper depth and styling
module render_die_text(text_content, size_mult, font_type, h_offset = 0, v_offset = 0, 
                      rotation = 0, stroke_width = 0, depth_offset = 0) {
    zrot(rotation)
    down(text_depth + depth_offset)
    linear_extrude(height = 2 * text_depth + depth_offset)
    move([h_offset, v_offset])
    offset(delta = stroke_width)
    text(text_content, size = size_mult, font = font_type, 
         halign = "center", valign = "center");
}

// Render content (text or symbol) on a die face
module render_face_content(content, is_symbol, text_params, symbol_params, 
                          rotation = 0, depth_offset = 0) {
    if (is_symbol) {
        render_die_text(
            content[0], 
            symbol_params[0],  // size
            symbol_font,
            symbol_params[1],  // h_offset
            symbol_params[2],  // v_offset
            rotation,
            symbol_params[3],  // stroke
            depth_offset
        );
    } else {
        render_die_text(
            content,
            text_params[0],    // size
            text_font,
            text_params[1],    // h_offset
            text_params[2],    // v_offset
            rotation,
            text_params[3],    // stroke
            depth_offset
        );
    }
}

// Apply edge rounding to a polyhedron
module apply_edge_rounding(die_shape, size, rounding = 0) {
    if (rounding > 0) {
        minkowski() {
            scale((size - 2 * rounding) / size)
                children();
            sphere(r = rounding);
        }
    } else {
        children();
    }
}

// Apply corner modifications (rounding or clipping)
module apply_corner_modifications(die_shape, size, corner_round = 0, corner_clip = 0) {
    if (corner_round > 0 || corner_clip > 0) {
        circumsphere_dia = calculate_circumsphere(die_shape, size);
        corner_round_mult = circumsphere_dia - (corner_round * circumsphere_dia / 100) / 1.8;
        dual_mult = calculate_dual_mult(die_shape, size);
        corner_clip_mult = dual_mult - (corner_clip * dual_mult / 100) / 1.8;
        
        intersection() {
            children();
            if (corner_round > 0) {
                translate([0, 0, size / 2])
                    sphere(d = corner_round_mult);
            } else if (corner_clip > 0) {
                translate([0, 0, size / 2])
                    regular_polyhedron("octahedron", side = corner_clip_mult, 
                                     facedown = false);
            }
        }
    } else {
        children();
    }
}

// Calculate circumsphere diameter for different die shapes
function calculate_circumsphere(shape, size) = 
    shape == "cube" ? size * sqrt(3) :
    shape == "tetrahedron" ? size * sqrt(6) / 2 :
    shape == "octahedron" ? size * sqrt(2) :
    shape == "dodecahedron" ? size * (sqrt(3) * (1 + sqrt(5)) / 2) :
    shape == "icosahedron" ? size * sqrt(10 + 2 * sqrt(5)) / 2 :
    size; // Default

// Calculate dual multiplier for different die shapes
function calculate_dual_mult(shape, size) = 
    shape == "cube" ? size * (3 * sqrt(2) / 2) :
    shape == "tetrahedron" ? size * sqrt(2/3) :
    shape == "octahedron" ? size :
    shape == "dodecahedron" ? size * sqrt(3) :
    shape == "icosahedron" ? size * (sqrt(5) + 1) / 2 :
    size; // Default

// Add bumpers to die edges
module add_die_bumpers(die_shape, size, bumper_flags) {
    union() {
        children();
        regular_polyhedron(die_shape, side = size, anchor = BOTTOM, 
                         rotate_children = false, draw = false)
            if (bumper_flags[$faceindex]) 
                stroke($face, width = bumper_size, closed = true);
    }
}

// Process face adjustments
function process_face_adjustments(base_value, adj_list, face_index, size_factor = 1) = 
    base_value + (adj_list[face_index] * size_factor);

// Prepare text parameters for rendering
function prepare_text_params(base_size, size_mult, h_push, v_push, adj_params, face_idx) = [
    base_size * size_mult + adj_params[0][face_idx],                    // size
    (h_push + adj_params[1][face_idx]) * size_mult,                     // h_offset
    (v_push + adj_params[2][face_idx]) * size_mult,                     // v_offset
    text_stroke * (base_size * size_mult)                               // stroke
];

// Prepare symbol parameters for rendering
function prepare_symbol_params(base_size, size_mult, h_push, v_push, adj_params, face_idx) = [
    base_size * size_mult,                                               // size
    (h_push + adj_params[1][face_idx]) * size_mult,                     // h_offset
    (v_push + adj_params[2][face_idx]) * size_mult,                     // v_offset
    symbol_stroke * (base_size * size_mult)                             // stroke
];