// shelf/panel_plans.scad — 墙书架层板俯视下料平面图（2D）
//
// 用法：在 OpenSCAD 中直接打开本文件 Preview/Render
// 导出：File → Export → Export as SVG… / DXF…
// 单位 mm；含外轮廓、圆角、立管孔

include <standards.scad>
include <boards.scad>

planGapMm = 220;
planDimOffsetMm = 55;
planFontSize = 18;
planTitleSize = 28;
planTickMm = 8;
planNoteSize = 14;

function plan_mm(v) = str(round(v), " mm");

module plan_label(pos, s, size = planFontSize, halign = "center", valign = "center") {
    translate(pos)
        text(s, size = size, halign = halign, valign = valign,
             font = "Noto Sans CJK SC");
}

module line_2d(a, b, w = 0.6) {
    hull() {
        translate(a) circle(d = w, $fn = 12);
        translate(b) circle(d = w, $fn = 12);
    }
}

module plan_dim_x(x0, x1, base_y, label, side = -1, offset = planDimOffsetMm) {
    y = base_y + side * offset;
    mid = (x0 + x1) / 2;
    line_2d([x0, base_y], [x0, y]);
    line_2d([x1, base_y], [x1, y]);
    line_2d([x0, y], [x1, y]);
    line_2d([x0, y - planTickMm / 2], [x0, y + planTickMm / 2]);
    line_2d([x1, y - planTickMm / 2], [x1, y + planTickMm / 2]);
    plan_label([mid, y + side * 14], label);
}

module plan_dim_y(y0, y1, base_x, label, side = -1, offset = planDimOffsetMm) {
    x = base_x + side * offset;
    mid = (y0 + y1) / 2;
    line_2d([base_x, y0], [x, y0]);
    line_2d([base_x, y1], [x, y1]);
    line_2d([x, y0], [x, y1]);
    line_2d([x - planTickMm / 2, y0], [x + planTickMm / 2, y0]);
    line_2d([x - planTickMm / 2, y1], [x + planTickMm / 2, y1]);
    translate([x + side * 14, mid])
        rotate([0, 0, 90])
            text(label, size = planFontSize, halign = "center", valign = "center",
                 font = "Noto Sans CJK SC");
}

module plan_corner_r(corner, diag, r) {
    len = 45;
    tip = corner + diag * len;
    line_2d(corner, tip);
    plan_label(tip + diag * 10, str("R", r), size = planNoteSize);
}

// 板内柱心 X（相对板左缘）列表 → 前后两排孔
function plan_board_posts(post_xs_local) =
    let (dm = shelfBoardDepthMarginMm, d = shelfBoardDepthMm)
        [for (px = post_xs_local) for (py = [dm, d - dm]) [px, py]];

module plan_shelf_board(title, qty, board_len, post_xs_local) {
    d = shelfBoardDepthMm;
    m = shelfBoardSideMarginMm;
    dm = shelfBoardDepthMarginMm;
    r = shelfBoardCornerR;
    hole_d = shelfBoardHoleD;
    inv = 1 / sqrt(2);
    posts = plan_board_posts(post_xs_local);
    n_holes = len(posts);

    color([0.62, 0.45, 0.28])
        shelf_board_2d([board_len, d], posts);

    plan_label([board_len / 2, d + 100],
        str(title, "  t=", plan_mm(shelfThicknessMm), "  ×", qty),
        size = planTitleSize);

    // 外轮廓
    plan_dim_x(0, board_len, 0, plan_mm(board_len), side = -1, offset = 55);
    plan_dim_y(0, d, 0, plan_mm(d), side = -1, offset = 55);

    // 端柱心距 / 前排孔边距
    plan_dim_x(m, board_len - m, d, str("柱心跨 ", plan_mm(board_len - 2 * m)),
        side = 1, offset = 40);
    plan_dim_y(dm, d - dm, board_len, str("柱心深 ", plan_mm(d - 2 * dm)),
        side = 1, offset = 45);

    // 各柱心到左缘（便于钻孔）
    for (i = [0 : len(post_xs_local) - 1]) {
        px = post_xs_local[i];
        plan_label([px, dm - 22],
            str(round(px)),
            size = planNoteSize);
    }

    plan_corner_r([0, 0], [-inv, -inv], r);
    plan_corner_r([board_len, 0], [inv, -inv], r);

    plan_label([board_len / 2, d / 2],
        str("∅", round(hole_d), " ×", n_holes,
            "  边距≥", shelfBoardHoleEdgeClearMm,
            "  R", r),
        size = planNoteSize);
}

module shelf_panel_plans() {
    gap = planGapMm;
    d = shelfBoardDepthMm;

    // 右架下层：三柱
    right_lower_posts = [
        shelfBoardSideMarginMm,
        shelfMidPostX - shelfLowerBoardLeftX,
        shelfLowerBoardLenMm - shelfBoardSideMarginMm
    ];
    // 右架上层：两柱（对齐中/右）
    right_upper_posts = [
        shelfBoardSideMarginMm,
        shelfUpperBoardLenMm - shelfBoardSideMarginMm
    ];
    // 左架：三柱居中
    left_posts = [
        shelfBoardSideMarginMm,
        shelfLeftMidPostX - shelfLeftBoardLeftX,
        shelfLeftBoardLenMm - shelfBoardSideMarginMm
    ];

    plan_label([shelfLowerBoardLenMm / 2, d + 160],
        "墙书架层板下料平面图（mm）",
        size = 26);

    // 右架下层
    plan_shelf_board("右架下层", 1, shelfLowerBoardLenMm, right_lower_posts);

    // 右架上层
    translate([0, -(d + gap)])
        plan_shelf_board("右架上层", 1, shelfUpperBoardLenMm, right_upper_posts);

    // 左架（上下同形 ×2）
    translate([0, -2 * (d + gap)])
        plan_shelf_board("左架层板（上=下）", 2, shelfLeftBoardLenMm, left_posts);
}

shelf_panel_plans();
