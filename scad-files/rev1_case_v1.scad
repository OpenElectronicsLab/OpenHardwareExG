// This file describes a laser-cut case for a rev1 OpenHardwareExG board with the
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

// A slot for a tab, with semicircular cutouts for strain relief in the
// corners.
// note: the center of the slot is at (0,0) (to simplify reasoning about slots
// with different orientations)
module tab_slot(length, width, r_relief) {
    _length = length + tab_slot_length_allowance;
    translate([-_length/2 + kerf/2, -width/2 + kerf/2])
        square([_length - kerf, width - kerf]);
    translate([-_length/2, width/2])
        scale([1,-1]) rotate(90) tab_relief_notch();
    translate([-_length/2, -width/2])
        rotate(90) tab_relief_notch();
    translate([_length/2, width/2])
        rotate(270) tab_relief_notch();
    translate([_length/2, -width/2])
        scale([1,-1]) rotate(270) tab_relief_notch();
}

// A tab
// note: the base of the tab is at (0,0) (to simplify reasoning about tabs with
// different orientations)
module tab(length, width=tab_length, r_corner=tab_corner_radius) {
    union() {
        translate([-length/2 - kerf/2, -fudge]) {
            rounded_rectangle([length + kerf, width + kerf + fudge], r_corner);
            // square out the corners at the attachment point
            square([length + kerf, fudge + r_corner]);
        }
    }
}

// Relief cut outs for a tab.  These should be subtracted from the base part to
// minimize sharp interior angles that can concentrate stress and start crack
// formation.
module tab_relief(length) {
    union() {
        translate([-length/2, 0])
            scale([-1,-1]) tab_relief_notch();
        translate([length/2, 0])
            scale([1,-1]) tab_relief_notch();
    }
}

module tab_relief_notch() {
    difference() {
        union() {
            translate([kerf/2, -kerf/2 - fudge])
                square([(tab_relief_radius * 3) - kerf,
                        tab_relief_radius + kerf/2 + fudge]);
            translate([tab_relief_radius, tab_relief_radius])
                circle(tab_relief_radius - kerf/2);
        }
        translate([tab_relief_radius * 3, tab_relief_radius])
            circle(tab_relief_radius + kerf/2);
    }
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

module vent_grid(length, width) {
    x_step = ((vent_radius*2) + vent_spacing);
    y_step = ((sqrt(3)/2) * ((vent_radius*2) + vent_spacing));

    num_x = 1 + floor((length - (vent_radius*2)) / x_step );
    num_y = 1 + floor((width - (vent_radius*2)) / y_step );
    translate([(length - (x_step * (num_x-1)))/2,
               (width  - (y_step * (num_y-1)))/2 ])
    for (j = [0 : num_y-1]) {
        for (i = [0 : num_x - 1 - (j - 2*floor(j / 2))]) {
            translate([(j - 2*floor(j / 2)) * (x_step/2), 0])
                translate([i * x_step, j * y_step])
                    circle(vent_radius - (kerf/2));
        }
    }
}

direction_x = [1,0];
direction_y = [0,1];

// Places children and the centers of a line of tabs starting from [0,0] and
// extending to a distance of length in direction direction.
module at_tab_centers(length, direction=direction_x) {
    // fit as many tabs as possible (assuming a gap on each side of the tabs)
    num_tabs = floor((length - tab_width) / (2*tab_width));
    // subtract out the tab widths to find the gap width.
    gap_width = (length - tab_width * num_tabs) / (num_tabs + 1);
    for (j = [0 : num_tabs-1]) {
        translate(direction*(gap_width + tab_width/2 + j*(tab_width + gap_width))) {
            for (i = [0 : $children-1]) {
                child(i);
            }
        }
    }
}

// the top/bottom with their shared holes
module top_blank() {
    difference() {
        translate([-case_top_margin - kerf/2, -case_top_margin - kerf/2])
            rounded_rectangle([ case_top_length + kerf, case_top_width + kerf ],
                case_top_corner_radius + kerf/2);
        screw_holes();

        // top row of tab slots
        translate([-air_gap, -air_gap - acrylic_thickness/2])
            at_tab_centers(board_length + 2 * air_gap, direction_x)
            tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);

