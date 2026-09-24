// main.scad — 场景总装：桌子 + 后墙/柱 + 书架

include <table/main.scad>
include <shelf/main.scad>

showWall = true;
showCutoutPillar = true;
showTable = true;

// 右后开洞占位柱截面（墙长接到柱左缘）
cutout_pillar_x = 290;
cutout_pillar_y = 260;
cutout_pillar_r = 5;

// 后墙：x=0 → 柱左缘；y = 桌后缘外 10mm；高 wall_h；厚 50（+Y）
wall_h = 3000;
wall_t = 50;
wall_len = table_length - cutout_pillar_x;
wall_y = table_width + 10;
// 主墙左侧再延一段（世界 −X），另色区分
wall_extend_left_mm = 2000;

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
        translate([w - r, d - r])
            square([r, r]);
    }
}

module main() {
    if (showTable)
        table_main();

    if (showCutoutPillar)
        color([0.35, 0.35, 0.4, 0.7])
            translate([
                table_length - cutout_pillar_x,
                table_width - cutout_pillar_y,
                0
            ])
                linear_extrude(height = wall_h)
                    cutout_pillar_profile(cutout_pillar_x, cutout_pillar_y, cutout_pillar_r);

    if (showWall) {
        // 主墙（对齐桌长至立柱）
        color([0.82, 0.82, 0.8, 0.85])
            translate([0, wall_y, 0])
                cube([wall_len, wall_t, wall_h]);
        // 左侧延申 2m（另色）
        color([0.55, 0.62, 0.72, 0.85])
            translate([-wall_extend_left_mm, wall_y, 0])
                cube([wall_extend_left_mm, wall_t, wall_h]);
    }
    shelf_main();
}

main();
