// table/tabletop.scad — 桌面板（视觉；承面 = frameHeight）
//
// 依赖：table_config.scad
// 外轮廓：左前 / 左后 / 右前 R=tabletopCornerR；右后直角（开洞角）
// 右后开洞：板内 tabletopCutoutX × tabletopCutoutY，再向外扩切 overcut

module tabletop_outline_profile(w, d, r) {
    // 局部：x=0 左、y=0 前；右后 (w,d) 直角
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

// 桌板俯视 2D（含右后开洞；过切到板外）
module tabletop_2d() {
    oc = tabletopCutoutOvercutMm;
    r = tabletopCornerR;
    difference() {
        tabletop_outline_profile(table_length, table_width, r);
        translate([
            table_length - tabletopCutoutX,
            table_width - tabletopCutoutY
        ])
            square([tabletopCutoutX + oc, tabletopCutoutY + oc]);
    }
}

module table_tabletop() {
    color([0.72, 0.55, 0.32, 0.55])
        translate([0, 0, frameHeight])
            linear_extrude(height = tabletopThickness)
                tabletop_2d();
}
