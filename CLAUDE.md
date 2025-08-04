# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PolyDiceGenerator is a customizable polyhedral dice generator for OpenSCAD that creates 3D printable dice models. The project has been refactored into a modular architecture with the main entry point at `PolyDiceGenerator.scad` and organized modules in the `src/` directory.

## Key Commands and Development Workflow

### Opening and Testing
```bash
# Open the project in OpenSCAD (macOS)
open -a OpenSCAD PolyDiceGenerator.scad

# Run BOSL2 tests
./BOSL2/scripts/run_tests.sh
```

### Development Process
1. Edit `PolyDiceGenerator.scad` or files in `src/` directory
2. Use OpenSCAD's Customizer panel (Window > Customizer) to adjust parameters
3. Preview with F5 (uses $preview mode with faster rendering)
4. Final render with F6 (uses high quality: $fa=2, $fs=0.2)
5. Export STL: File > Export > Export as STL

## Architecture and Code Structure

### Module Organization
- **Entry Point**: `PolyDiceGenerator.scad`
- **Configuration**: `src/config/` - Separated settings files
- **Dice Modules**: `src/dice/` - One file per die type with `draw_d*()` modules
- **Libraries**: `src/lib/` - Shared utilities and helper functions
- Each die type has its own `draw_d*()` module (e.g., `draw_d6()`, `draw_d20()`)
- Face content is distributed using array-based parameters for text, symbols, underscores, and rotation
- All modules follow the pattern: create geometry → apply text/symbols → position in layout

### Key Technical Patterns
- **BOSL2 Dependency**: Uses BOSL2 v2.0.716 for polyhedron manipulation and transformations
- **Face Mapping**: Each die type defines face normals and positions for text placement
- **Customizer Groups**: Parameters organized into sections (Master, d4, d6, etc.) for the OpenSCAD Customizer
- **Conditional Rendering**: Each die type controlled by `draw_d*` boolean parameters

### Adding New Die Types
1. Copy `src/dice/die_template.scad` to `src/dice/dX_name.scad`
2. Implement the `draw_dX()` module and parameters
3. Include the new file in `PolyDiceGenerator.scad`
4. Add to `standard_dice_layout()` in the main rendering section
5. Update `src/config/dice_selection.scad` if needed

## Important Implementation Details

### Text and Symbol Placement
- Text is placed using `linear_extrude()` with calculated face normals
- Symbol fonts (like SWAstro) require special handling for proper rendering
- Face rotation is handled per-face using the rotation distribution lists

### Coordinate System
- Uses BOSL2's movement functions (`move()`, `fwd()`, `back()`, `left()`, `right()`)
- Dice are positioned in a grid layout with configurable spacing
- Z-axis is up, with dice resting on the XY plane

### Performance Considerations
- Preview mode ($preview) uses lower resolution for faster iteration
- Final renders should use $fa=2, $fs=0.2 for smooth surfaces
- Complex dice (d12, d20) with text can take significant time to render

## Key Patterns

### File Naming Convention
- Dice modules: `d{number}_{description}.scad` (e.g., `d6_cube.scad`)
- Config files: descriptive names (e.g., `fonts.scad`, `rendering.scad`)
- Libraries: functional names (e.g., `utilities.scad`, `pip_drawing.scad`)

### Variable Scoping
- Configuration variables are included globally
- Die-specific parameters defined at the top of each die module
- Helper functions use local variables to avoid conflicts

### BOSL2 Special Variables
- `$faceindex` is only available within `regular_polyhedron()` with `draw=false`
- Always use `$faceindex` directly within the polyhedron's children blocks
- Define helper variables like `base_rotate` within render modules