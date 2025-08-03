# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PolyDiceGenerator is a customizable polyhedral dice generator for OpenSCAD that creates 3D printable dice models. The entire application is contained in a single file: `PolyDiceGenerator.scad`.

## Key Commands and Development Workflow

### Opening and Testing
```bash
# Open the project in OpenSCAD (macOS)
open -a OpenSCAD PolyDiceGenerator.scad

# Run BOSL2 tests
./BOSL2/scripts/run_tests.sh
```

### Development Process
1. Edit `PolyDiceGenerator.scad` in OpenSCAD or your preferred editor
2. Use OpenSCAD's Customizer panel (Window > Customizer) to adjust parameters
3. Preview with F5 (uses $preview mode with faster rendering)
4. Final render with F6 (uses high quality: $fa=2, $fs=0.2)
5. Export STL: File > Export > Export as STL

## Architecture and Code Structure

### Module Organization
- Each die type has its own `drawd*()` module (e.g., `drawd6()`, `drawd20()`)
- Face content is distributed using array-based parameters for text, symbols, underscores, and rotation
- All modules follow the pattern: create geometry → apply text/symbols → position in layout

### Key Technical Patterns
- **BOSL2 Dependency**: Uses BOSL2 v2.0.716 for polyhedron manipulation and transformations
- **Face Mapping**: Each die type defines face normals and positions for text placement
- **Customizer Groups**: Parameters organized into sections (Master, d4, d6, etc.) for the OpenSCAD Customizer
- **Conditional Rendering**: Each die type controlled by `draw_d*` boolean parameters

### Adding New Die Types
1. Add `draw_dX` boolean parameter in the appropriate Customizer group
2. Create corresponding parameters for size, text, symbols, etc.
3. Implement `drawdX()` module following existing patterns
4. Add to the main rendering section with appropriate positioning

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