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
        union() {
            BodyBox(body_r);
            // viewfinder
            translate([body_w-15, -5, body_h-10])
                cube([15, body_d+20, 10]);
        }
        BodyBox(body_r - 3);
        translate([(body_w+10)/2, 5, (body_h+10)/2])
        rotate([90, 0, 0])
            cylinder(10, 20, 20);
        translate([20, (body_d+10)/2, body_h+5])
            cylinder(h=10, r=5);
    }
}

//just_top_half = 1;
inf = 999;
if (!is_undef(just_top_half)) {
    difference() {
        Body();
        translate([-inf/2, d/2, -inf/2])
            cube([inf, inf, inf]);
    }
} else if (!is_undef(just_bottom_half)) {
    difference() {
        Body();
        translate([-inf/2, -inf, -inf/2])
            cube([inf, inf, inf]);
    }
} else {
    Body();
}