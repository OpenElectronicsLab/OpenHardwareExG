// smooth out circles
$fn = 60;

// all size constants are in mm
acrylic_thickness = 3;
fudge = 0.2;
air_gap = 5;

spacer_outer_radius = 0.25 * 25.4/2;
spacer_inner_radius = 0.14 * 25.4/2;
spacer_height = 0.5 * 25.4;

washer_outer_radius = 0.32 * 25.4/2;
washer_inner_radius = 0.14 * 25.4/2;
washer_height = 0.06 * 25.4;

nut_width = 5/16 * 25.4;
nut_inner_radius = 0.14 * 25.4/2;
nut_height = 1/8 * 25.4;

// Socket-headed cap screw, 6-32 thread, 1-3/4"
cap_screw_cap_height = 0.138 * 25.4;
cap_screw_cap_radius = 0.226 * 25.4/2;
cap_screw_hex_key = 7/64 * 25.4;
cap_screw_body_length = 1.75 * 25.4;
cap_screw_body_radius = 0.138 * 25.4/2;

// origin = top_left_corner_of_the_board

board_length = 197;
board_height = 71;
board_thickness = 0.062 * 25.4;

in1p_height = 16;
in1p_projection = 4.54;
in1p_radius = (9.6/2);
in1p_inner_radius = 4.8/2;
in1p_clearance = 2;
in1p_center_x = 17;
in1p_center_y = 11;
distance_to_next_center = 15;

screw_hole_centers_x = [ 9.5, 69.5, 114.5, 189.5 ];
screw_hole_centers_y = [ 3.5, 63.5 ];
// This is the size from Machinery's handbook for a free clearance fit for a
// size 6 screw (i.e. the larger common screw size used on computer cases).  It
// should also work for an M3 screw (but the fit will be looser).
screw_hole_radius = 0.1495 * 25.4 / 2;

top_arduino_header_x = 133.45;
top_arduino_header_y = 5.61;
top_arduino_header_length = 47.015;
top_arduino_header_breadth = 2.54;
top_arduino_header_height = 9;

bottom_arduino_header_x = 142.3146;
bottom_arduino_header_y = 54.0732;
bottom_arduino_header_length = 38.0746;
bottom_arduino_header_breadth = 2.54;
bottom_arduino_header_height = 9;

spi_cap_x = 177.4654;
spi_cap_y = 11.906;
spi_cap_length = 6;
spi_cap_breadth = 25;
spi_cap_height = 10.8;
spi_cap_tab_x = 176.4654;
spi_cap_tab_y = 22.406;
spi_cap_tab_length = 1;
spi_cap_tab_breadth = 4;
spi_cap_tab_height = 5.3;


// a rectangle with rounded corners of radius r
module rounded_rectangle(size = [1, 1], r = 0.1) {
    translate([r,r])
    minkowski() {
        square(size - 2*[r,r]);
        circle(r);
    }
}

// the top/bottom without any holes
module top_blank() {
    x = air_gap + board_length + air_gap;
    y = air_gap + board_height + air_gap;
    translate([-air_gap, -air_gap]) rounded_rectangle([ x, y ], 4);
}

module drilled_slot(x, y, x_len, y_len, r=1)
{
    translate([ x, y ])
        rounded_rectangle([x_len, y_len], r=r);
}

module drilled_hole(radius, x, y)
{
    translate([ x, y ])
        circle(r=radius);
}

module touch_proof_hole(_x, _y)
{
    x = ( in1p_center_x + (_x * distance_to_next_center));
    y = ( in1p_center_y + (_y * distance_to_next_center));
    drilled_hole(in1p_radius + in1p_clearance/2, x, y);
}

module touch_proof_holes()
{
    for( _y = [ 0 : 1 : 3 ] )
        for( _x = [ 0 : 1 : 7 ] )
            touch_proof_hole(_x, _y);
    touch_proof_hole(8, 1.5);
}

module screw_hole(_x,_y)
{
    x = ( screw_hole_centers_x[_x]);
    y = ( screw_hole_centers_y[_y]);
    drilled_hole(screw_hole_radius, x, y);
}

