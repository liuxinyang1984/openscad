// table/reference_lines.scad — 参考线（仅此文件；true/false 总开关）
//
// 依赖：须先 include <table_config.scad>
// 在 main() 中调用 table_reference_lines()

referenceLinesEnabled = true;

// 参考线默认放在左前外侧，避免挡住模型
referenceLinesOrigin = [-45, -12, 0];

module ref_z_bar(z0, z1, col, r = 1.2) {
    if (z1 > z0)
        color(col)
            translate([0, 0, z0])
                cylinder(r = r, h = z1 - z0);
}

module ref_z_tick(z, col, len = 28, r = 0.8) {
    color(col)
        translate([0, 0, z])
            rotate([0, 90, 0])
                cylinder(r = r, h = len);
}

module table_reference_lines() {
    if (referenceLinesEnabled)
        translate(referenceLinesOrigin)
            table_reference_lines_content();
}

// 具体参考线画在这里
module table_reference_lines_content() {
    // 一根竖线，三段色：桌脚(法兰+短管+三通) → 框架 → 桌面顶
    ref_z_bar(0, legHeight, [0.15, 0.55, 0.95]);
    ref_z_bar(legHeight, frameHeight, [0.15, 0.75, 0.25]);
    ref_z_bar(frameHeight, table_height, [0.9, 0.15, 0.15]);

    ref_z_tick(legHeight, [0.15, 0.55, 0.95]);
    ref_z_tick(frameHeight, [0.15, 0.75, 0.25]);
    ref_z_tick(table_height, [0.9, 0.15, 0.15]);
}
