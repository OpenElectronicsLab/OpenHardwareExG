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

module top() {
  cube([
    board_length+(air_gap * 2),
    board_height+(air_gap * 2),
    acrylic_thickness,
  ]);
}

module touch_proof_hole(i,j)
{
    x = (air_gap + in1p_center_x + (i*distance_to_next_center));
    y = (air_gap + in1p_center_y + (j*distance_to_next_center));
    z = -(fudge/2);
    translate([ x, y, z ])
        cylinder(r=in1p_radius,h=(acrylic_thickness+fudge));
}

difference() {
    top();
    for( i = [ 0 : 1 : 7 ] )
        for( j = [ 0 : 1 : 3 ] )
            touch_proof_hole(i, j);
    touch_proof_hole(8, 1.5);
}
