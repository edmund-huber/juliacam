$fs = 0.1;
body_r = 5;
body_w = 100 - (2 * body_r);
body_d = 30 - (2 * body_r);
body_h = 50 - (2 * body_r);
module BodyBox(radius) {
    minkowski() {
        translate([body_r, body_r, body_r])
            sphere(radius);
        cube([body_w, body_d, body_h]);
    }
}

module Body() {
    difference() {
        BodyBox(body_r);
        BodyBox(body_r - 3);
        translate([(body_w+10)/2, 5, (body_h+10)/2])
            rotate([90, 0, 0])
            cylinder(10, 20, 20);
        translate([20, (body_d+10)/2, body_h+5])
            cylinder(h=10, r=5);
    }
}

module Viewfinder() {
    // viewfinder
    difference() {
        minkowski() {
            translate([body_w-15, 0, body_h-10])
                cube([15, body_d+10, 10]);
                sphere(2);
        }
        // Punch out the viewfinder.
        translate([body_w-15, -10, body_h-10])
            cube([13, body_d+40, 8]);
    }
}

module Camera() {
    union() {
        Body();
        Viewfinder();
    }
}

//just_top_half = 1;
inf = 999;
if (!is_undef(just_top_half)) {
    difference() {
        Camera();
        translate([-inf/2, d/2, -inf/2])
            cube([inf, inf, inf]);
    }
} else if (!is_undef(just_bottom_half)) {
    difference() {
        Camera();
        translate([-inf/2, -inf, -inf/2])
            cube([inf, inf, inf]);
    }
} else {
    Camera();
}