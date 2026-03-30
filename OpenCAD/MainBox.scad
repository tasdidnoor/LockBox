// ============================================================
// PhoneLock - Main Box (bottom part, phone sits inside)
// All dimensions in mm. Inches converted at 25.4mm = 1 inch.
// ============================================================

// --- Parameters ---
wall       = 3;
in2mm      = 25.4;

// Footprint — same as component tray
outer_w    = 6.7  * in2mm;   // 170.18 mm  (X)
outer_d    = 6.7  * in2mm;   // 170.18 mm  (Y)
outer_h    = 4.0  * in2mm;   // 101.60 mm  (Z) - 4 inches tall

// Servo latch hole on front wall (y=0)
servo_hole_w   = 2.0  * in2mm;   // 50.80 mm  horizontal
servo_hole_h   = 0.5  * in2mm;   // 12.70 mm  vertical
servo_hole_z   = outer_h - wall - servo_hole_h - 0.5;  // near top edge, 5mm from top

// Hinge parameters — must match component tray exactly
hinge_r         = 5;
hinge_pin_r     = 2;
hinge_knuckle_h = 14;
hinge_gap       = 0.3;
hinge_inset     = 20;

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
// MODULE: Middle knuckle strip (knuckle 2 only)
// Slots between knuckles 1 & 3 on the component tray
// ============================================================
module hinge_strip_box() {
    // Only the middle knuckle — sits in the gap between tray's knuckles
    translate([0, 0, hinge_knuckle_h + hinge_gap])
        knuckle(hinge_knuckle_h);
}

// ============================================================
// MAIN: Box
// ============================================================
module main_box() {
    difference() {

        // --- Outer shell ---
        cube([outer_w, outer_d, outer_h]);

        // --- Hollow interior (open top) ---
        translate([wall, wall, wall])
            cube([
                outer_w - 2 * wall,
                outer_d - 2 * wall,
                outer_h              // cut all the way up — open top
            ]);

        // --- Servo latch hole on front wall, near top ---
        translate([
            outer_w / 2 - servo_hole_w / 2,
            -1,
            servo_hole_z
        ])
            cube([servo_hole_w, wall + 2, servo_hole_h]);

    }

    // --- Middle knuckle hinges on back wall ---
    difference() {
        union() {
            // Hinge 1 — middle knuckle
            translate([
                hinge_inset,
                outer_d,
                outer_h - wall - hinge_r
            ])
                rotate([0, 90, 0])
                    hinge_strip_box();

            // Hinge 2 — middle knuckle
            translate([
                outer_w - hinge_inset - hinge_r * 8,
                outer_d,
                outer_h - wall - hinge_r
            ])
                rotate([0, 90, 0])
                    hinge_strip_box();
        }

        // Clip anything intruding inside the box
        cube([outer_w, outer_d - wall, outer_h + 10]);
    }
}

// ============================================================
// RENDER
// ============================================================
main_box();