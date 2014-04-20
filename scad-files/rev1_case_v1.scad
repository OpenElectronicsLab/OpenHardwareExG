// smooth out circles
$fn = 60;

// all size constants are in mm
acrylic_thickness = 3;
fudge = 0.2;
air_gap = 5;

// origin = top_left_corner_of_the_board

board_length = 197;
board_height = 71;
board_thickness = 1.5;

in1p_radius = (9.6/2);
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

// the top/bottom without any holes
module top_blank() {
    x = air_gap + board_length + air_gap;
    y = air_gap + board_height + air_gap;
    translate([-air_gap, -air_gap]) square([ x, y ]);
}

module drilled_slot(x, y, x_len, y_len)
{
    translate([ x, y ])
        square([x_len, y_len]);
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

    drilled_slot(x1, y1, x1_len, y1_len);
    drilled_slot(x2, y2, x2_len, y2_len);
    drilled_slot(x3, y3, x3_len, y3_len);
    drilled_slot(x3t, y3t, x3t_len, y3t_len);
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

// the bottom
module bottom() {
    difference() {
        top_blank();
        screw_holes();
    }
}

// cut the given 2D design out of a sheet of material
module lasercut(thickness = acrylic_thickness) {
    linear_extrude(height = thickness) child();
}

//top();
lasercut() top();
translate([ 0, 0, 40 ]) lasercut() bottom();

// TODO: sides
// TODO: figure out how sides will fit together
