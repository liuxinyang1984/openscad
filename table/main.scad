// table/main.scad — 新项目总装（仅渲染入口）

include <table_config.scad>
include <standards.scad>
include <reference_lines.scad>
include <right_frame.scad>

showBottomFlangePreview = false;
showRightFrame = true;

module main() {
    if (showBottomFlangePreview)
        threaded_flange(flange_params);

    table_reference_lines();

    if (showRightFrame)
        table_right_frame_in_place();

    // TODO: 左框 / 拉结
}
