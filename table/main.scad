// table/main.scad — 新项目总装（仅渲染入口）

include <table_config.scad>
include <standards.scad>
include <reference_lines.scad>
include <right_frame.scad>
include <left_frame.scad>
include <desk_cross.scad>
include <tabletop.scad>

showBottomFlangePreview = false;
showRightFrame = true;
showLeftFrame = true;
showDeskCross = true;
showTabletop = true;
showCutoutPillar = true;

module main() {
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

    // -------------------------------------------------------------------------
    // 右后开洞占位柱（写在总装，不单拆文件）
    // 起点：桌板切割两虚拟边交点 = 原右上角 (table_length, table_width)
    // 柱截面 290×260：相对洞口 300×270 每边少 10（裁切多切了 10）
    // 高度：自地面到桌面顶再 +500
    // 柱体外角贴齐原右上角，向 −X / −Y 伸入洞口
    // 截面圆角：左上 / 左下 / 右下 R5；右上（原桌角）直角
    // -------------------------------------------------------------------------
    if (showCutoutPillar) {
        cutout_pillar_x = 290;
        cutout_pillar_y = 260;
        cutout_pillar_h = table_height + 500;
        cutout_pillar_r = 5;
        color([0.35, 0.35, 0.4, 0.7])
            translate([
                table_length - cutout_pillar_x,
                table_width - cutout_pillar_y,
                0
            ])
                linear_extrude(height = cutout_pillar_h)
                    cutout_pillar_profile(cutout_pillar_x, cutout_pillar_y, cutout_pillar_r);
    }
}

// 占位柱俯视截面：局部 x=0 左、y=0 前；右上角 (w,d) 为原桌角（直角）
module cutout_pillar_profile(w, d, r) {
    union() {
        translate([r, 0])
            square([w - 2 * r, d]);
        translate([0, r])
            square([w, d - 2 * r]);
        translate([r, r])
            circle(r = r);
        translate([r, d - r])
            circle(r = r);
        translate([w - r, r])
            circle(r = r);
        // 右上：直角填实
        translate([w - r, d - r])
            square([r, r]);
    }
}
