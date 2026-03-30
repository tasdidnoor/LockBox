// ============================================================
// PhoneLock - Component Tray (Acts as the main box lid)
// All dimensions in mm. Inches converted at 25.4mm = 1 inch.
// ============================================================

// --- Parameters ---
wall       = 3;
in2mm      = 25.4;

// Outer footprint
outer_w    = 6.7  * in2mm;   // 175.26 mm  (X)
outer_d    = 6.7  * in2mm;   // 175.26 mm  (Y)
inner_h    = 1.0  * in2mm;   //  50.80 mm  (Z) - interior height
outer_h    = inner_h + wall; //  53.80 mm  total tray height

// Servo slot in floor
slot_w     = 1.0  * in2mm;   //  25.40 mm
slot_d     = 0.5  * in2mm;   //  12.70 mm

// Hinge parameters
hinge_r         = 5;          // knuckle outer radius (mm)
hinge_pin_r     = 2;          // pin hole radius (mm)
hinge_knuckle_h = 14;         // height of each individual knuckle segment
hinge_gap       = 0.3;        // clearance between knuckles for printing
hinge_inset     = 20;         // how far from each corner the hinges sit

// Screw boss parameters (for flat lid attachment later)
boss_r     = 4;               // outer radius of corner screw boss
boss_h     = inner_h;         // full interior height
screw_r    = 1.5;             // M3 screw hole

// ============================================================
// MODULE: Single knuckle segment
// ============================================================
module knuckle(h) {
    difference() {
        cylinder(r = hinge_r, h = h, $fn = 32);
        cylinder(r = hinge_pin_r, h = h + 1, $fn = 20);
    }
}

// ============================================================
// MODULE: Full hinge strip (3 knuckles)
// Tray owns knuckles 1 & 3
// Main box will own knuckle 2 (middle)
// ============================================================
module hinge_strip() {
    // Knuckle 1 (tray — first)
    translate([0, 0, 0])
        knuckle(hinge_knuckle_h);

    // Knuckle 2 gap (reserved for main box knuckle)

    // Knuckle 3 (tray — second)
    translate([0, 0, hinge_knuckle_h + hinge_gap + hinge_knuckle_h + hinge_gap])
        knuckle(hinge_knuckle_h);
}

// ============================================================
// MODULE: Corner screw bosses (4 corners, inside the tray)
// ============================================================
module screw_bosses() {
    offsets = [
        [wall + boss_r,           wall + boss_r          ],
        [outer_w - wall - boss_r, wall + boss_r          ],
        [wall + boss_r,           outer_d - wall - boss_r],
        [outer_w - wall - boss_r, outer_d - wall - boss_r]
    ];
    for (o = offsets) {
        translate([o[0], o[1], wall])
            difference() {
                cylinder(r = boss_r, h = boss_h, $fn = 24);
                translate([0, 0, -1])
                    cylinder(r = screw_r, h = boss_h + 2, $fn = 18);
            }
    }
}

// ============================================================
// MAIN: Component Tray
// ============================================================
module component_tray() {
    difference() {

        // --- Outer shell ---
        cube([outer_w, outer_d, outer_h]);

        // --- Hollow interior (open top) ---
        translate([wall, wall, wall])
            cube([
                outer_w - 2 * wall,
                outer_d - 2 * wall,
                outer_h
            ]);

        // --- Servo slot in floor ---
        translate([
            outer_w / 2 - slot_w / 2,
            0,
            -1
        ])
            cube([slot_w, slot_d, wall + 2]);

    }

    // --- Screw bosses for flat lid ---
    screw_bosses();

    // --- Knuckle hinges on back wall ---
    // --- Knuckle hinges on back wall (clipped flush with inner wall) ---
    difference() {
        union() {
            // Hinge 1
            translate([
                hinge_inset,
                outer_d,
                wall + hinge_r
            ])
                rotate([0, 90, 0])
                    hinge_strip();

            // Hinge 2
            translate([
                outer_w - hinge_inset - hinge_r * 8,
                outer_d,
                wall + hinge_r
            ])
                rotate([0, 90, 0])
                    hinge_strip();
        }

        // Clip anything that intrudes inside the box
        translate([0, 0, 0])
            cube([outer_w, outer_d - wall, outer_h + 10]);
    }
}

// ============================================================
// RENDER
// ============================================================
component_tray();