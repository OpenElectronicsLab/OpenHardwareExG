// This file defines various measurements used for the rev1 OpenHardwareExG board
// with the analog and digital patch shields.

// smooth out circles
$fa = 6;
$fs = 0.1;

// all size constants are in mm
fudge = 1;

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

touchproof_height = 16;
touchproof_projection = 4.54;
touchproof_outer_radius = (9.6/2);
touchproof_inner_radius = 4.8/2;

// origin = top_left_corner_of_the_board

board_length = 197;
board_width = 71;
board_thickness = 0.062 * 25.4;

in1p_center_x = 17;
in1p_center_y = 11;
distance_between_touchproof_centers = 15;

screw_hole_centers_x = [ 9.5, 69.5, 114.5, 189.5 ];
screw_hole_centers_y = [ 3.5, 63.5 ];
// This is the size from Machinery's handbook for a free clearance fit for a
// size 6 screw (i.e. the larger common screw size used on computer cases).  It
// should also work for an M3 screw (but the fit will be looser).
screw_hole_radius = 0.1495 * 25.4 / 2;

top_arduino_header_x = 133.45;
top_arduino_header_y = 5.61;
top_arduino_header_length = 47.015;
top_arduino_header_width = 2.54;
top_arduino_header_height = 9;

bottom_arduino_header_x = 142.3146;
bottom_arduino_header_y = 54.0732;
bottom_arduino_header_length = 38.0746;
bottom_arduino_header_width = 2.54;
bottom_arduino_header_height = 9;

spi_cap_x = 177.4654;
spi_cap_y = 11.906;
spi_cap_length = 6;
spi_cap_width = 25;
spi_cap_height = 10.8;
spi_cap_tab_x = 176.4654;
spi_cap_tab_y = 22.406;
spi_cap_tab_length = 1;
spi_cap_tab_width = 4;
spi_cap_tab_height = 5.3;

USB_x = 187.591;
USB_y = 14.73;
USB_length = 16;
USB_width = 12.2;
USB_height = 11;
USB_hole_width = 8.45;
USB_hole_height = 7.78;
USB_post_width = 5.6;
USB_post_height = 3.18;

FTDI_x = 191.87;
FTDI_y = 31.01;
FTDI_length = 11;
FTDI_pitch = 2.54;
FTDI_pin_count = 6;
FTDI_pin_width = 0.6;
FTDI_width = FTDI_pin_count * FTDI_pitch;
FTDI_height = FTDI_pitch;

JYMCU_x = 191.87;
JYMCU_y = 48.79;
JYMCU_length = 11;
JYMCU_pitch = 2.54;
JYMCU_pin_count = 4;
JYMCU_pin_width = 0.6;
JYMCU_width = JYMCU_pin_count * JYMCU_pitch;
JYMCU_height = JYMCU_pitch;
