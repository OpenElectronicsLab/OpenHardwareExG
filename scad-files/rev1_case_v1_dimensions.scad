// This file defines various measurements used for the laser-cut case for a
// rev1 eeg-mouse board with the analog and digital patch shields.

include <rev1_dimensions.scad>

// all size constants are in mm

// width of the cutting tool/laser
// See this page for a brief introduction:
// http://blog.ponoko.com/2008/09/11/how-much-material-does-the-laser-burn-away/
// CAUTION: This value is overridden in rev1_case_v1_pattern.scad
// and is left as zero here so that the 3D model will show the final
// dimensions (without the extra material that will be destroyed in the
// cutting process).
kerf = 0;

// the thickness of the case material and the maximum thickness (taking into
// account the expected variation in thickness from manufacturing the material)
acrylic_thickness = 3;
acrylic_maximum_thickness = acrylic_thickness * 1.15;

// we want a gap between the edge of the PCB and the sides of the acrylic case
air_gap = 1;

// we also want a gap between the bottom board and the bottom of the case
air_gap_bottom = 1 + washer_height + nut_height;

// slots should be wide enough to reliably fit the tabs
tab_slot_width = acrylic_maximum_thickness + 0.1;

// we want a border on the outside of the slot to hold the tabs in place
retaining_margin_width = acrylic_thickness/2;

// position of the various layers of assembled case and boards
case_top_z = 0;
board_1_z = acrylic_thickness + washer_height;
board_2_z = board_1_z + board_thickness + spacer_height;
board_3_z = board_2_z + board_thickness + spacer_height;
case_bottom_z = board_3_z + board_thickness + air_gap_bottom;

case_top_margin = retaining_margin_width + tab_slot_width + air_gap;
case_top_length = case_top_margin + board_length + case_top_margin;
case_top_width = case_top_margin + board_width + case_top_margin;
case_top_corner_radius = 2;

case_front_length = 2 * air_gap + board_length;
case_front_width = case_bottom_z - case_top_z - acrylic_thickness;
case_front_corner_radius = 0.5;

case_side_length = 2 * case_top_margin + board_width;
case_side_width = case_bottom_z - case_top_z - acrylic_thickness;
case_side_corner_radius = 0.5;

// bounding rectangles (used for laying out the parts on the pattern)
case_top_bounding_x = -case_top_margin - kerf/2;
case_top_bounding_y = -case_top_margin - kerf/2;
case_top_bounding_length = case_top_length + kerf;
case_top_bounding_width = case_top_width + kerf;

case_front_bounding_x = -air_gap - kerf/2;
case_front_bounding_y = - kerf/2;
case_front_bounding_length = case_front_length + kerf;
case_front_bounding_width = case_front_width + kerf;

case_side_bounding_x = -case_top_margin - kerf/2;
case_side_bounding_y = - kerf/2;
case_side_bounding_length = case_side_length + kerf;
case_side_bounding_width = case_side_width + kerf;

// Extra allowance so the parts do not have to be precisely aligned,
// e.g. the width of the slot minus the width of the header.
header_allowance = 1.75;
touchproof_allowance = 1.75;
USB_allowance = 1.75;
FTDI_allowance = header_allowance;
JYMCU_allowance = header_allowance;

// minimum gap between parts on the lasercut sheet
part_gap = 2 + kerf;

// length of cap screw to use for the case
cap_screw_body_length = (2 + 1/4) * 25.4;

tab_width = 2 * acrylic_thickness;
