// This file describes a laser-cut case for a rev1 eeg-mouse board with the
// analog and digital patch shields.  When run directly (vs included with
// "use") it will render an empty case and a case containing the rev1 boards.

include <rev1_case_v1_dimensions.scad>
use <rev1.scad>

// a rectangle with rounded corners of radius r
module rounded_rectangle(size = [1, 1], r = 0.1) {
    translate([r,r])
    minkowski() {
        square(size - 2*[r,r]);
        circle(r);
    }
}

// color of the case
module case_color() {
    for (i = [0 : $children-1])
        color([0.5,0.5,0.7],0.5) child(i);
}

// the top/bottom without any holes
module top_blank() {
    translate([-air_gap - kerf/2, -air_gap - kerf/2])
        rounded_rectangle([ case_top_length + kerf, case_top_width + kerf ],
            case_top_corner_radius + kerf/2);
}

module drilled_slot(x, y, x_len, y_len, r=1)
{
    translate([ x + kerf/2, y + kerf/2 ])
        rounded_rectangle([x_len - kerf, y_len - kerf], r=max(0.01, r-kerf));
}

module drilled_hole(radius, x, y)
{
    translate([ x, y ])
        circle(r=radius - kerf/2);
}

module touch_proof_hole(_x, _y)
{
    x = ( in1p_center_x + (_x * distance_between_touchproof_centers));
    y = ( in1p_center_y + (_y * distance_between_touchproof_centers));
    drilled_hole(touchproof_outer_radius + touchproof_clearance/2, x, y);
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

    drilled_slot(top_arduino_header_x - header_clearance/2,
        top_arduino_header_y - header_clearance/2,
        top_arduino_header_length + header_clearance,
        top_arduino_header_width + header_clearance,
        r=header_clearance/2);
    drilled_slot(bottom_arduino_header_x - header_clearance/2,
        bottom_arduino_header_y - header_clearance/2,
        bottom_arduino_header_length + header_clearance,
        bottom_arduino_header_width + header_clearance,
        r=header_clearance/2);
    drilled_slot(spi_cap_x - header_clearance/2,
        spi_cap_y - header_clearance/2,
        spi_cap_length + header_clearance,
        spi_cap_width + header_clearance,
        r=header_clearance/2);
    drilled_slot(spi_cap_tab_x - header_clearance/2,
        spi_cap_tab_y - header_clearance/2,
        spi_cap_tab_length + header_clearance,
        spi_cap_tab_width + header_clearance,
        r=header_clearance/2);
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
module laser_cut(thickness = acrylic_thickness) {
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

// the empty case (in 3D)
module case() {
    translate([ 0, 0, 40 ]) case_color() laser_cut() bottom();
    translate([ 0, 0, 0 ]) case_color() laser_cut() top();
}

// hack: to include this file without rendering the 3D model, set
// render_case_model=0 in the file after the include statement.
render_case_model = 1;
if (render_case_model == 1) {
    translate([-board_length/2, board_width/2, 25]) rotate(a=[180,0,0]) {
        // the boards
        translate([ 0, 0, acrylic_thickness + washer_height]) board_stack();

        // the fasteners
        for( _y = [ 0 : 1 : 1 ] )
            for( _x = [ 0 : 1 : 3 ] )
                fastener_stack(_x, _y);

        // the case
        case();

        // an empty case behind the one with the boards
        translate([-250, 0, 0]) case();
    }
}

// TODO: sides
// TODO: figure out how sides will fit together
