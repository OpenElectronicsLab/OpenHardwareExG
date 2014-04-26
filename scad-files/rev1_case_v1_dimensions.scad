// This file defines various measurements used for the laser-cut case for a
// rev1 eeg-mouse board with the analog and digital patch shields.

include <rev1_dimensions.scad>

// all size constants are in mm

// width of the cutting tool/laser
// CAUTION: This value is overridden in rev1_case_v1_pattern.scad
// and is left as zero here so that the 3D model will show the final
// dimensions (without the extra material that will be destroyed in the
// cutting process).
kerf = 0;

acrylic_thickness = 3;
air_gap = 5;

case_top_length = air_gap + board_length + air_gap;
case_top_width = air_gap + board_width + air_gap;
case_top_corner_radius = 4;

// bounding rectangle (used for laying out the parts on the pattern)
case_top_bounding_x = -air_gap - kerf/2;
case_top_bounding_y = -air_gap - kerf/2;
case_top_bounding_length = case_top_length + kerf;
case_top_bounding_width = case_top_width + kerf;

// minimum gap between parts on the lasercut sheet
part_gap = 2 + kerf;
