// =============================================================================
// 左框架 — 独立几何（勿对 right_frame.scad 做 mirror / scale 翻转）
// =============================================================================
// 依赖：table_module.scad 已定义 pipe_params、flange_params、lf* / 共用标量后 include。
//
// 坐标约定（左框架自身局部系，俯视）：
//   原点 = 左前立柱；+X = 右前；+Y = 左后（桌深）。
//   左缘 x=0（外侧）；右缘 x=lfStorageLegSpacingX（与右框架对接的一侧）。
//
// 与右框架主要差异（结构意图）：
//   右框架：左缘 x=0 垂挂 + 三通，支口朝 −X，接左框架。
//   左框架：右缘 x=span 垂挂 + 三通，支口朝 +X，接右框架（非简单镜像体）。
//   下部框 z_hi 四横管高度：table_module 的 lfCutLowerShelfVertMm（非上半、非顶托）。
//   右侧两柱顶托（法兰下那一层）：五通 fiveway3d，+X 支口朝右接右框；下半仍为四通。
//
// 文件结构（与右框平行，命名前缀 lf_）：
//   0) 分解显示  1) 上半  2) 下半  3) 横管  4) 右缘对接  5) Z 参考  6) 总装
// =============================================================================

// -----------------------------------------------------------------------------
// 0. 组合 / 分解（规则同右框：管件不动，直管仅在 XY 外移）
// -----------------------------------------------------------------------------

function lf_is_exploded() = leftFrameDisplayMode == "exploded";

function lf_explode_mm() = lf_is_exploded() ? leftFrameExplodeMm : 0;

function lf_shift_xy(ex = 0, ey = 0) = [
    ex * lf_explode_mm(),
    ey * lf_explode_mm(),
    0
];

module lf_pipe_z(length, ex = 0, ey = 0) {
    translate(lf_shift_xy(ex, ey))
        pipe(pipe_params, length);
}

module lf_pipe_x(length, ey = 0) {
    translate(lf_shift_xy(0, ey))
        rotate([0, 90, 0])
            pipe(pipe_params, length);
}

module lf_pipe_y(length, ex = 0) {
    translate(lf_shift_xy(ex, 0))
        rotate([-90, 0, 0])
            pipe(pipe_params, length);
}

// -----------------------------------------------------------------------------
// 1. 上半 — 标高（与右框共用 desktopUndersideZ / frameHeight 体系）
// -----------------------------------------------------------------------------

function lf_upper_stem_start_z() = lfLowerFrameHeight + fittingHeadExtraMm;

function lf_upper_stem_pipe_length() = lfPipeStemMm;

// 单角顶托：法兰 + 对丝 + 顶管件 + 衔接短管
// top_fiveway_right：右柱专用五通（top_rot_z 与柱顶外层 rotate Z 配合，使 +X 支口朝世界 +X）
module lf_top_set_stack(ex = 0, ey = 0, top_fiveway_right = false, top_rot_z = 180) {
    union() {
        translate([0, 0, lf_upper_stem_start_z()])
            lf_pipe_z(lf_upper_stem_pipe_length(), ex, ey);

        translate([0, 0, -tabletopThickness])
            union() {
                translate([0, 0, previewTopFlangeCouplingLiftZ])
                    union() {
                        translate([0, 0, frameHeight])
                            rotate([0, 180, 0])
                                threaded_flange(flange_params);
                        pl_cz = frameHeight - flangeHeight - couplingTotalMm / 2;
                        difference() {
                            translate([0, 0, pl_cz])
                                pipe_link(pipe_params, couplingTotalMm, couplingHexMm);
                            translate([0, 0, frameHeight])
                                cylinder(r = 50, h = 20);
                        }
                    }
                translate([0, 0, verticalPipeHeight + pipe])
                    rotate([0, 0, top_rot_z])
                        if (top_fiveway_right)
                            fiveway3d(pipe_params);
                        else
                            fourway3d(pipe_params);
            }
    }
}

// TODO: 按左框各角核实绕 Z（初值与右框同型，勿假设镜像自动正确）
module lf_corner_front_left_upper() {
    lf_top_set_stack(-1, -1);
}

// 右前顶：外层 Z90 + 五通 Z90（相对初值 +180°）
module lf_corner_front_right_upper() {
    rotate([0, 0, 90])
        lf_top_set_stack(-1, -1, top_fiveway_right = true, top_rot_z = 90);
}

module lf_corner_back_left_upper() {
    rotate([0, 0, 270])
        lf_top_set_stack(-1, -1);
}