module screw_holes()
{
    for( _y = [ 0 : 1 : 1 ] )
        for( _x = [ 0 : 1 : 3 ] )
            screw_hole(_x, _y);
}

module modified_android_shield_slots()
{
    // Extra clearance so the headers do not have to be precisely placed,
    // e.g. the width of the slot minus the width of the header.
    header_clearance = 2;
    cap_clearance = 2;

    // the width of a header
    header_width = 0.1 * 25.4;

    // the dimensions of the cap (i.e. ribbon cable connector), not counting
    // the tab on the cap.
    cap_width = 6;
    cap_height = 25;
    // the tab dimensions
    tab_width = 1;
    tab_height = 4;

    // center of the first pin for this connector
    x1_pin1 = 134.72;
    y1_pin1 = 6.88;
    x1_first_to_last_pin = 44.4754;
    x1 =  x1_pin1 - (header_width + header_clearance) / 2;
    y1 =  y1_pin1 - (header_width + header_clearance) / 2;
    x1_len = x1_first_to_last_pin + header_width + header_clearance;
    y1_len = header_width + header_clearance;

    x2_pin1 = 143.5846;
    y2_pin1 = 55.3432;
    x2_first_to_last_pin = 35.5346;
    x2 =  x2_pin1 - (header_width + header_clearance) / 2;
    y2 =  y2_pin1 - (header_width + header_clearance) / 2;
    x2_len = x2_first_to_last_pin + header_width + header_clearance;
    y2_len = header_width + header_clearance;

    // center of the connector
    x3_center = 180.4654;
    y3_center = 24.406;
    x3 =  x3_center - (cap_width + cap_clearance)/2;
    y3 =  y3_center - (cap_height + cap_clearance)/2;
    x3_len = cap_width + cap_clearance;
    y3_len = cap_height + cap_clearance;

    // tab
    x3t =  x3_center - cap_width/2 - tab_width - cap_clearance / 2;
    y3t =  y3_center - (tab_height + cap_clearance) / 2;
    x3t_len = tab_width + cap_clearance;
    y3t_len = tab_height + cap_clearance;

    drilled_slot(x1, y1, x1_len, y1_len, r=header_clearance/2);
    drilled_slot(x2, y2, x2_len, y2_len, r=header_clearance/2);
    drilled_slot(x3, y3, x3_len, y3_len, r=cap_clearance/2);
    drilled_slot(x3t, y3t, x3t_len, y3t_len, r=cap_clearance/2);
}

// color of the PCBs
module boardcolor() {
    color([0.3,0.3,0.3]) child();
}

// color of the black plastic components
module blackplasticcolor() {
    for (i = [0 : $children-1])
        color([0.2,0.2,0.2]) child(i);
}

// color of the case
module casecolor() {
    for (i = [0 : $children-1])
        color([0.5,0.5,0.5],0.5) child(i);
}


// a hexagonal prism with a distance d between sides
module hexprism(d=1, h=1) {
    $fn=6;
    cylinder(r=d/cos(30)/2, h=h);
}

// a hollow cylinder
module pipe(rout, rin, h) {
    difference() {
        cylinder(r=rout, h=h);
        translate([0, 0, -fudge]) cylinder(r=rin, h=h+2*fudge);
    }
}

// a plastic spacer between boards
module spacer() {
    blackplasticcolor()
    pipe(spacer_outer_radius, spacer_inner_radius, spacer_height);
}

// a washer
module washer() {
    blackplasticcolor()
    pipe(washer_outer_radius, washer_inner_radius, washer_height);
}

// a nut
module nut() {
    blackplasticcolor()
    difference() {
        hexprism(d=nut_width, h=nut_height);
        translate([0, 0, -fudge])
            cylinder(r=nut_inner_radius, h=nut_height+2*fudge);
    }
}

// a socket-headed cap screw
module cap_screw() {
    blackplasticcolor() {
        translate([0, 0, -cap_screw_cap_height]) difference() {
            cylinder(r=cap_screw_cap_radius, h=cap_screw_cap_height);
            translate([0, 0, -1/3 * cap_screw_cap_height])
                hexprism(d=cap_screw_hex_key, h=cap_screw_cap_height);
        }
        cylinder(r=cap_screw_body_radius, h=cap_screw_body_length);
    }
}

