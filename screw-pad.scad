include <libs/BOSL/constants.scad>
use <libs/BOSL/threading.scad>

use <libs/knurledFinishLib_v2.scad>


height            = 15;
material_strength =  2.5;
head_height       =  5;

outer_diameter = 30;
inner_diameter = outer_diameter - 2 * material_strength;

thread_height = height - material_strength;
thread_pitch  = 2;

offset_x = outer_diameter * 0.75;


$fn = 360;


nut();
screw();


module nut() {
    translate([-offset_x, 0, 0])
    union() {
        // Base
        difference() {
            cylinder(
                // Don't use full outer diamter, to leave some room for the
                // knurling we add below.
                d = outer_diameter - material_strength,
                h = material_strength
            );
            mark();
        }

        translate([0, 0, material_strength])
        difference() {
            // The internal thread, plus some superfluous geometry we'll be
            // removing in the next step.
            //
            // TASK: This bevels the thread on both sides, although that's only
            //       necessary on the upper side. According to the
            //       documentation, there should be separate `bevel1` and
            //       `bevel2` arguments to enable this, but those don't actually
            //       exist.
            buttress_threaded_nut(
                od     = outer_diameter,
                id     = inner_diameter,
                h      = thread_height,
                pitch  = thread_pitch,
                bevel  = true,
                orient = ORIENT_ZNEG,
                align  = V_UP
            );

            // BOSL generates an actual hexagonal nut, which is not what we
            // want. Let's make it a cylinder.
            difference() {
                cylinder(
                    d = outer_diameter * 2,
                    h = thread_height
                );
                cylinder(
                    // Remove more than we have to, to make some room for the
                    // knurling we add below.
                    d = outer_diameter - material_strength,
                    h = thread_height
                );
            }
        }

        // Add knurling.
        difference() {
            cyl_knurled(
                d = outer_diameter,
                h = height
            );
            cylinder(
                d = outer_diameter - material_strength,
                h = height
            );
        }
    }
}

module screw() {
    translate([offset_x, 0, 0])
    difference() {
        union() {
            // The head.
            cyl_knurled(
                d = outer_diameter,
                h = head_height
            );

            // The screw threads.
            translate([0, 0, head_height])
            buttress_threaded_rod(
                d      = inner_diameter,
                l      = thread_height,
                pitch  = thread_pitch,
                bevel2 = true,
                orient = ORIENT_Z,
                align  = V_UP
            );
        }

        // Hollow out the screw, to save material.
        translate([0, 0, material_strength])
        cylinder(
            // We subtract the thread pitch, but we actually need to subtract
            // the height. Still, this should be a good enough approximation.
            d = inner_diameter - 2 * thread_pitch - material_strength,
            h = head_height + thread_height - material_strength
        );
    }
}

module cyl_knurled(d, h) {
    knurled_cyl(
        chg = h,
        cod = d,

        // Knurling parameters
        cwd = 2, // polyhedron width
        csh = 2, // polyhedron height
        cdp = 1, // polyhedron depth
        fsh = 2, // cylinder ends smoothed height
        smt = 0  // knurled surface smoothing amount
    );
}

module mark() {
    lines = [
        "Screw Pad",
        "Hanno Braun",
        "2021-W51 · #4",
        "Made in",
        "Odenwald",
    ];

    size = 2.5;

    linear_extrude(1)
    mirror([1, 0, 0])
    union() {
        for (i = [0 : len(lines) - 1]) {
            translate([0, -(i - 2.0) * size * 1.5, 0])
            text(
                lines[i],
                size = size,
                font = "osifont",
                halign = "center",
                valign = "center"
            );
        }
    }
}
