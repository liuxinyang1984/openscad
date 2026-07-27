// table/right_frame.scad — 右框架几何
//
// 依赖：table_config.scad + standards.scad
// 坐标（局部）：原点对齐「未右移的左前网」；实际左柱在 x=rightFrameShiftX
//   左前/左后/右前立柱右移 rightFrameShiftX；右后立柱不移（躲开开洞立柱）
//   前缘在原右缘 x=rightFrameWidth 处用平面三通分出右侧纵管
//
// 直管起止约定：相对管件中心外偏 fittingHeadExtraMm，净长 = 中心距 − 2×fittingHeadExtraMm

module rf_pipe_z(length) {
    pipe(pipe_params, length);
}

module rf_pipe_x(length) {
    rotate([0, 90, 0])
        pipe(pipe_params, length);
}

module rf_pipe_y(length) {
    rotate([-90, 0, 0])
        pipe(pipe_params, length);
}

// -----------------------------------------------------------------------------
// 顶托：翻法兰 + 对丝（法兰承面 = frameHeight）
// -----------------------------------------------------------------------------

module rf_top_flange_coupling() {
    translate([0, 0, frameHeight])
        rotate([0, 180, 0])
            threaded_flange(flange_params);
    pl_cz = frameHeight - flangeThicknessMm - couplingTotalMm / 2;
    difference() {
        translate([0, 0, pl_cz])
            pipe_link(pipe_params, couplingTotalMm, couplingHexMm);
        translate([0, 0, frameHeight])
            cylinder(r = 50, h = 20);
    }
}

// 垂挂直管：拉结三通上缘 → 顶平面四通下缘（净长 hangPipeNetMm）
module rf_hang_pipe() {
    translate([0, 0, hangPipeStartZ])
        rf_pipe_z(hangPipeNetMm);
}

// -----------------------------------------------------------------------------
// 右缘立柱：上四通 → 单段衔接 → 顶四通 + 顶托
// -----------------------------------------------------------------------------

module rf_corner_post_right(rot_z) {
    mid_z = rf_z_lo + fittingHeadExtraMm;

    union() {
        threaded_flange(flange_params);

        translate([0, 0, flangeThicknessMm])
            rf_pipe_z(footPipeNetMm);

        translate([0, 0, rf_z_lo])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, mid_z])
            rf_pipe_z(rfMidPipeNetMm);

        translate([0, 0, rf_z_hi])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, rfStemStartZ])
            rf_pipe_z(rfStemNetMm);

        translate([0, 0, rf_z_top])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        rf_top_flange_coupling();
    }
}

// -----------------------------------------------------------------------------
// 左缘立柱：垂挂 + 顶平面四通
// -----------------------------------------------------------------------------

module rf_corner_post_left(rot_z, hang_tee_rot_z = 0, top_rot_z = 90) {
    mid_z = rf_z_lo + fittingHeadExtraMm;
    stem_below_z = rf_z_hi + fittingHeadExtraMm;

    union() {
        threaded_flange(flange_params);

        translate([0, 0, flangeThicknessMm])
            rf_pipe_z(footPipeNetMm);

        translate([0, 0, rf_z_lo])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, mid_z])
            rf_pipe_z(rfMidPipeNetMm);

        translate([0, 0, rf_z_hi])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, stem_below_z])
            rf_pipe_z(rfStemBelowTieNetMm);

        translate([0, 0, crossTieZ])
            rotate([0, 0, hang_tee_rot_z])
                tee(pipe_params);

        rf_hang_pipe();

        translate([0, 0, rf_z_top])
            rotate([0, 0, top_rot_z])
                fourway(pipe_params);

        rf_top_flange_coupling();
    }
}

// -----------------------------------------------------------------------------
// 前缘分叉三通：主通 ±X，支口 +Y（接原右缘纵管）
// -----------------------------------------------------------------------------

module rf_front_right_tee() {
    // 主通 ±X、支口沿 Y；相对初值绕 +X 翻 180°
    rotate([180, 0, 0])
        rotate([0, 0, 180])
            rotate([0, -90, 0])
                tee(pipe_params);
}

// -----------------------------------------------------------------------------
// 一层 XY：梯形 — 前缘三通分左右横管 + 右侧纵管；后缘短横管；可选左缘纵管
// -----------------------------------------------------------------------------

module rf_rail_layer_shifted(z, skip_left_y = false) {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;
    hx = fittingHeadExtraMm;

    // 前缘三通 @ 原右缘 x=w（未随右前柱右移）
    translate([w, 0, z])
        rf_front_right_tee();

    // 前缘左段：左前柱 → 三通
    translate([sx + hx, 0, z])
        rf_pipe_x(rfSpanXFrontLeftNetMm);

