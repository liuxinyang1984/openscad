// table/panel_plans.scad — 桌板 / 层板俯视下料平面图（2D）
//
// 用法：在 OpenSCAD 中直接打开本文件 Preview/Render
// 导出：File → Export → Export as SVG… / DXF…
// 单位 mm；标注为外轮廓与关键开洞/孔径

include <table_config.scad>
include <standards.scad>
include <tabletop.scad>
include <shelves.scad>

planGapMm = 280;
planDimOffsetMm = 60;
planFontSize = 20;
planTitleSize = 32;
planTickMm = 8;
planNoteSize = 15;

function plan_mm(v) = str(round(v), " mm");

module plan_label(pos, s, size = planFontSize, halign = "center", valign = "center") {
    translate(pos)
        text(s, size = size, halign = halign, valign = valign,
             font = "Noto Sans CJK SC");
}

// 水平尺寸：量 x0→x1，标注线在 y=base_y + side*offset
module plan_dim_x(x0, x1, base_y, label, side = -1, offset = planDimOffsetMm) {
    y = base_y + side * offset;
    mid = (x0 + x1) / 2;
    line_2d([x0, base_y], [x0, y]);
    line_2d([x1, base_y], [x1, y]);
    line_2d([x0, y], [x1, y]);
    line_2d([x0, y - planTickMm / 2], [x0, y + planTickMm / 2]);
    line_2d([x1, y - planTickMm / 2], [x1, y + planTickMm / 2]);
    plan_label([mid, y + side * 16], label);
}

// 竖直尺寸：量 y0→y1，标注线在 x=base_x + side*offset
module plan_dim_y(y0, y1, base_x, label, side = -1, offset = planDimOffsetMm) {
    x = base_x + side * offset;
    mid = (y0 + y1) / 2;
    line_2d([base_x, y0], [x, y0]);
    line_2d([base_x, y1], [x, y1]);
    line_2d([x, y0], [x, y1]);
    line_2d([x - planTickMm / 2, y0], [x + planTickMm / 2, y0]);
    line_2d([x - planTickMm / 2, y1], [x + planTickMm / 2, y1]);
    translate([x + side * 16, mid])
        rotate([0, 0, 90])
            text(label, size = planFontSize, halign = "center", valign = "center",
                 font = "Noto Sans CJK SC");
}

module line_2d(a, b, w = 0.6) {
    hull() {
        translate(a) circle(d = w, $fn = 12);
        translate(b) circle(d = w, $fn = 12);
    }
}

// 圆角引出标注：从角点沿 diag 方向拉短线，末端写 Rxx
module plan_corner_r(corner, diag, r, label_extra = "") {
    len = 55;
    tip = corner + diag * len;
    line_2d(corner, tip);
    plan_label(tip + diag * 12, str("R", r, label_extra), size = planNoteSize);
}

// -----------------------------------------------------------------------------
// 桌板
// -----------------------------------------------------------------------------
module plan_tabletop() {
    w = table_length;
    d = table_width;
    cx = tabletopCutoutX;
    cy = tabletopCutoutY;
    r = tabletopCornerR;
    // 单位对角方向（指向板外）
    inv = 1 / sqrt(2);

    color([0.72, 0.55, 0.32])
        tabletop_2d();

    // 标题放在板上方，避开开洞标注
    plan_label([w / 2, d + 110],
        str("桌面板  t=", plan_mm(tabletopThickness), "  ×1"),
        size = planTitleSize);

    // 外包：下边 / 左边
    plan_dim_x(0, w, 0, plan_mm(w), side = -1, offset = 70);
    plan_dim_y(0, d, 0, plan_mm(d), side = -1, offset = 70);

    // 开洞：宽标在板顶外侧，高标在板右外侧
    plan_dim_x(w - cx, w, d, plan_mm(cx), side = 1, offset = 45);
    plan_dim_y(d - cy, d, w, plan_mm(cy), side = 1, offset = 45);

    // 三圆角（左前 / 左后 / 右前）；右后为开洞直角
    plan_corner_r([0, 0], [-inv, -inv], r);
    plan_corner_r([0, d], [-inv, inv], r);
    plan_corner_r([w, 0], [inv, -inv], r);
    plan_label([w - cx / 2, d - cy - 35],
        "开洞角直角",
        size = planNoteSize);

