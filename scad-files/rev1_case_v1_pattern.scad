// This file generates a 2D pattern used for laser-cutting a case for a rev1
// eeg-mouse board with the analog and digital patch shields.

include <rev1_case_v1_dimensions.scad>
use <rev1_case_v1.scad>

translate([-case_top_bounding_x, -case_top_bounding_y]) top();
translate([-case_top_bounding_x,
    -case_top_bounding_y + case_top_bounding_width + part_gap])
    bottom();
