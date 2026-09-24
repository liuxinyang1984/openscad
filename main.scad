// main.scad — 场景总装：桌子 + 后墙/柱 + 书架

include <table/main.scad>
include <shelf/main.scad>

showWall = true;
showCutoutPillar = true;

// 右后开洞占位柱截面（墙长接到柱左缘）
cutout_pillar_x = 290;
cutout_pillar_y = 260;
cutout_pillar_r = 5;

// 后墙：x=0 → 柱左缘；y = 桌后缘外 10mm；高 2000；厚 50（+Y）
wall_h = 3000;
wall_t = 50;
wall_len = table_length - cutout_pillar_x;
wall_y = table_width + 10;

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

    if (showWall)
        color([0.82, 0.82, 0.8, 0.85])
            translate([0, wall_y, 0])
                cube([wall_len, wall_t, wall_h]);

    shelf_main();
}

main();
