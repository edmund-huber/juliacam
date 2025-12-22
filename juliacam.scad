$fs = 0.1;
fillet_r_xy = 5;
fillet_r_z = 3;
body_w = 100;
body_d = 40;
body_h = 20;
module BodyBox(shrink=0) {
    translate([shrink, shrink, shrink])
    minkowski() {
        scale([fillet_r_xy*2, fillet_r_xy*2, fillet_r_z*2])
        intersection() {
            union() {
                polyhedron(points=[[0,0,0.5],[1,0,0.5],[1,1,0.5],[0,1,0.5],[0.5,0.5,1]], faces=[[0,1,4],[1,2,4],[2,3,4],[3,0,4],[1,0,3],[2,1,3]]);
                polyhedron(points=[[0,0,0.5],[1,0,0.5],[1,1,0.5],[0,1,0.5],[0.5,0.5,0]], faces=[[0,1,4],[1,2,4],[2,3,4],[3,0,4],[1,0,3],[2,1,3]]);
            }
        }
        cube([
            body_w - fillet_r_xy*2 - shrink*2,
            body_d - fillet_r_xy*2 - shrink*2,
            body_h - fillet_r_z*2 - shrink*2
        ]);
    }
}

module Screwholder(h, r, add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    if (add) {
        intersection() {
            BodyBox()
            cylinder(h=h, r=r-2);
        }
    }
    if (sub) {
        cylinder(h=h, r=r);
    }
}

module Screwholders(z, h, add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    r = 4;
    min_x = r;
    mid_x = body_w / 2;
    max_x = body_w - r;
    min_y = r;
    max_y = body_d - r;
    for (xy = [
        [min_x, min_y], [min_x, max_y],
        [mid_x, min_y], [mid_x, max_y],
        [max_x, min_y], [max_x, max_y]
    ]) {
        translate([xy[0], xy[1], body_h - h])
        Screwholder(h, r, add=add, sub=sub);
    }
}

module Body() {
    union() {
        // The body, hollowed out.
        difference() {
            union() {
                BodyBox(shrink=0);
                Screwholders(5, 5, add=true);
            }
            Screwholders(5, 5, sub=true);
            BodyBox(shrink=2);
        }
        // Beef up the top so that we can place the gasket trench and screw holders.
        /*union() {
            difference() {
                // Make a solid top,
                intersection() {
                    BodyBox(shrink=0);
                    translate([0, 0, body_h-7])
                        cube([body_w, body_d, 5]);
                }
                // .. and subtract out some of the inside.
                translate([5, 5, body_h-10])
                    cube([body_w-10, body_d-10, 7]);
            }
            Screwholders(body_h, 7);
        }*/
    }
}

module Camera() {
    Body();
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