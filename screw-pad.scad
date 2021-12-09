include <BOSL/constants.scad>
use <BOSL/threading.scad>

height            = 15;
material_strength = 2.5;
head_height       = 5;

outer_diameter = 30;
inner_diameter = outer_diameter - material_strength;

thread_height = height - material_strength;
thread_pitch  = 2;


nut();
screw();


module nut() {
    union() {
        cylinder(
            d = outer_diameter * 1.2,
            h = material_strength,
            $fn = 360
        );

        translate([0, 0, material_strength])
        // TASK: This bevels the thread on both sides, although that's only
        //       necessary on the upper side. According to the documentation,
        //       there should be separate `bevel1` and `bevel2` arguments to
        //       enable this, but those don't actually exist.
        buttress_threaded_nut(
            od     = outer_diameter,
            id     = inner_diameter,
            h      = thread_height,
            pitch  = thread_pitch,
            bevel  = true,
            orient = ORIENT_ZNEG,
            align  = V_UP
        );
    }
}

module screw() {
    translate([50, 0, 0])
    union() {
        cylinder(
            d   = outer_diameter,
            h   = head_height,
            $fn = 360
        );

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
}
