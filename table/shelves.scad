// table/shelves.scad — 框上层板（视觉）
//
// 依赖：table_config.scad + standards.scad
// 三块 12mm 木板：左框下框；右框下框；右框中框
// 承面 = 横管顶面（管件中心 Z + 管外径/2）
// 外轮廓：相对框架管外侧外沿再外延 shelfEdgeOverhangMm
// 立柱角：圆心 = 立柱轴心；直径 = 三通外螺纹段外径 + 5（封闭圆孔）
// 右框板：与桌板同法 — 方形外包 + 右后切矩形（非梯形斜边）
// 2D 轮廓：shelf_board_*_2d（平面图 / 挤出共用）

shelfEdgeOverhangMm = 10;

function shelf_fitting_od() = pipe + 2 * (pipe * 0.1);
function shelf_post_cut_d() = shelf_fitting_od() + 5;
function shelf_outline_outset() = pipe / 2 + shelfEdgeOverhangMm;

// 右框板右后切洞：X = 右移量；Y 与桌板洞口前缘对齐
function shelf_rf_cut_x() = rightFrameShiftX;
function shelf_rf_cut_y() = tabletopCutoutY - frameInset;

// 左/右层板外包尺寸（含 outset；柱心外包 + 两侧外延）
function shelf_left_outer_w() = leftFrameWidth + 2 * shelf_outline_outset();
function shelf_left_outer_d() = leftFrameDepth + 2 * shelf_outline_outset();
function shelf_right_outer_w() = rightFrameWidth + 2 * shelf_outline_outset();
function shelf_right_outer_d() = rightFrameDepth + 2 * shelf_outline_outset();

module shelf_post_hole_2d(post) {
    translate([post[0], post[1]])
        circle(d = shelf_post_cut_d());
}

// 左框层板 2D：局部原点 = 左前柱心；外轮廓相对柱网 offset
module shelf_board_rect_2d(size_xy) {
    w = size_xy[0];
    d = size_xy[1];
    o = shelf_outline_outset();
    difference() {
        offset(delta = o)
            square([w, d]);
        shelf_post_hole_2d([0, 0]);
        shelf_post_hole_2d([w, 0]);
        shelf_post_hole_2d([0, d]);
        shelf_post_hole_2d([w, d]);
    }
}

// 右框层板 2D：局部原点 = 已右移的左前柱心
module shelf_board_right_2d() {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;
    o = shelf_outline_outset();
    oc = tabletopCutoutOvercutMm;
    cut_x = shelf_rf_cut_x();
    cut_y = shelf_rf_cut_y();
    posts = [
        [0, 0],
        [w, 0],
        [w - sx, d],
        [0, d]
    ];
    assert(cut_y > 0 && cut_y < d,
        str("shelf_rf_cut_y 须在 (0, depth) 内，当前=", cut_y));
    difference() {
        offset(delta = o)
            square([w, d]);
        translate([w - cut_x, d - cut_y])
            square([cut_x + o + oc, cut_y + o + oc]);
        for (p = posts)
            shelf_post_hole_2d(p);
    }
}

module shelf_board_rect(size_xy) {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_rect_2d(size_xy);
}

module shelf_board_right_rect() {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_right_2d();
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
