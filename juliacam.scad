$fs = 0.1;
fillet_r_xy = 5;
fillet_r_z = 3;
body_w = 100;
body_d = 40;
body_h = 20;
module BodyBox(shrink=0) {
    translate([shrink, shrink, shrink])
    resize([body_w - shrink*2, body_d - shrink*2, body_h - shrink*2])
    minkowski() {
        scale([fillet_r_xy*2, fillet_r_xy*2, fillet_r_z*2])
        intersection() {
        union() {
            polyhedron(points=[[0,0,0.5],[1,0,0.5],[1,1,0.5],[0,1,0.5],[0.5,0.5,1]], faces=[[0,1,4],[1,2,4],[2,3,4],[3,0,4],[1,0,3],[2,1,3]]);
            polyhedron(points=[[0,0,0.5],[1,0,0.5],[1,1,0.5],[0,1,0.5],[0.5,0.5,0]], faces=[[0,1,4],[1,2,4],[2,3,4],[3,0,4],[1,0,3],[2,1,3]]);
        }
        translate([0.5, 0.5, 0])
        cylinder(h=1, d=1);
    }
        cube([body_w - fillet_r_xy*2, body_d - fillet_r_xy*2, body_h - fillet_r_z*2]);
    }
}

module Screwholders(z, h) {
    translate([5, 5, z-h])
        cylinder(h=h, r=5);
    translate([body_w/2, 5, z-h])
        cylinder(h=h, r=5);
    translate([body_w - 5, 5, z-h])
        cylinder(h=h, r=5);
    translate([5, body_d - 5, z-h])
        cylinder(h=h, r=5);
    translate([body_w/2, body_d - 5, z-h])
        cylinder(h=h, r=5);
    translate([body_w - 5, body_d - 5, z-h])
        cylinder(h=h, r=5);
}

module Body() {
    union() {
        // The body, hollowed out.
        difference() {
            union() {
                BodyBox(shrink=0);
                Screwholders(5, 5);
            }
            BodyBox(shrink=2);
        }
        // Beef up the top so that we can place the gasket trench and screw holders.
        union() {
            difference() {
                // Make a solid top,
                intersection() {
                    BodyBox(shrink=0);
                    translate([0, 0, body_h-10])
                        cube([body_w, body_d, 5]);
                }
                // .. and subtract out some of the inside.
                translate([5, 5, body_h-10])
                    cube([body_w-10, body_d-10, 7]);
            }
            Screwholders(body_h, 7);
        }
    }
}

module Lens(positive=false, negative=false) {
    assert(positive || negative);
    assert(!(positive && negative));
    if (positive) {
        
    }
}

module Viewfinder(positive=false, negative=false) {
    assert(positive || negative);
    assert(!(positive && negative));
    if (positive) {
        difference() {
            minkowski() {
                translate([body_w-15, 0, body_h-10])
                    cube([15, body_d+10, 10]);
                    sphere(1);
            }
        }
    }
    if (negative) {
        translate([body_w-15, -10, body_h-10])
            cube([13, body_d+40, 8]);
    }
}

module Camera() {
    difference() {
        union() {
            Body();
            //Viewfinder(positive=true);
        }
        //Viewfinder(negative=true);
    }
}

inf = 999;

module TopHalf() {
    translate([0, body_d + 10, 0])
    intersection() {
        Camera();
        translate([0, 0, (inf/2) + body_h - fillet_r_z - 2])
            cube([inf, inf, inf], center=true);
    }
}

module BottomHalf() {
    difference() {
        Camera();
        translate([0, 0, (inf/2) + body_h - fillet_r_z - 2])
            cube([inf, inf, inf], center=true);
    }
}

//transverse_section = 1;
//sagittal_section = 1;

if (!is_undef(part)) {
    if (part == 1) {
        TopHalf();
    } else if (part == 2) {
        BottomHalf();
    } else {
        assert(false);
    }
} else if (!is_undef(transverse_section)) {
    intersection() {
        union() {
            TopHalf();
            BottomHalf();
        }
        translate([(body_w/2) - 5, 0, 0])
            cube([10, inf, inf]);
    }
} else if (!is_undef(sagittal_section)) {
    intersection() {
        union() {
            TopHalf();
            BottomHalf();
        }
        union() {
            translate([0, body_d/2, 0])
                cube([inf, 5, inf]);
            translate([0, body_d + body_d/2, 0])
                cube([inf, 5, inf]);
        }
    }
} else {
    TopHalf();
    BottomHalf();
}