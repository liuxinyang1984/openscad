// table/main.scad — 新项目总装（仅渲染入口）

include <table_config.scad>
include <standards.scad>
include <reference_lines.scad>
include <right_frame.scad>
include <left_frame.scad>

showBottomFlangePreview = false;
showRightFrame = true;
showLeftFrame = true;

module main() {
    if (showBottomFlangePreview)
        threaded_flange(flange_params);

    table_reference_lines();

    if (showLeftFrame)
        table_left_frame_in_place();

    if (showRightFrame)
        table_right_frame_in_place();

    // TODO: 拉结
}
