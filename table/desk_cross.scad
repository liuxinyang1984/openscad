// table/desk_cross.scad — 左右框架对接横管
//
// 依赖：table_config.scad + standards.scad
// 三根沿 +X：前/后 @ z_top（顶平面四通；中点三通+支口翻法兰顶桌底）
//            中 @ crossTieZ（垂挂中位三通；整根）
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
module desk_cross_branch_flange() {
    translate([0, 0, fittingHeadExtraMm])
        union() {
            pipe(pipe_params, deskCrossBranchStemNetMm);
            translate([0, 0, deskCrossBranchStemNetMm])
                rotate([0, 180, 0])
                    threaded_flange(flange_params);
        }
}

module desk_cross_support_at(x, y, z) {
    translate([x, y, z])
        union() {
            desk_cross_support_tee();
            desk_cross_branch_flange();
        }
}

// 整根（垂挂层）
module desk_cross_span_whole(y, z) {
    translate([deskCrossPipeStartX, y, z])
        desk_cross_pipe_x(deskCrossNetMm);
}

// 前/后顶层：左半 + 中点支撑 + 右半（两端外缘）
module desk_cross_span_supported(y, z) {
    hx = fittingHeadExtraMm;
    half = deskCrossHalfNetMm;
    x_mid = deskCrossMidX;

    translate([deskCrossPipeStartX, y, z])
        desk_cross_pipe_x(half);

    desk_cross_support_at(x_mid, y, z);

    translate([x_mid + hx, y, z])
        desk_cross_pipe_x(half);
}

module table_desk_cross() {
    // 前 / 后：顶平面四通层 + 中点桌面支撑
    desk_cross_span_supported(deskCrossYFront, rf_z_top);
    desk_cross_span_supported(deskCrossYRear, rf_z_top);

    // 中：垂挂拉结层（整根）
    desk_cross_span_whole(deskCrossYMid, crossTieZ);

    e = fittingHeadExtraMm;
    assert(deskCrossNetMm > 0 && abs(deskCrossNetMm - (deskCrossCenterMm - 2 * e)) < 0.01,
        "对接横管搭接异常");
    assert(deskCrossHalfNetMm > 0 && abs(deskCrossHalfNetMm - (deskCrossCenterMm / 2 - 2 * e)) < 0.01,
        "对接半跨搭接异常");
    assert(deskCrossBranchStemNetMm > 0
        && abs(deskCrossBranchStemNetMm - (frameHeight - rf_z_top - e)) < 0.01,
        "桌面支撑支口搭接异常");
    assert(abs(deskCrossPipeStartX + deskCrossHalfNetMm - (deskCrossMidX - e)) < 0.01,
        "对接左半终点异常");
    assert(abs(deskCrossMidX + e + deskCrossHalfNetMm - (deskCrossRightX - e)) < 0.01,
        "对接右半终点异常");

    echo(str(
        "[对接] 柱心距=", deskCrossCenterMm,
        " 整净长=", deskCrossNetMm, " 半净长=", deskCrossHalfNetMm,
        " 支口=", deskCrossBranchStemNetMm, " 下料≈", deskCrossBranchStemCutMm,
        " midX=", deskCrossMidX,
        " y前/中/后=", deskCrossYFront, "/", deskCrossYMid, "/", deskCrossYRear,
        " z顶=", rf_z_top, " z垂挂=", crossTieZ
    ));
}
