$fs = 0.1;
inf = 99999;
fillet_r_xy = 5;
fillet_r_z = 3;
body_w = 100;
body_d = 40;
body_h = 20;
body_top_h = 5;
body_skin_d = 2;

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

module GasketLedge() {
    h = 6;
    w = 6;
    intersection() {
        BodyBox(shrink=0);
        union() {
            translate([0, 0, body_h - h])
                cube([body_w, w, h]);
            translate([0, body_d - w, body_h - h])
                cube([body_w, w, h]);
            translate([0, 0, body_h - h])
                cube([w, body_d, h]);
            translate([body_w - w, 0, body_h - h])
                cube([w, body_d, h]);
        }
    }
}

module Screwholder(x, y, z, r, add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    screw_post_h = 6;
    if (add) {
        union() {
            intersection() {
                BodyBox(shrink=0);
                // A screw post large enough to accomodate the entire screw.
                translate([x, y, z - screw_post_h])
                    cylinder(h=inf, r=r);
            }
        }
    }
    if (sub) {
        // Bore out the space for the M3 screw head.
        translate([x, y, z+2])
            cylinder(h=inf, d=6);
        // Bore out a space for the M3 threaded insert.
        translate([x, y, z - screw_post_h + 1])
            cylinder(h=inf, d=4.5);
    }
}

module Screwholders(z, h, add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    r = 6;
    min_x = 4;
    mid_x = body_w / 2;
    max_x = body_w - 4;
    min_y = 4;
    max_y = body_d - 4;
    for (xy = [
        [min_x, min_y], [min_x, max_y],
        [mid_x, min_y], [mid_x, max_y],
        [max_x, min_y], [max_x, max_y]
    ]) {
        Screwholder(xy[0], xy[1], z, r, add=add, sub=sub);
    }
}

viewfinder_x = 15;
viewfinder_y = 10;
viewfinder_w = 15;
viewfinder_h = 10;

module Viewfinder(add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    if (add) {
        // Eye hole.
        translate([viewfinder_x, viewfinder_y, 0])
            cube([viewfinder_w, viewfinder_h, body_h]);
    }
    if (sub) {
        // Eye hole.
        translate([viewfinder_x + 1, viewfinder_y + 1, 0])
            cube([viewfinder_w - 2, viewfinder_h - 2, inf]);
        // Camera hole.
        translate([
            viewfinder_x + viewfinder_w + 5,
            viewfinder_y + (viewfinder_h / 2),
            body_h - 2
        ])
            cylinder(h=inf, r=(viewfinder_h - 2) / 2);
        inset = 1;
        cutout_h = body_top_h - body_skin_d;
        translate([viewfinder_x, viewfinder_y, body_h - body_skin_d - cutout_h])
            cube([25, 10, cutout_h + inset]);
    }
}

module Buttonholder(add=false, sub=false) {
    assert(add || sub);
    assert(!(add && sub));
    if (add) {
        intersection() {
            BodyBox(shrink=0);
            translate([70, 5, 10])
                rotate([90, 0, 0])
                    cylinder(h=inf, d=10);
        }
    }
    if (sub) {
        union() {
            translate([70, 4, 10])
                rotate([90, 0, 0])
                    cylinder(h=inf, d=8);
            translate([70, 6, 10])
                rotate([90, 0, 0])
                    cylinder(h=inf, d=4);
        }
    }
}

module Camera() {
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        BodyBox(shrink=0);
                        BodyBox(shrink=body_skin_d);
                    }
                    GasketLedge();
                    Screwholders(body_h - 5, 5, add=true);
                    Viewfinder(add=true);
                    Buttonholder(add=true);
                }
                Screwholders(body_h - 5, 5, sub=true);
                Viewfinder(sub=true);
                Buttonholder(sub=true);
            }
        }
        
    }
}

module Part1() {
    intersection() {
        Camera();
        cube([body_w, body_d, body_h - body_top_h]);
    }
}

module Part2() {
    translate([0, body_d + 10, 0])
    intersection() {
        Camera();
        translate([0, 0, body_h - body_top_h])
            cube([body_w, body_d, body_top_h]);
    }
}

//transverse_section = 1;
//sagittal_section = 1;

if (!is_undef(part)) {
    if (part == 1) {
        Part1();
    } else if (part == 2) {
        Part2();
    } else {
        assert(false);
    }
} else if (!is_undef(transverse_section)) {
    intersection() {
        union() {
            Part1();
            Part2();
        }
        translate([body_w/2, 0, 0])
            cube([10, inf, inf]);
    }
} else if (!is_undef(sagittal_section)) {
    intersection() {
        union() {
            Part1();
            Part2();
        }
        union() {
            translate([0, body_d/2, 0])
                cube([inf, 5, inf]);
            translate([0, body_d + body_d/2, 0])
                cube([inf, 5, inf]);
        }
    }
} else {
    Part1();
    Part2();
    translate([-body_w - 10, 0, 0])
        Camera();
}