// table/shelves.scad — 框上层板（视觉）
//
// 四块 12mm 木板：
//   左框下 @ lf_z_lo；左框上 @ crossTieZ（承在拉结三通顶）
//   右框下 @ rf_z_lo；右框中 @ rf_z_hi（承在立体四通顶）
// 承面 = 管件主体顶（中心 Z + 管外径/2）；立柱穿孔落板
// 左柜外轮廓手填 leftShelfBoardWMm × leftShelfBoardDMm；孔边距板边 ≥ shelfHoleEdgeClearMm
// 右框板：柱心跨距 + outset；右后切矩形

shelfHoleEdgeClearMm = 30;
shelfHoleExtraMm = 5; // 孔径 = 管件外螺纹段外径 + 本值
shelfEdgeOverhangMm = 10; // 右框旧兼容；左框不用

function shelf_fitting_od() = pipeOD + 2 * (pipeOD * 0.1);
function shelf_post_cut_d() = shelf_fitting_od() + shelfHoleExtraMm;
function shelf_board_outset() = shelfHoleEdgeClearMm + shelf_post_cut_d() / 2;
function shelf_outline_outset() = shelf_board_outset();

function shelf_rf_cut_x() = rightFrameShiftX;
function shelf_rf_cut_y() = tabletopCutoutY - frameInset;

function shelf_left_margin_x() = (leftShelfBoardWMm - leftFrameWidth) / 2;
function shelf_left_margin_y() = (leftShelfBoardDMm - leftFrameDepth) / 2;

function shelf_left_outer_w() = leftShelfBoardWMm;
function shelf_left_outer_d() = leftShelfBoardDMm;
function shelf_right_outer_w() = rightFrameWidth + 2 * shelf_board_outset();
function shelf_right_outer_d() = rightFrameDepth + 2 * shelf_board_outset();

module shelf_post_hole_2d(post) {
    translate([post[0], post[1]])
        circle(d = shelf_post_cut_d());
}

// 圆角矩形外轮廓（四角 R = shelfCornerR）
module shelf_rounded_rect_2d(w, d, r = shelfCornerR) {
    offset(r = r)
        offset(delta = -r)
            square([w, d]);
}

// 左柜托板 2D：原点 = 板左前角；柱心内缩 margin；四角圆角
module shelf_board_left_2d() {
    ow = leftShelfBoardWMm;
    od = leftShelfBoardDMm;
    mx = shelf_left_margin_x();
    my = shelf_left_margin_y();
    min_m = shelf_board_outset();
    assert(ow >= leftFrameWidth + 2 * min_m - 0.01,
        str("leftShelfBoardWMm=", ow, " 过窄，须 ≥ ", leftFrameWidth + 2 * min_m));
    assert(od >= leftFrameDepth + 2 * min_m - 0.01,
        str("leftShelfBoardDMm=", od, " 过窄，须 ≥ ", leftFrameDepth + 2 * min_m));
    difference() {
        shelf_rounded_rect_2d(ow, od);
        shelf_post_hole_2d([mx, my]);
        shelf_post_hole_2d([mx + leftFrameWidth, my]);
        shelf_post_hole_2d([mx, my + leftFrameDepth]);
        shelf_post_hole_2d([mx + leftFrameWidth, my + leftFrameDepth]);
    }
}

// 右框层板 2D：局部原点 = 已右移的左前柱心；外包圆角；右后切洞
module shelf_board_right_2d() {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;
    o = shelf_board_outset();
    r = shelfCornerR;
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
    assert(o >= r - 0.01, str("shelf outset 须 ≥ 圆角 R=", r));
    difference() {
        // 先外扩再倒圆角（等效外包尺寸不变）
        offset(r = r)
            offset(delta = o - r)
                square([w, d]);
        translate([w - cut_x, d - cut_y])
            square([cut_x + o + oc, cut_y + o + oc]);
        for (p = posts)
            shelf_post_hole_2d(p);
    }
}

module shelf_board_left_rect() {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_left_2d();
}

module shelf_board_right_rect() {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_right_2d();
}

// panel_plans 旧矩形接口（同样圆角）
module shelf_board_rect_2d(size_xy) {
    w = size_xy[0];
    d = size_xy[1];
    o = shelf_board_outset();
    r = shelfCornerR;
    difference() {
        offset(r = r)
            offset(delta = o - r)
                square([w, d]);
        shelf_post_hole_2d([0, 0]);
        shelf_post_hole_2d([w, 0]);
        shelf_post_hole_2d([0, d]);
        shelf_post_hole_2d([w, d]);
    }
}

module shelf_board_rect(size_xy) {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_rect_2d(size_xy);
}

module table_shelves() {
    z_on_fitting = pipeOD / 2;
    col = [0.62, 0.45, 0.28, 0.65];
    sx = rightFrameShiftX;
    mx = shelf_left_margin_x();
    my = shelf_left_margin_y();

    echo(str(
        "[层板] 左柜托板外轮廓=", leftShelfBoardWMm, "×", leftShelfBoardDMm,
        " 边距X/Y=", mx, "/", my,
        " 孔边距板边≥", shelfHoleEdgeClearMm,
        " 孔径=", shelf_post_cut_d()
    ));

    // 左框下 / 上：原点改为板左前角
    color(col)
        translate([
            leftFrameOriginX - mx,
            leftFrameOriginY - my,
            lf_z_lo + z_on_fitting
        ])
            shelf_board_left_rect();

    color(col)
        translate([
            leftFrameOriginX - mx,
            leftFrameOriginY - my,
            crossTieZ + z_on_fitting
        ])
            shelf_board_left_rect();

    color(col)
        translate([rightFrameOriginX + sx, rightFrameOriginY, rf_z_lo + z_on_fitting])
            shelf_board_right_rect();

    color(col)
        translate([rightFrameOriginX + sx, rightFrameOriginY, rf_z_hi + z_on_fitting])
            shelf_board_right_rect();
}
