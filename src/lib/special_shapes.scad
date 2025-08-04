// Special shape modules for PolyDiceGenerator
// Custom polyhedra and shapes not included in BOSL2

// Pentagonal antiprism for corner clipping
module pentagonal_antiprism(size) {
    C0 = (1 + sqrt(5)) / 4; // midradius ≈0.80901699437
    C1 = sqrt(5 * (5 + 2 * sqrt(5))) / 10; // inradius ≈0.68819096024
    C2 = sqrt((5 - sqrt(5)) / 40); // ≈0.26286555606
    P0 = sqrt(10 * (5 + sqrt(5))) / 20; // pentagon center radius ≈0.42532540418
    
    scale([size, size, size * 1.8])
    polyhedron(
        points = [
            [-C0, -C2, -P0],
            [-C0,  C2,  P0],
            [-0.5, -C1,  P0],
            [-0.5,  C1, -P0],
            [   0, -P0 * 2, -P0],
            [   0,  P0 * 2,  P0],
            [ 0.5, -C1,  P0],
            [ 0.5,  C1, -P0],
            [  C0, -C2, -P0],
            [  C0,  C2,  P0]
        ],
        faces = [
            [4, 8, 7], [3, 4, 7],
            [4, 3, 0], [6, 2, 1],
            [5, 6, 1], [6, 5, 9],
            [3, 5, 1], [3, 1, 0],
            [0, 1, 2], [0, 2, 4],
            [4, 2, 6], [4, 6, 8],
            [8, 6, 9], [8, 9, 7],
            [7, 9, 5], [7, 5, 3]
        ]
    );
}