// table/right_frame.scad — 右框架几何
//
// 依赖：table_config.scad + standards.scad
// 坐标（局部）：原点 = 左前立柱；+X → 右前；+Y → 左后（桌深）
//
// 直管起止约定：相对管件中心外偏 fittingHeadExtraMm，净长 = 中心距 − 2×fittingHeadExtraMm
// （停在搭接外缘，不伸进管件中心）

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

        // 脚管：法兰盘顶 → 下四通下缘
        translate([0, 0, flangeThicknessMm])
            rf_pipe_z(footPipeNetMm);

        translate([0, 0, rf_z_lo])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        // 中立管：下四通上缘 → 上四通下缘
        translate([0, 0, mid_z])
            rf_pipe_z(rfMidPipeNetMm);

        translate([0, 0, rf_z_hi])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        // 上半衔接：上四通上缘 → 顶四通下缘
        translate([0, 0, rfStemStartZ])
            rf_pipe_z(rfStemNetMm);

        translate([0, 0, rf_z_top])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        rf_top_flange_coupling();
    }
}

// -----------------------------------------------------------------------------
// 左缘立柱：上四通 → 直通 → 拉结三通 − 垂挂直管 − 顶平面四通 → 顶托
// 顶用平面四通（十字）：±Z（垂挂管 / 顶法兰）+ ±横通（框内 +X 与对接左框 −X）
// top_rot_z=90：横通从局部 ±Y 转到世界 ±X
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

        // 垂挂竖管：上四通上缘 → 拉结三通下缘
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
// XY 横纵拉（两端：柱心 ± fittingHeadExtraMm）
// -----------------------------------------------------------------------------

module rf_rail_layer(z, skip_left_y = false) {
    frame_w = rightFrameWidth;
    frame_d = rightFrameDepth;
    hx = fittingHeadExtraMm;

    translate([hx, 0, z])
        rf_pipe_x(rfSpanXNetMm);
    translate([hx, frame_d, z])
        rf_pipe_x(rfSpanXNetMm);

    if (!skip_left_y)
        translate([0, hx, z])
            rf_pipe_y(rfSpanYNetMm);
    translate([frame_w, hx, z])
        rf_pipe_y(rfSpanYNetMm);
}

// -----------------------------------------------------------------------------
// 左缘深向：半跨 + 中位三通（两端扣搭接）
// -----------------------------------------------------------------------------

module rf_left_edge_depth_tie() {
    y_mid = rightFrameDepth / 2;
    seg = rfEdgeHalfNetMm;
    hx = fittingHeadExtraMm;

    translate([0, hx, crossTieZ])
        rf_pipe_y(seg);

    translate([0, y_mid, crossTieZ])
        rotate([90, 0, 0])
            rotate([0, 0, 90])
                tee(pipe_params);

    translate([0, y_mid + hx, crossTieZ])
        rf_pipe_y(seg);
}

// -----------------------------------------------------------------------------
// 总装
// -----------------------------------------------------------------------------

module table_right_frame() {
    frame_w = rightFrameWidth;
    frame_d = rightFrameDepth;

    rf_corner_post_left(180, 0, 90);
    translate([frame_w, 0, 0])
        rf_corner_post_right(-90);
    translate([0, frame_d, 0])
        rotate([0, 0, 180])
            rf_corner_post_left(-90, 0, 90);
    translate([frame_w, frame_d, 0])
        rotate([0, 0, 180])
            rf_corner_post_right(180);

    rf_rail_layer(rf_z_lo);
    rf_rail_layer(rf_z_hi);
    rf_rail_layer(rf_z_top, skip_left_y = true);

    rf_left_edge_depth_tie();

    // 搭接检查：净长须 > 0，且 = 中心距 − 2×extra
    e = fittingHeadExtraMm;
    assert(rfMidPipeNetMm > 0 && abs(rfMidPipeNetMm - (rf_z_hi - rf_z_lo - 2 * e)) < 0.01,
        "中立管搭接异常");
    assert(rfStemNetMm > 0 && abs(rfStemNetMm - (rf_z_top - rf_z_hi - 2 * e)) < 0.01,
        "右缘上衔接搭接异常");
    assert(rfStemBelowTieNetMm > 0 && abs(rfStemBelowTieNetMm - (crossTieZ - rf_z_hi - 2 * e)) < 0.01,
        "左缘垂挂竖管搭接异常");
    assert(hangPipeNetMm > 0 && abs(hangPipeNetMm - (rf_z_top - crossTieZ - 2 * e)) < 0.01,
        "垂挂连接管搭接异常");
    assert(rfSpanXNetMm > 0 && abs(rfSpanXNetMm - (rightFrameWidth - 2 * e)) < 0.01,
        "X横拉搭接异常");
    assert(rfSpanYNetMm > 0 && abs(rfSpanYNetMm - (rightFrameDepth - 2 * e)) < 0.01,
        "Y纵拉搭接异常");
    assert(rfEdgeHalfNetMm > 0 && abs(rfEdgeHalfNetMm - (rightFrameDepth / 2 - 2 * e)) < 0.01,
        "左缘半跨搭接异常");
    assert(footPipeNetMm > 0, "脚管净长异常");

    echo(str(
        "[右框搭接检查 OK] extra=", e,
        " 脚管=", footPipeNetMm,
        " 中立管=", rfMidPipeNetMm,
        " 右衔接=", rfStemNetMm,
        " 左垂挂竖=", rfStemBelowTieNetMm,
        " X横=", rfSpanXNetMm,
        " Y纵=", rfSpanYNetMm,
        " 半跨=", rfEdgeHalfNetMm
    ));
}

module table_right_frame_in_place() {
    translate([rightFrameOriginX, rightFrameOriginY, 0])
        table_right_frame();
}