    // 前缘右段：三通 → 右前柱
    translate([w + hx, 0, z])
        rf_pipe_x(rfSpanXFrontRightNetMm);

    // 后缘：左后柱 → 右后柱（右后不右移，跨距缩短）
    translate([sx + hx, d, z])
        rf_pipe_x(rfSpanXRearNetMm);

    // 左侧纵管（顶层跳过，垂挂层另做）
    if (!skip_left_y)
        translate([sx, hx, z])
            rf_pipe_y(rfSpanYNetMm);

    // 右侧纵管：三通 → 右后柱（仍在 x=w）
    translate([w, hx, z])
        rf_pipe_y(rfSpanYNetMm);
}

// -----------------------------------------------------------------------------
// 左缘深向垂挂（局部 x = rightFrameShiftX）
// -----------------------------------------------------------------------------

module rf_left_edge_depth_tie() {
    sx = rightFrameShiftX;
    y_mid = rightFrameDepth / 2;
    seg = rfEdgeHalfNetMm;
    hx = fittingHeadExtraMm;

    translate([sx, hx, crossTieZ])
        rf_pipe_y(seg);

    translate([sx, y_mid, crossTieZ])
        rotate([90, 0, 0])
            rotate([0, 0, 90])
                tee(pipe_params);

    translate([sx, y_mid + hx, crossTieZ])
        rf_pipe_y(seg);
}

// -----------------------------------------------------------------------------
// 总装
// -----------------------------------------------------------------------------

module table_right_frame() {
    sx = rightFrameShiftX;
    w = rightFrameWidth;
    d = rightFrameDepth;

    // 左前 / 右前（右移）；左后（右移）；右后（不移）
    translate([sx, 0, 0])
        rf_corner_post_left(180, 0, 90);
    translate([w + sx, 0, 0])
        rf_corner_post_right(-90);
    translate([sx, d, 0])
        rotate([0, 0, 180])
            rf_corner_post_left(-90, 0, 90);
    translate([w, d, 0])
        rotate([0, 0, 180])
            rf_corner_post_right(180);

    rf_rail_layer_shifted(rf_z_lo);
    rf_rail_layer_shifted(rf_z_hi);
    rf_rail_layer_shifted(rf_z_top, skip_left_y = true);

    rf_left_edge_depth_tie();

    e = fittingHeadExtraMm;
    assert(rfMidPipeNetMm > 0 && abs(rfMidPipeNetMm - (rf_z_hi - rf_z_lo - 2 * e)) < 0.01,
        "中立管搭接异常");
    assert(rfStemNetMm > 0 && abs(rfStemNetMm - (rf_z_top - rf_z_hi - 2 * e)) < 0.01,
        "右缘上衔接搭接异常");
    assert(rfStemBelowTieNetMm > 0 && abs(rfStemBelowTieNetMm - (crossTieZ - rf_z_hi - 2 * e)) < 0.01,
        "左缘垂挂竖管搭接异常");
    assert(hangPipeNetMm > 0 && abs(hangPipeNetMm - (rf_z_top - crossTieZ - 2 * e)) < 0.01,
        "垂挂连接管搭接异常");
    assert(rfSpanXFrontLeftNetMm > 0
        && abs(rfSpanXFrontLeftNetMm - (rightFrameWidth - rightFrameShiftX - 2 * e)) < 0.01,
        "前缘左段横拉搭接异常");
    assert(rfSpanXFrontRightNetMm > 0
        && abs(rfSpanXFrontRightNetMm - (rightFrameShiftX - 2 * e)) < 0.01,
        "前缘右段横拉搭接异常");
    assert(rfSpanXRearNetMm > 0
        && abs(rfSpanXRearNetMm - (rightFrameWidth - rightFrameShiftX - 2 * e)) < 0.01,
        "后缘横拉搭接异常");
    assert(rfSpanYNetMm > 0 && abs(rfSpanYNetMm - (rightFrameDepth - 2 * e)) < 0.01,
        "Y纵拉搭接异常");
    assert(rfEdgeHalfNetMm > 0 && abs(rfEdgeHalfNetMm - (rightFrameDepth / 2 - 2 * e)) < 0.01,
        "左缘半跨搭接异常");
    assert(footPipeNetMm > 0, "脚管净长异常");

    echo(str(
        "[右框梯形] shift=", sx,
        " 前跨=", rightFrameWidth, " 后跨=", rightFrameWidth - sx,
        " 前左/右段净长=", rfSpanXFrontLeftNetMm, "/", rfSpanXFrontRightNetMm,
        " 后横=", rfSpanXRearNetMm,
        " Y纵=", rfSpanYNetMm
    ));
}

module table_right_frame_in_place() {
    translate([rightFrameOriginX, rightFrameOriginY, 0])
        table_right_frame();
}
