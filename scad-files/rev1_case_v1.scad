//

acrylic_thickness=3; //mm
fudge=0.2;
air_gap=5;

//origin=corner_of_the_top_sheet

board_length=197;
board_height=71;
board_thickness=1.5;

in1p_radius=((10.5)/2);
in1p_center_x=17;
in1p_center_y=11;
distance_to_next_center=15;

screw_hole_centers_x = [ 9.5, 69.5, 114.5, 189.5 ];
screw_hole_centers_y = [ 3.5, 63.5 ];
screw_hole_radius = 1.5;

module top() {
  cube([
    board_length+(air_gap * 2),
    board_height+(air_gap * 2),
    acrylic_thickness,
  ]);
}

module drilled_slot(x, y, x_len, y_len)
{
    z = -(fudge/2);
    translate([ x, y, z ])
        cube([ x_len, y_len, acrylic_thickness+fudge ]);
}

module drilled_hole(radius, x, y)
{
    z = -(fudge/2);
    translate([ x, y, z ])
        cylinder(r=radius,h=(acrylic_thickness+fudge));
}

module touch_proof_hole(_x, _y)
{
    x = (air_gap + in1p_center_x + (_x*distance_to_next_center));
    y = (air_gap + in1p_center_y + (_y*distance_to_next_center));
    drilled_hole(in1p_radius, x, y);
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
    x = (air_gap + screw_hole_centers_x[_x]);
    y = (air_gap + screw_hole_centers_y[_y]);
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
    x1=air_gap + 132;
    y1=air_gap + 5;
    x1_len=48;
    y1_len=4;

    x2=air_gap + 140;
    y2=air_gap + 54;
    x2_len=40;
    y2_len=4;

    x3=air_gap + 176;
    y3=air_gap + 17;
    x3_len=8;
    y3_len=25;

    drilled_slot(x1, y1, x1_len, y1_len);
    drilled_slot(x2, y2, x2_len, y2_len);
    drilled_slot(x3, y3, x3_len, y3_len);
}

// the top
difference() {
    top();
    screw_holes();
    touch_proof_holes();
    modified_android_shield_slots();
}

// the bottom (modified top)
translate([ 0, 0, 40 ])
    difference() {
        top();
        screw_holes();
    }
