// table/desk_cross.scad — 左右框架对接横管
//
// 依赖：table_config.scad + standards.scad
// 中 @ crossTieZ：左半 + 中点三通（上托桌底法兰）+ 右半
// 前/后 @ z_top：暂去掉（模块保留）
// 直管两端停在管件搭接外缘（fittingHeadExtraMm），不到柱心

module desk_cross_pipe_x(length) {
    rotate([0, 90, 0])
        pipe(pipe_params, length);
}

// 主通 ±X，支口 +Z
module desk_cross_support_tee() {
    rotate([0, 0, -90])
        rotate([90, 0, 0])
            tee(pipe_params);
}

// 支口向上：外缘起短管 + 翻法兰（承面 = frameHeight）
module desk_cross_branch_flange(stem_net) {
    translate([0, 0, fittingHeadExtraMm])
        union() {
            pipe(pipe_params, stem_net);
            translate([0, 0, stem_net])
                rotate([0, 180, 0])
                    threaded_flange(flange_params);
        }
}

module desk_cross_support_at(x, y, z, stem_net) {
    translate([x, y, z])
        union() {
            desk_cross_support_tee();
            desk_cross_branch_flange(stem_net);
        }
}

// 整根（无中托）
module desk_cross_span_whole(y, z) {
    translate([deskCrossPipeStartX, y, z])
        desk_cross_pipe_x(deskCrossNetMm);
}

// 左半 + 中点支撑 + 右半
module desk_cross_span_supported(y, z, stem_net) {
    hx = fittingHeadExtraMm;
    half = deskCrossHalfNetMm;
    x_mid = deskCrossMidX;

    translate([deskCrossPipeStartX, y, z])
        desk_cross_pipe_x(half);

    desk_cross_support_at(x_mid, y, z, stem_net);

    translate([x_mid + hx, y, z])
        desk_cross_pipe_x(half);
}

module table_desk_cross() {
    // 前/后顶层暂去掉
    // desk_cross_span_supported(deskCrossYFront, rf_z_top, deskCrossBranchStemNetMm);
    // desk_cross_span_supported(deskCrossYRear, rf_z_top, deskCrossBranchStemNetMm);

    // 中：垂挂拉结 + 中点上托桌底
    desk_cross_span_supported(
        deskCrossYMid,
        crossTieZ,
        deskCrossMidBranchStemNetMm
    );

    e = fittingHeadExtraMm;
    assert(deskCrossNetMm > 0 && abs(deskCrossNetMm - (deskCrossCenterMm - 2 * e)) < 0.01,
        "对接横管搭接异常");
    assert(deskCrossHalfNetMm > 0 && abs(deskCrossHalfNetMm - (deskCrossCenterMm / 2 - 2 * e)) < 0.01,
        "对接半跨搭接异常");
    assert(deskCrossMidBranchStemNetMm > 0
        && abs(deskCrossMidBranchStemNetMm - (frameHeight - crossTieZ - e)) < 0.01,
        "中托支口搭接异常");
    assert(abs(deskCrossPipeStartX + deskCrossHalfNetMm - (deskCrossMidX - e)) < 0.01,
        "对接左半终点异常");
    assert(abs(deskCrossMidX + e + deskCrossHalfNetMm - (deskCrossRightX - e)) < 0.01,
        "对接右半终点异常");

    echo(str(
        "[对接] 柱心距=", deskCrossCenterMm,
        " 半净长=", deskCrossHalfNetMm, " 下料≈", deskCrossHalfCutMm,
        " 中托支口=", deskCrossMidBranchStemNetMm, " 下料≈", deskCrossMidBranchStemCutMm,
        " midX=", deskCrossMidX,
        " y中=", deskCrossYMid,
        " z=", crossTieZ
    ));
}
