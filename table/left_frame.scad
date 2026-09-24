// table/left_frame.scad — 左框架几何（电脑机箱侧）
//
// 依赖：table_config.scad + standards.scad（可与 right_frame 同 include）
// 坐标（局部）：原点 = 左前立柱；+X → 右前（对接右框）；+Y → 左后
//
// 单层：底圈前后横管 + crossTieZ 左右深向拉结（左缘整根 / 右缘半跨+中三通）+ 顶翻法兰。
// 四柱同高分段：下段 / 上段下料同长；顶无四通/对丝。

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

// 仅翻法兰（立管外丝直接拧入；承面 = frameHeight）
module lf_top_flange_only() {
    translate([0, 0, frameHeight])
        rotate([0, 180, 0])
            threaded_flange(flange_params);
}

// 垂挂直管：拉结三通上缘 → 顶翻法兰盘底（四柱同长 lfHangToFlangeNetMm）
module lf_hang_pipe() {
    translate([0, 0, hangPipeStartZ])
        lf_pipe_z(lfHangToFlangeNetMm);
}

// -----------------------------------------------------------------------------
// 立柱（左/右缘共用分段）：底三通 → 下段 → 拉结三通 → 垂挂上段 → 顶翻法兰
// 左右缘竖管同高分段，下料同长（lfStemBelowTieNetMm / lfHangToFlangeNetMm）
// bottom_tee_rot_z：支口默认 +Y；−90°→+X；+90°→−X
// hang_tee_rot_z：拉结层支口；0 → +Y（深向纵管）
// -----------------------------------------------------------------------------

module lf_corner_post(bottom_tee_rot_z, hang_tee_rot_z = 0) {
    stem_below_z = lf_z_lo + fittingHeadExtraMm;

    union() {
        threaded_flange(flange_params);

        translate([0, 0, flangeThicknessMm])
            lf_pipe_z(footPipeNetMm);

        translate([0, 0, lf_z_lo])
            rotate([0, 0, bottom_tee_rot_z])
                tee(pipe_params);

        translate([0, 0, stem_below_z])
            lf_pipe_z(lfStemBelowTieNetMm);

        translate([0, 0, crossTieZ])
            rotate([0, 0, hang_tee_rot_z])
                tee(pipe_params);

        lf_hang_pipe();

        lf_top_flange_only();
    }
}

module lf_corner_post_left(bottom_tee_rot_z, hang_tee_rot_z = 0) {
    lf_corner_post(bottom_tee_rot_z, hang_tee_rot_z);
}

module lf_corner_post_right(bottom_tee_rot_z, hang_tee_rot_z = 0) {
    lf_corner_post(bottom_tee_rot_z, hang_tee_rot_z);
}

// -----------------------------------------------------------------------------
// XY 横纵拉（两端：柱心 ± fittingHeadExtraMm）
// -----------------------------------------------------------------------------

module lf_rail_layer(z, skip_right_y = false, skip_left_y = false, skip_x = false) {
    frame_w = leftFrameWidth;
    frame_d = leftFrameDepth;
    hx = fittingHeadExtraMm;

    if (!skip_x) {
        translate([hx, 0, z])
            lf_pipe_x(lfSpanXNetMm);
        translate([hx, frame_d, z])
            lf_pipe_x(lfSpanXNetMm);
    }

    if (!skip_left_y)
        translate([0, hx, z])
            lf_pipe_y(lfSpanYNetMm);
    if (!skip_right_y)
        translate([frame_w, hx, z])
            lf_pipe_y(lfSpanYNetMm);
}

// -----------------------------------------------------------------------------
// 左缘深向：crossTieZ 整根纵管（与右缘同高；四柱竖管分段同长下料）
// -----------------------------------------------------------------------------

module lf_left_edge_depth_tie() {
    hx = fittingHeadExtraMm;
    translate([0, hx, crossTieZ])
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

    // 左前：底支口 +X、拉结支口 +Y；左后：整柱 180 后同理
    // 右前：底支口 −X、拉结支口 +Y；右后：整柱 180 后同理
    // tee 默认支口 +Y：−90°→+X；+90°→−X
    lf_corner_post_left(-90, 0);
    translate([frame_w, 0, 0])
        lf_corner_post_right(90, 0);
    translate([0, frame_d, 0])
        rotate([0, 0, 180])
            lf_corner_post_left(90, 0);
    translate([frame_w, frame_d, 0])
        rotate([0, 0, 180])
            lf_corner_post_right(-90, 0);

    // 底圈：仅前后横管
    lf_rail_layer(lf_z_lo, skip_left_y = true, skip_right_y = true);
    // 顶圈暂无横纵管
    lf_rail_layer(lf_z_top, skip_right_y = true, skip_left_y = true, skip_x = true);

    lf_left_edge_depth_tie();
    lf_right_edge_depth_tie();

    e = fittingHeadExtraMm;
    assert(lfStemBelowTieNetMm > 0 && abs(lfStemBelowTieNetMm - (crossTieZ - lf_z_lo - 2 * e)) < 0.01,
        "垂挂下段竖管搭接异常");
    assert(lfHangToFlangeNetMm > 0
        && abs(lfHangToFlangeNetMm - (frameHeight - flangeThicknessMm - hangPipeStartZ)) < 0.01,
        "垂挂上段→法兰搭接异常");
    assert(lfSpanXNetMm > 0 && abs(lfSpanXNetMm - (leftFrameWidth - 2 * e)) < 0.01,
        "左框X横拉搭接异常");
    assert(lfSpanYNetMm > 0 && abs(lfSpanYNetMm - (leftFrameDepth - 2 * e)) < 0.01,
        "左缘深向纵管搭接异常");
    assert(lfEdgeHalfNetMm > 0 && abs(lfEdgeHalfNetMm - (leftFrameDepth / 2 - 2 * e)) < 0.01,
        "右缘半跨搭接异常");

    echo(str(
        "[左框] 宽=", leftFrameWidth,
        " 深=", leftFrameDepth,
        " z_lo=", lf_z_lo,
        " crossTieZ=", crossTieZ,
        " 四柱下段=", lfStemBelowTieNetMm, " 下料≈", lfStemBelowTieCutMm,
        " 四柱上段→法兰=", lfHangToFlangeNetMm, " 下料≈", lfHangToFlangeCutMm,
        " 左缘纵=", lfSpanYNetMm,
        " 右缘半跨=", lfEdgeHalfNetMm,
        " 底X横=", lfSpanXNetMm
    ));
}

module table_left_frame_in_place() {
    translate([leftFrameOriginX, leftFrameOriginY, 0])
        table_left_frame();
}
