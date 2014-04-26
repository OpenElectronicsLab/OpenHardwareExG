// This file describes a rough 3d model of an eeg-mouse board with the
// analog and digital patch shields, along with the plastic fasteners used to
// hold the stack of boards together.  When run directly (vs included with
// "use") it will render the stack of rev1 boards.

include <rev1_dimensions.scad>

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
    x = ( in1p_center_x + (_x * distance_between_touchproof_centers));
    y = ( in1p_center_y + (_y * distance_between_touchproof_centers));
    translate([x,y,-touchproof_projection])
        pipe(rout=touchproof_outer_radius, rin=touchproof_inner_radius,
            h=touchproof_height);
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

module drilled_hole(radius, x, y)
{
    translate([ x, y ])
        circle(r=radius);
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

// one of the PCBs
module board() {
    boardcolor() linear_extrude(height=board_thickness)
    difference() {
        square([board_length, board_width]);
        screw_holes();
    }

    // far Arduino headers
    blackplasticcolor()
        translate([top_arduino_header_x, top_arduino_header_y,
            -top_arduino_header_height])
        cube([top_arduino_header_length, top_arduino_header_width,
            top_arduino_header_height]);

    // near Arduino headers
    blackplasticcolor()
        translate([bottom_arduino_header_x, bottom_arduino_header_y,
            -bottom_arduino_header_height])
        cube([bottom_arduino_header_length, bottom_arduino_header_width,
            bottom_arduino_header_height]);
}

// the top-most PCB
module top_board() {
    board();

    // the touch-proof connectors
    for( _x = [ 0 : 1 : 7 ] ) {
        color([1,0.2,0.2]) touch_proof_connector(_x, 0);
        blackplasticcolor() touch_proof_connector(_x, 1);
        blackplasticcolor() touch_proof_connector(_x, 2);
        color([0.9,0.9,0.9]) touch_proof_connector(_x, 3);
    }
    color([0.2,0.5,0.2]) touch_proof_connector(8, 1.5);

    // the SPI header cap
    color([0.7,0.7,0.7])
        translate([spi_cap_x, spi_cap_y, -spi_cap_height])
        cube([spi_cap_length, spi_cap_width, spi_cap_height]);
    color([0.7,0.7,0.7])
        translate([spi_cap_tab_x, spi_cap_tab_y, -spi_cap_tab_height])
        cube([spi_cap_tab_length, spi_cap_tab_width, spi_cap_tab_height]);
}

// the stack of all three boards mounted together
module boardstack() {
    top_board();
    translate([ 0, 0, board_thickness + spacer_height]) board();
    translate([ 0, 0, 2*board_thickness + 2*spacer_height]) board();
}

module fastener_stack(_x, _y) {
    x = ( screw_hole_centers_x[_x]);
    y = ( screw_hole_centers_y[_y]);
    translate([x,y,-washer_height]) cap_screw();
    translate([x,y,-washer_height]) washer();
    translate([x,y,board_thickness]) spacer();
    translate([x,y,2*board_thickness + spacer_height]) spacer();
    translate([x,y,3*board_thickness + 2*spacer_height]) washer();
    translate([x,y,washer_height + 3*board_thickness + 2*spacer_height]) nut();
}

translate([-board_length/2, board_width/2, 25]) rotate(a=[180,0,0]) {
    // the boards
    boardstack();

    // the fasteners
    for( _y = [ 0 : 1 : 1 ] )
        for( _x = [ 0 : 1 : 3 ] )
            fastener_stack(_x, _y);
}
