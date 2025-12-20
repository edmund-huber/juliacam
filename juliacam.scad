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

module Body() {
    difference() {
        BodyBox(shrink=0);
        BodyBox(shrink=2);
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

if (!is_undef(part)) {
    if (part == 1) {
        TopHalf();
    } else if (part == 2) {
        BottomHalf();
    } else {
        assert(false);
    }
} else {
    TopHalf();
    BottomHalf();
}