// 右后顶：外层 Z180 + 五通 Z−180（再顺时针 90°，累计俯视顺时针 180°）
module lf_corner_back_right_upper() {
    rotate([0, 0, 180])
        lf_top_set_stack(-1, -1, top_fiveway_right = true, top_rot_z = -180);
}

// -----------------------------------------------------------------------------
// 2. 下半 — 四角立柱
// -----------------------------------------------------------------------------

module lf_corner_front_left_lower() {
    union() {
        threaded_flange(flange_params);
        translate([0, 0, flangeHeight])
            lf_pipe_z(storageFootHeight, -1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
            rotate([0, 0, 180])
                fourway3d(pipe_params);
        translate([0, 0, flangeHeight + storageFootHeight + pipe])
            lf_pipe_z(lfVerticalPipeStorageMiddle, -1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + pipe + lfVerticalPipeStorageMiddle + fittingHeadExtraMm])
            rotate([0, 0, 180])
                fourway3d(pipe_params);
    }
}

module lf_corner_front_right_lower() {
    union() {
        threaded_flange(flange_params);
        translate([0, 0, flangeHeight])
            lf_pipe_z(storageFootHeight, 1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
            rotate([0, 0, -90])
                fourway3d(pipe_params);
        translate([0, 0, flangeHeight + storageFootHeight + pipe])
            lf_pipe_z(lfVerticalPipeStorageMiddle, 1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + pipe + lfVerticalPipeStorageMiddle + fittingHeadExtraMm])
            rotate([0, 0, -90])
                fourway3d(pipe_params);
    }
}

module lf_corner_back_left_lower() {
    rotate([0, 0, 180])
        union() {
            threaded_flange(flange_params);
            translate([0, 0, flangeHeight])
                lf_pipe_z(storageFootHeight, 1, -1);
            translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
                rotate([0, 0, -90])
                    fourway3d(pipe_params);
            translate([0, 0, flangeHeight + storageFootHeight + pipe])
                lf_pipe_z(lfVerticalPipeStorageMiddle, 1, -1);
            translate([0, 0, flangeHeight + storageFootHeight + pipe + lfVerticalPipeStorageMiddle + fittingHeadExtraMm])
                rotate([0, 0, -90])
                    fourway3d(pipe_params);
        }
}

module lf_span_x(length, ey = 0) {
    lf_pipe_x(length, ey);
}

module lf_span_y(length, ex = 0) {
    lf_pipe_y(length, ex);
}

// -----------------------------------------------------------------------------
// 4. 右缘对接 — 垂挂 + 三通 + 深向拉结（对接右框架左缘，支口朝 +X）
// -----------------------------------------------------------------------------

function lf_right_edge_drop_z_top() = desktopUndersideZ;

function lf_right_edge_drop_z_tee_center() =
    lf_right_edge_drop_z_top() - lfPipeEdgeDropMm / 2;

function lf_right_edge_drop_z_bottom() =
    lf_right_edge_drop_z_top() - lfPipeEdgeDropMm;

module lf_right_edge_drop(y_world, tee_rot_z) {
    z_tee = lf_right_edge_drop_z_tee_center();
    x_edge = lfStorageLegSpacingX;

    translate([x_edge, y_world, lf_right_edge_drop_z_bottom()])
        lf_pipe_z(lfPipeEdgeLowerMm, 1, y_world <= 0 ? -1 : 1);

    translate([x_edge, y_world, z_tee])
        rotate([0, 0, tee_rot_z])
            tee(pipe_params);
}

// 右前 / 右后垂挂；中位三通（朝向待与右框左缘中位核对）
module lf_right_edge_drops_pair() {
    z_tee = lf_right_edge_drop_z_tee_center();
    y_mid = lfLegSpacingDepthY / 2;
    seg = lfPipeEdgeHalfMm;
    x_edge = lfStorageLegSpacingX;

    // 右前 / 右后垂挂：绕 Z +180°（相对初值）
    lf_right_edge_drop(0, 0);
    lf_right_edge_drop(lfLegSpacingDepthY, 180);

    translate([x_edge, fittingHeadExtraMm, z_tee])
        lf_span_y(seg, 1);
    translate([x_edge, y_mid, z_tee])
        rotate([90, 0, 0])
            rotate([0, 0, 270])
                tee(pipe_params);
    translate([x_edge, y_mid + fittingHeadExtraMm, z_tee])
        lf_span_y(seg, 1);
}

