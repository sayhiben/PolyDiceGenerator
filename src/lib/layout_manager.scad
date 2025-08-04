// Layout Manager for PolyDiceGenerator
// Handles positioning of dice in a grid layout

include <../config/global_settings.scad>

// Layout configuration
layout_spacing = 40; // Default spacing between dice

// Position a die at a specific grid location
module position_die(x, y, die_module) {
    translate([x * layout_spacing, y * layout_spacing, 0])
        children();
}

// Create a grid layout for multiple dice
module dice_grid(dice_positions) {
    for (pos = dice_positions) {
        if (pos[2]) { // Check if die should be drawn
            position_die(pos[0], pos[1])
                children(pos[3]);
        }
    }
}

// Standard layout positions for all dice types
module standard_dice_layout(
    draw_d2, draw_d3, draw_d4, draw_d4c, draw_d4i, draw_d4p,
    draw_d6, draw_d8, draw_d10, draw_d00, draw_d12, draw_d12r,
    draw_d16, draw_d20
) {
    // Row 1
    if (draw_d2) move([spacing, -spacing]) children(0);       // d2
    if (draw_d3) move([-spacing, -spacing * 2]) children(1);  // d3
    if (draw_d4c) move([-spacing, -spacing]) children(2);     // d4c
    
    // Row 2
    if (draw_d4) fwd(spacing) children(3);                    // d4
    if (draw_d6) children(4);                                 // d6 (center)
    if (draw_d10) move([-spacing, spacing]) children(5);      // d10
    
    // Row 3
    if (draw_d4i) move([spacing, -spacing * 2]) children(6);  // d4i
    if (draw_d8) back(spacing) children(7);                   // d8
    if (draw_d12) move([spacing, spacing]) children(8);       // d12
    
    // Row 4
    if (draw_d4p) fwd(spacing * 2) children(9);               // d4p
    if (draw_d12r) back(spacing * 2) children(10);            // d12r
    if (draw_d20) right(spacing) children(11);                // d20
    
    // Additional dice
    if (draw_d00) move([spacing * 2, spacing]) children(12);  // d00
    if (draw_d16) move([-spacing * 2, 0]) children(13);       // d16
}

// Alternative compact layout
module compact_dice_layout(dice_list, columns = 4) {
    count = len(dice_list);
    for (i = [0 : count - 1]) {
        if (dice_list[i]) {
            x = (i % columns) - columns / 2;
            y = floor(i / columns) - floor(count / columns) / 2;
            position_die(x, y)
                children(i);
        }
    }
}

// Custom layout with explicit positions
module custom_dice_layout(positions) {
    for (i = [0 : len(positions) - 1]) {
        if (positions[i] != undef) {
            translate([positions[i][0], positions[i][1], positions[i][2] ? positions[i][2] : 0])
                children(i);
        }
    }
}