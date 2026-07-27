// table/left_frame.scad — 左框架几何（电脑机箱侧）
//
// 依赖：table_config.scad + standards.scad（可与 right_frame 同 include）
// 坐标（局部）：原点 = 左前立柱；+X → 右前（对接右框）；+Y → 左后
//
// 单层：底圈四通 + 右缘垂挂（crossTieZ 与右框对齐）+ 右前/右后顶平面四通（对接横管）+ 顶托。

module lf_pipe_z(length) {
    pipe(pipe_params, length);
}

module lf_pipe_x(length) {
    rotate([0, 90, 0])
        pipe(pipe_params, length);
}

module lf_pipe_y(length) {
    rotate([-90, 0, 0])
        pipe(pipe_params, length);
}

module lf_top_flange_coupling() {
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

module lf_tee_coupling() {
    translate([0, 0, crossTieCouplingZ])
        pipe_link(pipe_params, couplingTotalMm, couplingHexMm);
}

// -----------------------------------------------------------------------------
// 左缘立柱（外侧）：底四通 → 单段立管 → 顶四通 + 顶托
// -----------------------------------------------------------------------------

module lf_corner_post_left(rot_z) {
    stem_z = lf_z_lo + fittingHeadExtraMm;

    union() {
        threaded_flange(flange_params);

        translate([0, 0, flangeThicknessMm])
            lf_pipe_z(footPipeNetMm);

        translate([0, 0, lf_z_lo])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, stem_z])
            lf_pipe_z(lfStemNetMm);

        translate([0, 0, lf_z_top])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        lf_top_flange_coupling();
    }
}

// -----------------------------------------------------------------------------
// 右缘立柱（朝桌心）：底四通 → 立管 → 拉结三通 − 对丝 − 顶平面四通 → 顶托
// 顶用平面四通（十字）：±Z（对丝 / 顶法兰）+ ±横通（框内 −X 与对接右框 +X）
// top_rot_z=90：横通从局部 ±Y 转到世界 ±X
// -----------------------------------------------------------------------------

module lf_corner_post_right(rot_z, hang_tee_rot_z = 0, top_rot_z = 90) {
    stem_below_z = lf_z_lo + fittingHeadExtraMm;

    union() {
        threaded_flange(flange_params);

        translate([0, 0, flangeThicknessMm])
            lf_pipe_z(footPipeNetMm);

        translate([0, 0, lf_z_lo])
            rotate([0, 0, rot_z])
                fourway3d(pipe_params);

        translate([0, 0, stem_below_z])
            lf_pipe_z(lfStemBelowTieNetMm);

        translate([0, 0, crossTieZ])
            rotate([0, 0, hang_tee_rot_z])
                tee(pipe_params);

        lf_tee_coupling();

        translate([0, 0, lf_z_top])
            rotate([0, 0, top_rot_z])
                fourway(pipe_params);

        lf_top_flange_coupling();
    }
}

// -----------------------------------------------------------------------------
// XY 横纵拉（两端：柱心 ± fittingHeadExtraMm）
// -----------------------------------------------------------------------------

module lf_rail_layer(z, skip_right_y = false) {
    frame_w = leftFrameWidth;
    frame_d = leftFrameDepth;
    hx = fittingHeadExtraMm;

    translate([hx, 0, z])
        lf_pipe_x(lfSpanXNetMm);
    translate([hx, frame_d, z])
        lf_pipe_x(lfSpanXNetMm);

    translate([0, hx, z])
        lf_pipe_y(lfSpanYNetMm);
    if (!skip_right_y)
        translate([frame_w, hx, z])
            lf_pipe_y(lfSpanYNetMm);
}

// -----------------------------------------------------------------------------
// 右缘深向：半跨 + 中位三通（支口朝 +X，对接 desk_cross）
// -----------------------------------------------------------------------------

module lf_right_edge_depth_tie() {
    frame_w = leftFrameWidth;
    y_mid = leftFrameDepth / 2;
    seg = lfEdgeHalfNetMm;
    hx = fittingHeadExtraMm;

    translate([frame_w, hx, crossTieZ])
        lf_pipe_y(seg);

    translate([frame_w, y_mid, crossTieZ])
        rotate([90, 0, 0])
            rotate([0, 0, -90])
                tee(pipe_params);

    translate([frame_w, y_mid + hx, crossTieZ])
        lf_pipe_y(seg);
}

// -----------------------------------------------------------------------------
// 总装
// -----------------------------------------------------------------------------

module table_left_frame() {
    frame_w = leftFrameWidth;
    frame_d = leftFrameDepth;

    lf_corner_post_left(180);
    translate([frame_w, 0, 0])
        lf_corner_post_right(-90, 0, 90);
    translate([0, frame_d, 0])
        rotate([0, 0, 180])
            lf_corner_post_left(-90);
    translate([frame_w, frame_d, 0])
        rotate([0, 0, 180])
            lf_corner_post_right(180, 0, 90);

    lf_rail_layer(lf_z_lo);
    // 顶圈右缘无 Y 口（平面四通横通沿 X，深向在 crossTieZ 垂挂层）
    lf_rail_layer(lf_z_top, skip_right_y = true);

    lf_right_edge_depth_tie();

    e = fittingHeadExtraMm;
    assert(lfStemNetMm > 0 && abs(lfStemNetMm - (lf_z_top - lf_z_lo - 2 * e)) < 0.01,
        "左缘立管搭接异常");
    assert(lfStemBelowTieNetMm > 0 && abs(lfStemBelowTieNetMm - (crossTieZ - lf_z_lo - 2 * e)) < 0.01,
        "右缘垂挂竖管搭接异常");
    assert(lfSpanXNetMm > 0 && abs(lfSpanXNetMm - (leftFrameWidth - 2 * e)) < 0.01,
        "左框X横拉搭接异常");
    assert(lfSpanYNetMm > 0 && abs(lfSpanYNetMm - (leftFrameDepth - 2 * e)) < 0.01,
        "左框Y纵拉搭接异常");
    assert(lfEdgeHalfNetMm > 0 && abs(lfEdgeHalfNetMm - (leftFrameDepth / 2 - 2 * e)) < 0.01,
        "右缘半跨搭接异常");

    echo(str(
        "[左框] 单层 宽=", leftFrameWidth,
        " 深=", leftFrameDepth,
        " z_lo=", lf_z_lo,
        " crossTieZ=", crossTieZ,
        " z_top=", lf_z_top,
        " 左立管=", lfStemNetMm, " 下料≈", lfStemCutMm,
        " 右垂挂竖=", lfStemBelowTieNetMm, " 下料≈", lfStemBelowTieCutMm,
        " X横=", lfSpanXNetMm,
        " Y纵=", lfSpanYNetMm,
        " 半跨=", lfEdgeHalfNetMm
    ));
}

module table_left_frame_in_place() {
    translate([leftFrameOriginX, leftFrameOriginY, 0])
        table_left_frame();
}