        // bottom row of tab slots
        translate([-air_gap, board_width + air_gap + acrylic_thickness/2])
            at_tab_centers(board_length + 2 * air_gap, direction_x)
            tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);

        // left row of tab slots
        translate([-air_gap - acrylic_thickness/2, -case_top_margin])
            at_tab_centers(case_top_width, direction_y)
            rotate(90) tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);

        // right row of tab slots
        translate([ board_length + air_gap + acrylic_thickness/2,
            -case_top_margin])
            at_tab_centers(case_top_width, direction_y)
            rotate(90) tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);
    }
}

// the bottom
module bottom() {
    difference() {
        top_blank();
        translate([vent_bottom_margin,vent_bottom_margin])
        vent_grid(board_length - (2*vent_bottom_margin),
                         board_width - (2*vent_bottom_margin));
    }
}

// the top
module top() {
    difference() {
        top_blank();
        touch_proof_holes();
        modified_android_shield_slots();
    }
}

module front() {
    difference() {
        union() {
            // the basic rectangle
            translate([ -air_gap - kerf/2, - kerf/2])
                rounded_rectangle([ case_front_length + kerf,
                    case_front_width + kerf ],
                    case_front_corner_radius + kerf/2);

            // top tabs
            translate([-air_gap, 0])
                at_tab_centers(board_length + 2 * air_gap, direction_x)
                rotate(180) tab(tab_width, tab_length+compression_gap);

            // bottom tabs
            translate([-air_gap, case_front_width])
                at_tab_centers(board_length + 2 * air_gap, direction_x)
                tab(tab_width);

            // left tabs
            translate([-air_gap,
                       (-compression_gap/2)+(-tab_slot_length_allowance/4)])
                at_tab_centers(case_front_width, direction_y)
                rotate(90) tab(tab_width);

            // right tabs
            translate([board_length + air_gap,
                       (-compression_gap/2)+(-tab_slot_length_allowance/4)])
                at_tab_centers(case_front_width, direction_y)
                rotate(270) tab(tab_width);
        }

        // top tab relief
        translate([-air_gap, 0])
            at_tab_centers(board_length + 2 * air_gap, direction_x)
            rotate(180) tab_relief(tab_width);

        // bottom tab relief
        translate([-air_gap, case_front_width])
            at_tab_centers(board_length + 2 * air_gap, direction_x)
            tab_relief(tab_width);

        // left tab relief
        translate([-air_gap,
                   (-compression_gap/2)+(-tab_slot_length_allowance/4)])
            at_tab_centers(case_front_width, direction_y)
            rotate(90) tab_relief(tab_width);

        // right tab relief
        translate([board_length + air_gap,
                   (-compression_gap/2)+(-tab_slot_length_allowance/4)])
            at_tab_centers(case_front_width, direction_y)
            rotate(270) tab_relief(tab_width);

        // vent
        translate([vent_sides_margin,vent_sides_margin])
        vent_grid(case_front_length - (2*vent_sides_margin),
                         case_front_width - (2*vent_sides_margin));
    }
}

module side_blank() {
    difference() {
        union() {
            // the basic rectangle
            translate([ -case_top_margin - kerf/2, - kerf/2])
                rounded_rectangle([ case_side_length + kerf,
                    case_side_width + kerf ],
                    case_side_corner_radius + kerf/2);

            // top tabs
            translate([-case_top_margin, 0])
                at_tab_centers(case_top_width, direction_x)
                rotate(180) tab(tab_width);

            // bottom tabs
            translate([-case_top_margin, case_side_width])
                at_tab_centers(case_top_width, direction_x)
                tab(tab_width, tab_length+compression_gap);
        }

        // top tab relief
        translate([-case_top_margin, 0])
            at_tab_centers(case_top_width, direction_x)
            rotate(180) tab_relief(tab_width);

        // bottom tab relief
        translate([-case_top_margin, case_side_width])
            at_tab_centers(case_top_width, direction_x)
            tab_relief(tab_width);

        // left row of tab slots
        translate([-air_gap - acrylic_thickness/2,
                   (compression_gap/2)+(tab_slot_length_allowance/4)])
            at_tab_centers(case_side_width, direction_y)
            rotate(90)
            tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);

