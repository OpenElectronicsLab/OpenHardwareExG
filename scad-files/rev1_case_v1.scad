// This file describes a laser-cut case for a rev1 eeg-mouse board with the
// analog and digital patch shields.  When run directly (vs included with
// "use") it will render an empty case and a case containing the rev1 boards.

include <rev1_case_v1_dimensions.scad>
use <rev1.scad>

// a rectangle with rounded corners of radius r
module rounded_rectangle(size = [1, 1], r = 0.1) {
    // move the origin, to compensate for shrinkage
    translate([r,r])
    minkowski() {
        square(size - 2*[r,r]);
        circle(r);
    }
}

// color of the case
module case_color() {
    transparency = 0.5;
    for (i = [0 : $children-1])
        color([0.5,0.5,0.7], transparency) child(i);
}

// the top/bottom without any holes
module top_blank() {
    translate([-case_top_margin - kerf/2, -case_top_margin - kerf/2])
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
    drilled_hole(touchproof_outer_radius + touchproof_allowance/2, x, y);
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
    drilled_slot(top_arduino_header_x - header_allowance/2,
        top_arduino_header_y - header_allowance/2,
        top_arduino_header_length + header_allowance,
        top_arduino_header_width + header_allowance,
        r=header_allowance/2);
    drilled_slot(bottom_arduino_header_x - header_allowance/2,
        bottom_arduino_header_y - header_allowance/2,
        bottom_arduino_header_length + header_allowance,
        bottom_arduino_header_width + header_allowance,
        r=header_allowance/2);
    drilled_slot(spi_cap_x - header_allowance/2,
        spi_cap_y - header_allowance/2,
        spi_cap_length + header_allowance,
        spi_cap_width + header_allowance,
        r=header_allowance/2);
    drilled_slot(spi_cap_tab_x - header_allowance/2,
        spi_cap_tab_y - header_allowance/2,
        spi_cap_tab_length + header_allowance,
        spi_cap_tab_width + header_allowance,
        r=header_allowance/2);
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

module front() {
    translate([ -air_gap - kerf/2, - kerf/2])
        rounded_rectangle([ case_front_length + kerf, case_front_width + kerf ],
            case_front_corner_radius + kerf/2);
}

// cut the given 2D design out of a sheet of material
module laser_cut(thickness = acrylic_thickness) {
    linear_extrude(height = thickness) child();
}

module fastener_stack(_x, _y) {
    x = ( screw_hole_centers_x[_x]);
    y = ( screw_hole_centers_y[_y]);
    translate([x,y,case_top_z - washer_height])
        cap_screw(cap_screw_body_length);
    translate([x,y,case_top_z - washer_height]) washer();
    translate([x,y,board_1_z - washer_height]) washer();
    translate([x,y,board_2_z - spacer_height]) spacer();
    translate([x,y,board_3_z - spacer_height]) spacer();
    translate([x,y,board_3_z + board_thickness]) washer();
    translate([x,y,board_3_z + board_thickness + washer_height]) nut();
    translate([x,y,case_bottom_z + acrylic_thickness]) washer();
    translate([x,y,case_bottom_z + acrylic_thickness + washer_height]) nut();
}

// the empty case (in 3D)
module case() {
    translate([ 0, 0, case_bottom_z ]) case_color() laser_cut() bottom();
    translate([ 0, -air_gap, case_top_z + acrylic_thickness])
        rotate(a=[90,0,0]) case_color() laser_cut()
        front();
    translate([ 0, 0, case_top_z ]) case_color() laser_cut() top();
    translate([ 0, board_width + air_gap + acrylic_thickness,
        case_top_z + acrylic_thickness])
        rotate(a=[90,0,0]) case_color() laser_cut()
        front();
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
        translate([-300, 0, 0]) case();
    }
}

// TODO: sides
// TODO: figure out how sides will fit together
