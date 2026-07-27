// table/shelves.scad — 框上层板（视觉）
//
// 依赖：table_config.scad + standards.scad
// 三块 12mm 木板：左框下框；右框下框；右框中框
// 承面 = 横管顶面（管件中心 Z + 管外径/2）
// 外轮廓：相对框架管外侧外沿再外延 shelfEdgeOverhangMm
// 立柱角：圆心 = 立柱轴心；直径 = 三通外螺纹段外径 + 5（封闭圆孔）
// 右框板：与桌板同法 — 方形外包 + 右后切矩形（非梯形斜边）

shelfEdgeOverhangMm = 10;

function shelf_fitting_od() = pipe + 2 * (pipe * 0.1);
function shelf_post_cut_d() = shelf_fitting_od() + 5;
function shelf_outline_outset() = pipe / 2 + shelfEdgeOverhangMm;

// 右框板右后切洞：X = 右移量；Y 与桌板洞口前缘对齐
function shelf_rf_cut_x() = rightFrameShiftX;
function shelf_rf_cut_y() = tabletopCutoutY - frameInset;

module shelf_post_hole(post) {
    eps = 0.2;
    translate([post[0], post[1], -eps])
        cylinder(d = shelf_post_cut_d(), h = shelfThicknessMm + 2 * eps);
}

module shelf_board_rect(size_xy) {
    w = size_xy[0];
    d = size_xy[1];
    o = shelf_outline_outset();
    difference() {
        linear_extrude(height = shelfThicknessMm)
            offset(delta = o)
                square([w, d]);
        shelf_post_hole([0, 0]);
        shelf_post_hole([w, 0]);
        shelf_post_hole([0, d]);
        shelf_post_hole([w, d]);
    }
}

// 右框层板：局部原点 = 已右移的左前柱心
// 外包方形 = 前缘跨距 × 深；右后切矩形（同桌板），过切到板外
module shelf_board_right_rect() {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;
    o = shelf_outline_outset();
    oc = tabletopCutoutOvercutMm;
    cut_x = shelf_rf_cut_x();
    cut_y = shelf_rf_cut_y();
    eps = 0.2;
    h = shelfThicknessMm + 2 * eps;
    // 四柱：左前 / 右前 / 右后（未右移） / 左后
    posts = [
        [0, 0],
        [w, 0],
        [w - sx, d],
        [0, d]
    ];
    assert(cut_y > 0 && cut_y < d,
        str("shelf_rf_cut_y 须在 (0, depth) 内，当前=", cut_y));
    difference() {
        linear_extrude(height = shelfThicknessMm)
            offset(delta = o)
                square([w, d]);
        // 右后内角对齐；+X/+Y 再切出板外（含 outset）
        translate([w - cut_x, d - cut_y, -eps])
            cube([cut_x + o + oc, cut_y + o + oc, h]);
        for (p = posts)
            shelf_post_hole(p);
    }
}

module table_shelves() {
    z_on_rail = pipe / 2;
    col = [0.62, 0.45, 0.28, 0.65];
    sx = rightFrameShiftX;

    color(col)
        translate([leftFrameOriginX, leftFrameOriginY, lf_z_lo + z_on_rail])
            shelf_board_rect([leftFrameWidth, leftFrameDepth]);

    color(col)
        translate([rightFrameOriginX + sx, rightFrameOriginY, rf_z_lo + z_on_rail])
            shelf_board_right_rect();

    color(col)
        translate([rightFrameOriginX + sx, rightFrameOriginY, rf_z_hi + z_on_rail])
            shelf_board_right_rect();
}
