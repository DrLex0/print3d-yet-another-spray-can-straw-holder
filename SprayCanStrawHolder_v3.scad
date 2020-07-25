/* Customizable Spray Can Straw Holder
 * By DrLex, v3.0 2019/12
 * Thingiverse thing:1707976
 * Released under Creative Commons - Attribution license */

/* [Dimensions (all in mm)] */
// Type of holder: 'clamp' yields a circle segment that grabs the can by itself; 'taped' yields a small holder that must be attached to the can with one or two strips of adhesive tape.
type = "clamp"; //[clamp,taped]

// Diameter of the can. For the 'clamp' type holder, you may want to use a value that is slightly too small, to give the holder extra clamping force.
can_dia = 57.0; //[40:0.1:80]

// Height of the holder. For the 'taped' type, you should use the width of your strip of tape.
height = 8.0; //[3:0.1:32]

// Diameter of the straw hole. The ideal value will depend on your printer, print settings, and filament. Try out a few values and print the final model with what works best.
straw_dia = 2.30; //[1:0.01:4]

// Thickness of the holder walls. Preferably set this to a value that will yield exactly an integer number of perimeters.
thickness = 1.8; //[0.8:0.01:3]

// Add a chamfer to the hole. This makes it easier to insert the straw, especially for the 'taped' model if you're going to attach it with a single strip of tape that blocks the gap in the front.
chamfer = "no"; //[no,yes]

/* [Advanced] */

// The angle for the opening in the clamp (only for 'clamp' shape). Zero produces a half circle which will obviously not clamp at all, 90 produces a full circle which you could only slide onto the can if there is nothing in the way. The default has been tested to work well, so you probably should not change this.
opening_angle = 36; //[0:1:90]

// Number of segments (detail) for the model.
segments = 80; //[32:128]


/* [Hidden] */
rounding = 0.8;
inner_radius = can_dia / 2;
straw_r = straw_dia / 2;

outer_radius = inner_radius + thickness;
mid_radius = (inner_radius + outer_radius)/2;

cut_x = (outer_radius + 2) * cos(opening_angle);
cut_y = (outer_radius + 2) * sin(opening_angle);
r_x = mid_radius * cos(opening_angle);
r_y = mid_radius * sin(opening_angle);

block_w = straw_dia + 3.5;
block_x = block_w/2 - rounding;
xtra_y = straw_dia < 2.6 ? 0 : (straw_dia-2.6)/2;
block_y = outer_radius + 2.5 + straw_dia + xtra_y - rounding;
straw_y = outer_radius + 1.0 + straw_dia;

if(type == "clamp") {
    difference() {
        cylinder(h=height, r=outer_radius, $fn=segments);
        translate([0,0,-1]) {
            cylinder(h=height+2, r=inner_radius, $fn=segments);
            if(opening_angle < 90) {
                linear_extrude(height+2) polygon([[0, 0], [cut_x, cut_y], [cut_x, cut_y + outer_radius], [-cut_x, cut_y + outer_radius], [-cut_x, cut_y]]);
            }
        }
    }
    if(opening_angle < 90) {
        translate([r_x, r_y, 0]) cylinder(r=thickness/2, h=height, $fn=16);
        translate([-r_x, r_y, 0]) cylinder(r=thickness/2, h=height, $fn=16);
    }
}
else {
    touch_x = cos(60) * (inner_radius+rounding);
    touch_y = sin(60) * (inner_radius+rounding);
    block_x2 = block_x + rounding*2 + .4;
    block_w2 = block_w + .8;
    difference() {
        hull() {
            translate([-touch_x, -touch_y, 0]) cylinder(h=height, r=rounding, $fn=24);
            translate([touch_x, -touch_y, 0]) cylinder(h=height, r=rounding, $fn=24);
            translate([block_x2, -block_y, 0]) cylinder(h=height, r=rounding, $fn=24);
            translate([-block_x2, -block_y, 0]) cylinder(h=height, r=rounding, $fn=24);
        }
        translate([0, -(outer_radius + block_w2/2), height/2]) cube([block_w2, block_w2, height+1], center=true);
        translate([0,0,-1]) {
            cylinder(h=height+2, r=inner_radius, $fn=segments);
        }
    }
}

difference() {
    hull() {
        translate([block_x, -block_y, 0]) cylinder(h=height, r=rounding, $fn=24);
        translate([-block_x, -block_y, 0]) cylinder(h=height, r=rounding, $fn=24);
        translate([0, -mid_radius, height/2]) cube([block_w, 0.1, height], center=true);
    }

    translate([0, -straw_y, -1]) {
        cylinder(h=height + 2, r=straw_r, $fn=32);
        linear_extrude(height + 2, convexity=4)
            polygon([[0.2*straw_dia, straw_dia + 0.35], [0.26*straw_dia, 0.2*straw_dia], [straw_dia, -1.85*straw_dia],
                    [-straw_dia, -1.85*straw_dia], [-0.26*straw_dia, 0.2*straw_dia], [-0.2*straw_dia, straw_dia + 0.35]]);
    }

    if(chamfer == "yes") {
        translate([0, -straw_y, height-straw_r-rounding]) cylinder(h=straw_dia+rounding, r1=0, r2=straw_dia+rounding, $fn=32); 
        translate([0, -straw_y, -straw_r]) cylinder(h=straw_dia+rounding, r2=0, r1=straw_dia+rounding, $fn=32); 
    }
}

// Finishing touches
if(type == "clamp") {
    // Round the connection between the circle and the block
    round_y = sqrt(pow(outer_radius + rounding, 2) - pow(block_w/2 + rounding, 2));
    ft_x = block_w/2 - .1;
    ft_y = round_y + .1;
    difference() {
        linear_extrude(height, convexity=4) {
            polygon([[ft_x, -ft_y], [ft_x, -mid_radius], [block_w/2 + round_y - mid_radius, -mid_radius]]);
            polygon([[-ft_x, -ft_y], [-ft_x, -mid_radius], [-(block_w/2 + round_y - mid_radius), -mid_radius]]);
        }
        translate([block_w/2 + rounding, -round_y, height/2]) cylinder(h=height+2, r=rounding, center=true, $fn=24);
        translate([-block_w/2 - rounding, -round_y, height/2]) cylinder(h=height+2, r=rounding, center=true, $fn=24);
    }
}
