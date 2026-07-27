// =============================================================================
// 左右框架拉结 — 三根沿 +X 横管（前 / 中 / 后）
// =============================================================================
// 前：z_top 与中柱五通主通同高，中点三通 + 支口向上直通 + 顶翻法兰
// 中：deskCrossMidRowZMm（左框上半竖向中点），整根（纯拉结，无三通）
// 后：z_top 整管
// =============================================================================

function desk_cross_z_top() = table_upper_fourway_world_z();

function desk_cross_z_mid_row() = deskCrossMidRowZMm;

function desk_cross_z_tee() = desk_cross_z_top();

function desk_cross_y_mid() = legSpacingDepthY / 2;

function desk_cross_x0() = lfStorageLegSpacingX + fittingHeadExtraMm;

function desk_cross_explode_x() =
    (rightFrameDisplayMode == "exploded" || leftFrameDisplayMode == "exploded")
        ? -min(rightFrameExplodeMm, leftFrameExplodeMm) : 0;

// 主通沿 +X，支口朝 +Z
module desk_cross_tee_main_x() {
    rotate([180, 0, 0])
        rotate([0, 0, 90])
            rotate([0, 90, 0])
                rotate([90, 0, 0])
                    rotate([0, 0, 270])
                        tee(pipe_params);
}

// 支口向上：直通 + 法兰（法兰底对齐 desktopUndersideZ，与角柱顶托同高）
module desk_cross_branch_pipe_and_flange() {
    translate([0, 0, fittingHeadExtraMm])
        union() {
            pipe(pipe_params, deskCrossBranchStemLenMm);
            translate([0, 0, deskCrossBranchStemLenMm])
                rotate([0, 180, 0])
                    threaded_flange(flange_params);
        }
}

module desk_cross_tee_with_branch_flange() {
    union() {
        desk_cross_tee_main_x();
        desk_cross_branch_pipe_and_flange();
    }
}

// 前缘横管：中点三通 + 支口（仅前一根）
module desk_cross_front_pipe_split(y, z) {
    ex = desk_cross_explode_x();
    x0 = desk_cross_x0() + ex;
    half = deskCrossHalfPipeLenMm;
    x_tee = x0 + half;

    translate([x0, y, z])
        rotate([0, 90, 0])
            pipe(pipe_params, half);

    translate([x_tee, y, z])
        desk_cross_tee_with_branch_flange();

    translate([x_tee, y, z])
        rotate([0, 90, 0])
            pipe(pipe_params, half);
}

module desk_cross_pipe_whole(y, z) {
    off = desk_cross_explode_x();
    translate([desk_cross_x0() + off, y, z])
        rotate([0, 90, 0])
            pipe(pipe_params, deskCrossPipeLenMm);
}

module table_desk_cross_pipes() {
    desk_cross_front_pipe_split(0, desk_cross_z_tee());
    desk_cross_pipe_whole(desk_cross_y_mid(), desk_cross_z_mid_row());
    desk_cross_pipe_whole(legSpacingDepthY, desk_cross_z_top());
}
