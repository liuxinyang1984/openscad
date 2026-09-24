// table/main.scad — 桌子总装（墙/柱见根目录 main.scad）

include <table_config.scad>
include <standards.scad>
include <reference_lines.scad>
include <right_frame.scad>
include <left_frame.scad>
include <desk_cross.scad>
include <tabletop.scad>
include <shelves.scad>

showBottomFlangePreview = false;
showRightFrame = true;
showLeftFrame = true;
showDeskCross = true;
showTabletop = true;
showShelves = true;

module table_main() {
    if (showBottomFlangePreview)
        threaded_flange(flange_params);

    table_reference_lines();

    if (showLeftFrame)
        table_left_frame_in_place();

    if (showRightFrame)
        table_right_frame_in_place();

    if (showDeskCross)
        table_desk_cross();

    if (showTabletop)
        table_tabletop();

    if (showShelves)
        table_shelves();
}