// -----------------------------------------------------------------------------
// 5. Z 轴参考线（可选）
// -----------------------------------------------------------------------------

module lf_z_reference() {
    z_lo = flangeHeight + storageFootHeight + fittingHeadExtraMm;
    z_hi = lower_frame_upper_fourway_z(lfVerticalPipeStorageMiddle, flangeHeight, storageFootHeight, pipe, fittingHeadExtraMm);
    z_stem = lf_upper_stem_start_z();
    z_top = table_upper_fourway_world_z();

    translate([-45, -12, 0])
        union() {
            color([0.45, 0.45, 0.45])
                translate([0, 0, 0])
                    cylinder(r = 1.2, h = flangeHeight, $fn = 16);
            color([0.15, 0.55, 0.95])
                translate([0, 0, flangeHeight])
                    cylinder(r = 1.2, h = storageFootHeight, $fn = 16);
            color([0.15, 0.75, 0.25])
                translate([0, 0, flangeHeight + storageFootHeight + pipe])
                    cylinder(r = 1.2, h = lfVerticalPipeStorageMiddle, $fn = 16);
        }

    echo(str("[左框 Z参考] 腿高顶 z_hi=", z_hi, " lowerFrameHeight=", lfLowerFrameHeight,
        " frameHeight=", frameHeight));
}

// -----------------------------------------------------------------------------
// 6. 总装
// -----------------------------------------------------------------------------

module table_left_frame_preview() {
    dy = lfLegSpacingDepthY;
    sx = lfStorageLegSpacingX;
    z_lo = flangeHeight + storageFootHeight + fittingHeadExtraMm;
    z_hi = lower_frame_upper_fourway_z(lfVerticalPipeStorageMiddle, flangeHeight, storageFootHeight, pipe, fittingHeadExtraMm);
    z_top = table_upper_fourway_world_z();
    span_x = lfStorageHeight;

    translate([leftFrameOriginX, 0, 0])
        union() {
            // --- 四角下半 ---
            lf_corner_front_left_lower();
            translate([sx, 0, 0])
                lf_corner_front_right_lower();
            translate([0, dy, 0])
                lf_corner_back_left_lower();
            translate([sx, dy, 0])
                rotate([0, 0, 180])
                    lf_corner_front_left_lower();

            // --- 下部框横管：z_lo 底圈四根；z_hi 上圈四根（抬高此项改 lfCutLowerShelfVertMm）
            translate([fittingHeadExtraMm, 0, z_lo])
                lf_span_x(span_x, -1);
            translate([fittingHeadExtraMm, dy, z_lo])
                lf_span_x(span_x, 1);
            translate([fittingHeadExtraMm, 0, z_hi])
                lf_span_x(span_x, -1);
            translate([fittingHeadExtraMm, dy, z_hi])
                lf_span_x(span_x, 1);

            translate([0, fittingHeadExtraMm, z_lo])
                lf_span_y(lfDepthLength, -1);
            translate([sx, fittingHeadExtraMm, z_lo])
                lf_span_y(lfDepthLength, 1);
            translate([0, fittingHeadExtraMm, z_hi])
                lf_span_y(lfDepthLength, -1);
            translate([sx, fittingHeadExtraMm, z_hi])
                lf_span_y(lfDepthLength, 1);

            // --- 四角上半 ---
            lf_corner_front_left_upper();
            translate([sx, 0, 0])
                lf_corner_front_right_upper();
            translate([0, dy, 0])
                lf_corner_back_left_upper();
            translate([sx, dy, 0])
                lf_corner_back_right_upper();

            // --- 顶四通层横管 ---
            translate([fittingHeadExtraMm, 0, z_top])
                lf_span_x(span_x, -1);
            translate([fittingHeadExtraMm, dy, z_top])
                lf_span_x(span_x, 1);
            translate([0, fittingHeadExtraMm, z_top])
                lf_span_y(lfDepthLength, -1);
            translate([sx, fittingHeadExtraMm, z_top])
                lf_span_y(lfDepthLength, 1);

            // --- 右缘对接右框架（非镜像，独立定位在 x=sx）---
            lf_right_edge_drops_pair();

            if (leftFrameShowZReference)
                lf_z_reference();
        }
}

// 左右框架 + 三根拉结横管（右框在 rightFrameOriginX）
module table_frames_both_preview() {
    table_left_frame_preview();
    translate([rightFrameOriginX, 0, 0])
        table_right_frame_preview();
    table_desk_cross_pipes();
}