        // right row of tab slots
        translate([ board_width + air_gap + acrylic_thickness/2,
                   (compression_gap/2)+(tab_slot_length_allowance/4)])
            at_tab_centers(case_side_width, direction_y)
            rotate(90)
            tab_slot(tab_width,tab_slot_width,tab_slot_relief_radius);
    }
}

module left_side() {
    difference() {
        side_blank();
        translate([vent_sides_margin - case_top_margin, vent_sides_margin])
        vent_grid(case_side_length - (2*vent_sides_margin),
                         case_side_width - (2*vent_sides_margin));
    }
}

module right_side() {
    difference() {
        side_blank();
        drilled_slot(
            board_width - USB_y - USB_width - USB_allowance/2,
            board_3_z - case_top_z - acrylic_thickness - USB_height
                - USB_allowance/2,
            USB_width + USB_allowance,
            USB_height + USB_allowance,
            r=USB_allowance/2);
        drilled_slot(
            board_width - FTDI_y - FTDI_width - FTDI_allowance/2,
            board_3_z - case_top_z - acrylic_thickness - FTDI_height
                - FTDI_allowance/2,
            FTDI_width + FTDI_allowance,
            FTDI_height + FTDI_allowance,
            r=FTDI_allowance/2);
        drilled_slot(
            board_width - JYMCU_y - JYMCU_width - JYMCU_allowance/2,
            board_3_z - case_top_z - acrylic_thickness - JYMCU_height
                - JYMCU_allowance/2,
            JYMCU_width + JYMCU_allowance,
            JYMCU_height + JYMCU_allowance,
            r=JYMCU_allowance/2);
    }
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
    // draw the case roughly back to front to work around the absence of
    // z-sorting in the 2013 version of OpenSCAD

    // bottom
    translate([ 0, 0, case_bottom_z ]) case_color() laser_cut() bottom();

    // back
    translate([ 0, -air_gap, case_top_z + acrylic_thickness + compression_gap])
        rotate(a=[90,0,0]) case_color() laser_cut()
        front();

    // left side
    translate([-air_gap - acrylic_thickness, 0,
        case_top_z + acrylic_thickness])
        rotate(a=[90,0,90]) case_color() laser_cut()
        left_side();

    // front
    translate([ 0, board_width + air_gap + acrylic_thickness,
        case_top_z + acrylic_thickness + compression_gap])
        rotate(a=[90,0,0]) case_color() laser_cut()
        front();

    // right side
    translate([ board_length + air_gap + acrylic_thickness, board_width,
        case_top_z + acrylic_thickness])
        rotate(a=[90,0,-90]) case_color() laser_cut()
        right_side();

    // top
    translate([ 0, 0, case_top_z ]) case_color() laser_cut() top();
}

// hack: to include this file without rendering the 3D model, set
// render_case_model=0 in the file after the include statement.
render_case_model = 1;
if (render_case_model == 1) {
    translate([-board_length/2, board_width/2, 25]) rotate(a=[180,0,0]) {
        // an empty case behind the one with the boards
        translate([-300, 0, 0]) case();

        // the boards
        translate([ 0, 0, acrylic_thickness + washer_height]) board_stack();

        // the fasteners
        for( _y = [ 0 : 1 : 1 ] )
            for( _x = [ 0 : 1 : 3 ] )
                fastener_stack(_x, _y);

        // the case
        case();
    }
}
