w = 100;
d = 30;
h = 50;
module BodyBox(radius) {
    minkowski() {
        translate([5, 5, 5]) sphere(radius);
        cube([w, d, h]);
    }
}

module Body() {
    difference() {
        union() {
            BodyBox(5);
            // viewfinder
            translate([w-15, -5, h-10])
                cube([15, d+20, 10]);
        }
        BodyBox(3);
        translate([(w+10)/2, 5, (h+10)/2])
        rotate([90, 0, 0])
            cylinder(10, 20, 20);
        translate([20, (d+10)/2, h+5])
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