    plan_label([w - cx - 180, d - cy / 2],
        str("开洞 ", cx, "×", cy, " +过切", tabletopCutoutOvercutMm),
        size = planNoteSize, halign = "right");
}

// -----------------------------------------------------------------------------
// 左框层板（柱心坐标；外轮廓已含 outset）
// -----------------------------------------------------------------------------
module plan_shelf_left() {
    w = leftFrameWidth;
    d = leftFrameDepth;
    o = shelf_outline_outset();
    ow = shelf_left_outer_w();
    od = shelf_left_outer_d();
    hole_d = shelf_post_cut_d();

    color([0.62, 0.45, 0.28])
        shelf_board_rect_2d([w, d]);

    // 标题在最上；柱心尺寸在标题下、板顶上
    plan_label([w / 2, d + o + 130],
        str("左框层板  t=", plan_mm(shelfThicknessMm), "  ×1"),
        size = planTitleSize);

    plan_dim_x(0, w, d + o, str("柱心 ", plan_mm(w)), side = 1, offset = 45);
    plan_dim_y(0, d, w + o, str("柱心 ", plan_mm(d)), side = 1, offset = 50);

    // 外轮廓：下边 / 左边
    plan_dim_x(-o, w + o, -o, plan_mm(ow), side = -1, offset = 55);
    plan_dim_y(-o, d + o, -o, plan_mm(od), side = -1, offset = 55);

    plan_label([w / 2, d / 2 + 30],
        str("∅", round(hole_d), " ×4（柱心）"),
        size = planNoteSize);
    plan_label([w / 2, -o - 100],
        str("外延 outset=", round(o), "（管外径/2+", shelfEdgeOverhangMm, "）"),
        size = planNoteSize);
}

// -----------------------------------------------------------------------------
// 右框层板（两块同形；柱心坐标）
// -----------------------------------------------------------------------------
module plan_shelf_right() {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;
    o = shelf_outline_outset();
    ow = shelf_right_outer_w();
    od = shelf_right_outer_d();
    cut_x = shelf_rf_cut_x();
    cut_y = shelf_rf_cut_y();
    hole_d = shelf_post_cut_d();

    color([0.62, 0.45, 0.28])
        shelf_board_right_2d();

    // 标题最上；其下依次：后柱心、前柱心（拉开间距）
    plan_label([w / 2, d + o + 175],
        str("右框层板  t=", plan_mm(shelfThicknessMm), "  ×2（下框+中框）"),
        size = planTitleSize);

    plan_dim_x(0, w - sx, d + o, str("后柱心 ", plan_mm(w - sx)), side = 1, offset = 95);
    plan_dim_x(0, w, d + o, str("前柱心 ", plan_mm(w)), side = 1, offset = 45);

    // 外轮廓下边；深向尺寸只放右侧，避免与左边挤在一起
    plan_dim_x(-o, w + o, -o, plan_mm(ow), side = -1, offset = 55);
    plan_dim_y(-o, d + o, w + o, plan_mm(od), side = 1, offset = 55);
    plan_dim_y(0, d, w + o, str("柱心 ", plan_mm(d)), side = 1, offset = 110);

    // 切洞：宽标在缺口底边下方；高标在板右最外侧（躲开外轮廓/柱心深向尺寸）
    plan_dim_x(w - cut_x, w + o, d - cut_y, plan_mm(cut_x), side = -1, offset = 40);
    plan_dim_y(d - cut_y, d + o, w + o, plan_mm(cut_y), side = 1, offset = 165);

    plan_label([w / 2 - 40, d / 2 - 40],
        str("∅", round(hole_d), " ×4（柱心；右后未右移）"),
        size = planNoteSize);
    plan_label([w - cut_x - 120, d - cut_y / 2],
        str("切 ", cut_x, "×", cut_y, " +过切"),
        size = planNoteSize, halign = "right");
}

module panel_plans() {
    gap = planGapMm;
    o = shelf_outline_outset();

    plan_tabletop();

    // 左框在桌板下方（加大间隙给底部尺寸）
    y_left = -(table_width + gap + o + 40);
    translate([0, y_left])
        plan_shelf_left();

    // 右框在左板右侧（加大间隙给右侧尺寸）
    x_right = shelf_left_outer_w() + gap + 80;
    translate([x_right, y_left])
        plan_shelf_right();

    plan_label([table_length / 2, table_width + 170],
        "面板下料平面图（mm）",
        size = 28);
}

panel_plans();
