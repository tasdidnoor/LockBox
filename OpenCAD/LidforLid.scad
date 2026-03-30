// ============================================================
// PhoneLock - Outer Cover (goes over the flat lid)
// Same footprint as tray, 1 inch tall, open bottom, hollow
// All dimensions in mm. Inches converted at 25.4mm = 1 inch.
// ============================================================

// --- Parameters ---
wall            = 3;          // side wall thickness (mm)
top_thickness   = 1;          // top face thickness (mm)
in2mm           = 25.4;

// Must match component tray exactly
outer_w    = 6.7  * in2mm;   // 170.18 mm  (X)
outer_d    = 6.7  * in2mm;   // 170.18 mm  (Y)
outer_h    = 1.0  * in2mm;   //  25.40 mm  (Z) - 1 inch tall

// Screw boss parameters — must match component tray exactly
boss_r     = 4;               // outer radius of corner screw boss
screw_r    = 1.5;             // M3 screw hole

// ============================================================
// MODULE: Corner screw bosses
// ============================================================
module screw_bosses() {
    offsets = [
        [wall + boss_r,           wall + boss_r          ],
        [outer_w - wall - boss_r, wall + boss_r          ],
        [wall + boss_r,           outer_d - wall - boss_r],
        [outer_w - wall - boss_r, outer_d - wall - boss_r]
    ];
    for (o = offsets) {
        translate([o[0], o[1], 0])
            difference() {
                cylinder(r = boss_r, h = outer_h - top_thickness, $fn = 24);
                translate([0, 0, -1])
                    cylinder(r = screw_r, h = outer_h + 2, $fn = 18);
            }
    }
}

// ============================================================
// MAIN: Outer Cover
// ============================================================
module outer_cover() {
    difference() {

        // --- Outer shell ---
        cube([outer_w, outer_d, outer_h]);

        // --- Hollow interior (open bottom) ---
        translate([wall, wall, 0])
            cube([
                outer_w - 2 * wall,
                outer_d - 2 * wall,
                outer_h - top_thickness   // leaves top_thickness solid on top
            ]);

        // --- 4 screw holes through the top face ---
        offsets = [
            [wall + boss_r,           wall + boss_r          ],
            [outer_w - wall - boss_r, wall + boss_r          ],
            [wall + boss_r,           outer_d - wall - boss_r],
            [outer_w - wall - boss_r, outer_d - wall - boss_r]
        ];
        for (o = offsets) {
            translate([o[0], o[1], outer_h - top_thickness - 1])
                cylinder(r = screw_r, h = top_thickness + 2, $fn = 18);
        }

    }

    // --- Screw bosses inside ---
    screw_bosses();
}

// ============================================================
// RENDER
// ============================================================
outer_cover();