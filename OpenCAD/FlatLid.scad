// ============================================================
// PhoneLock - Flat Lid (screws onto the open top of component tray)
// All dimensions in mm. Inches converted at 25.4mm = 1 inch.
// ============================================================

// --- Parameters ---
wall       = 3;
in2mm      = 25.4;

// Must match component tray exactly
outer_w    = 6.7  * in2mm;   // 170.18 mm  (X)
outer_d    = 6.7  * in2mm;   // 170.18 mm  (Y)

// Screw boss parameters — must match component tray exactly
boss_r     = 4;               // outer radius of corner screw boss
screw_r    = 1.5;             // M3 screw hole

// Lid
lid_thickness = 0.5;            // mm

// ============================================================
// MAIN: Flat Lid
// ============================================================
module flat_lid() {
    difference() {
        // --- Flat plate, same footprint as tray ---
        cube([outer_w, outer_d, lid_thickness]);

        // --- Screw holes, matching boss positions exactly ---
        offsets = [
            [wall + boss_r,           wall + boss_r          ],
            [outer_w - wall - boss_r, wall + boss_r          ],
            [wall + boss_r,           outer_d - wall - boss_r],
            [outer_w - wall - boss_r, outer_d - wall - boss_r]
        ];
        for (o = offsets) {
            translate([o[0], o[1], -1])
                cylinder(r = screw_r, h = lid_thickness + 2, $fn = 18);
        }
    }
}

// ============================================================
// RENDER
// ============================================================
flat_lid();