// a touch-proof connector
module touch_proof_connector(_x, _y) {
    x = ( in1p_center_x + (_x * distance_to_next_center));
    y = ( in1p_center_y + (_y * distance_to_next_center));
    translate([x,y,-in1p_projection])
        pipe(rout=in1p_radius, rin=in1p_inner_radius, h=in1p_height);
}

// one of the PCBs
module board() {
    boardcolor() lasercut(board_thickness)
    difference() {
        square([board_length, board_height]);
        screw_holes();
    }

    blackplasticcolor()
        translate([top_arduino_header_x, top_arduino_header_y,
            -top_arduino_header_height])
        cube([top_arduino_header_length, top_arduino_header_breadth,
            top_arduino_header_height]);

    blackplasticcolor()
        translate([bottom_arduino_header_x, bottom_arduino_header_y,
            -bottom_arduino_header_height])
        cube([bottom_arduino_header_length, bottom_arduino_header_breadth,
            bottom_arduino_header_height]);
}

// the top-most PCB
module top_board() {
    board();
    for( _x = [ 0 : 1 : 7 ] ) {
        color([1,0.2,0.2]) touch_proof_connector(_x, 0);
        blackplasticcolor() touch_proof_connector(_x, 1);
        blackplasticcolor() touch_proof_connector(_x, 2);
        color([0.9,0.9,0.9]) touch_proof_connector(_x, 3);
    }

    color([0.2,0.5,0.2]) touch_proof_connector(8, 1.5);

    color([0.7,0.7,0.7])
        translate([spi_cap_x, spi_cap_y, -spi_cap_height])
        cube([spi_cap_length, spi_cap_breadth, spi_cap_height]);
    color([0.7,0.7,0.7])
        translate([spi_cap_tab_x, spi_cap_tab_y, -spi_cap_tab_height])
        cube([spi_cap_tab_length, spi_cap_tab_breadth, spi_cap_tab_height]);
}

// the bottom
module bottom() {
    difference() {
        top_blank();
        screw_holes();
    }
}

// the top
module top() {
    difference() {
        top_blank();
        screw_holes();
        touch_proof_holes();
        modified_android_shield_slots();
    }
}

// cut the given 2D design out of a sheet of material
module lasercut(thickness = acrylic_thickness) {
    linear_extrude(height = thickness) child();
}

module fastener_stack(_x, _y) {
    x = ( screw_hole_centers_x[_x]);
    y = ( screw_hole_centers_y[_y]);
    translate([x,y,-washer_height]) cap_screw();
    translate([x,y,-washer_height]) washer();
    translate([x,y,acrylic_thickness]) washer();
    translate([x,y,acrylic_thickness + washer_height + board_thickness]) spacer();
    translate([x,y,acrylic_thickness + washer_height + 2*board_thickness + spacer_height])
        spacer();
    translate([x,y,acrylic_thickness + washer_height + 3*board_thickness + 2*spacer_height])
        washer();
    translate([x,y,acrylic_thickness + 2*washer_height + 3*board_thickness + 2*spacer_height])
        nut();
}

translate([-board_length/2, board_height/2, 25]) rotate(a=[180,0,0]) {
    // the boards
    translate([ 0, 0, acrylic_thickness + washer_height]) top_board();
    translate([ 0, 0, acrylic_thickness + washer_height + board_thickness + spacer_height])
        board();
    translate([ 0, 0, acrylic_thickness + washer_height + 2*board_thickness + 2*spacer_height])
        board();

    // the fasteners
    for( _y = [ 0 : 1 : 1 ] )
        for( _x = [ 0 : 1 : 3 ] )
            fastener_stack(_x, _y);

    // the case
    translate([ 0, 0, 0 ]) casecolor() lasercut() top();
    translate([ 0, 0, 40 ]) casecolor() lasercut() bottom();
}

// TODO: sides
// TODO: figure out how sides will fit together
