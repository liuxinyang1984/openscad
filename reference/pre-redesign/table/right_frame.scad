// =============================================================================
// 右框架（储物框）— 全部几何汇总
// =============================================================================
// 依赖：由 table_module.scad 先行定义 pipe_params、flange_params 及尺寸标量后 include 本文件。
//
// 坐标约定（俯视）：
//   原点 = 左前立柱；+X = 右前；+Y = 左后（桌深方向）。
//   右框架左缘 x=0，右缘 x=storageLegSpacingX；前缘 y=0，后缘 y=legSpacingDepthY。
//
// 文件结构：
//   1) 上半 — 顶托（翻法兰 + 对丝 + 顶管件）+ 衔接短立管
//      左缘两柱（对接左框）：法兰下为五通，−X 支口朝左；其余角仍为顶四通。
//   2) 下半 — 四角落地立柱
//   3) 横管 — 沿 X / 沿 Y 拉结
//   4) 左缘 — 左前/左后垂挂三通 + 中位三通深向拉结
//   5) 总装 — table_right_frame_preview()
//   6) 显示 — exploded：管件不动，直管在水平面内沿「向外」法向平移（不改 Z）
// =============================================================================

// -----------------------------------------------------------------------------
// 0. 组合 / 分解 — 管件位置不变；直管仅在 XY 上外移（不沿管轴、不上下移）
// -----------------------------------------------------------------------------
// 前横管（沿 X）→ 仅 Y；右/左纵管（沿 Y）→ 仅 X；立柱/垂挂（沿 Z）→ X+Y 按角点外法向

function rf_is_exploded() = rightFrameDisplayMode == "exploded";

function rf_explode_mm() = rf_is_exploded() ? rightFrameExplodeMm : 0;

function rf_shift_xy(ex = 0, ey = 0) = [
    ex * rf_explode_mm(),
    ey * rf_explode_mm(),
    0
];

// 立柱 / 垂挂竖管：沿 Z，分解时在角点 XY 外移（ex、ey 为 ±1）
module rf_pipe_z(length, ex = 0, ey = 0) {
    translate(rf_shift_xy(ex, ey))
        pipe(pipe_params, length);
}

// 前/后横管：沿 +X，分解时仅沿 Y 外移（ey：前缘 −1，后缘 +1）
module rf_pipe_x(length, ey = 0) {
    translate(rf_shift_xy(0, ey))
        rotate([0, 90, 0])
            pipe(pipe_params, length);
}

// 左/右纵管：沿 +Y，分解时仅沿 X 外移（ex：左缘 −1，右缘 +1）
module rf_pipe_y(length, ex = 0) {
    translate(rf_shift_xy(ex, 0))
        rotate([-90, 0, 0])
            pipe(pipe_params, length);
}

// -----------------------------------------------------------------------------
// 1. 上半 — 标高函数
// -----------------------------------------------------------------------------

// legacy 顶四通参照 Z（未扣桌板厚）
function table_upper_fourway_legacy_z() = verticalPipeHeight + pipe;

// 顶四通中心世界 Z（随桌板厚下移 tabletopThickness）
function table_upper_fourway_world_z() = table_upper_fourway_legacy_z() - tabletopThickness;

// 须在 translate([0,0,-tabletopThickness]) 系内调用（与角柱顶托同局部标高）
module table_top_flange_coupling_above_fourway() {
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

// 上半竖向短管起点 Z（对齐下半「上四通」中心略上）
function table_upper_stem_start_z() = lowerFrameHeight + fittingHeadExtraMm;

// 上半衔接短立管：厘米级目标 rfPipeStemMm（整体总高 700 不变，与反算腿高顶差约数毫米）
function table_upper_stem_pipe_length() = rfPipeStemMm;

// -----------------------------------------------------------------------------
// 1. 上半 — 顶托堆叠（单角局部坐标，+Z 向上）
// -----------------------------------------------------------------------------

// 单角顶托：短立管 + 顶翻法兰 + 对丝 + 顶管件（ex/ey 为角点 XY 外移方向）
// top_fiveway_left：左缘柱五通，top_rot_z 与柱顶外层 rotate Z 配合，使 −X 支口朝左框
module table_top_set_stack(ex = 0, ey = 0, top_fiveway_left = false, top_rot_z = 180) {
    union() {
        // 衔接下半上四通与顶管件
        translate([0, 0, table_upper_stem_start_z()])
            rf_pipe_z(table_upper_stem_pipe_length(), ex, ey);

        translate([0, 0, -tabletopThickness])
            union() {
                translate([0, 0, previewTopFlangeCouplingLiftZ])
                    table_top_flange_coupling_above_fourway();

                translate([0, 0, verticalPipeHeight + pipe])
                    rotate([0, 0, top_rot_z])
                        if (top_fiveway_left)
                            fiveway3d(pipe_params);
                        else
                            fourway3d(pipe_params);
            }
    }
}

// 左前上半：五通 −X 接左框（top_rot_z 180，相对初值 +180°）
module table_left_front_upper() {
    table_top_set_stack(-1, -1, top_fiveway_left = true, top_rot_z = 180);
}

// 右前上半：绕 Z +90°；分解偏移须在 stack 局部 (−1,−1)，旋后世界 (+X,−Y)
module table_right_front_upper() {
    rotate([0, 0, 90])
        table_top_set_stack(-1, -1);
}

// 左后上半：Z270 + 五通 Z90（相对初值 Z−90 再 +180°）
module table_left_back_upper() {
    rotate([0, 0, 270])
        table_top_set_stack(-1, -1, top_fiveway_left = true, top_rot_z = 90);
}

// 右后上半：绕 Z 180°；局部 (−1,−1) → 世界 (+X,+Y)
module table_right_back_upper() {
    rotate([0, 0, 180])
        table_top_set_stack(-1, -1);
}

// -----------------------------------------------------------------------------
// 2. 下半 — 四角落地立柱（底法兰 → 短管 → 下四通 → 长管 → 上四通）
// -----------------------------------------------------------------------------

// 左前立柱：下/上四通均 rotate([0,0,180])
module table_left_front_lower() {
    union() {
        // 落地三孔内丝法兰
        threaded_flange(flange_params);
        // 脚高短立管
        translate([0, 0, flangeHeight])
            rf_pipe_z(storageFootHeight, -1, -1);
        // 下四通
        translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
            rotate([0, 0, 180])
                fourway3d(pipe_params);
        // 下半框中间长立管
        translate([0, 0, flangeHeight + storageFootHeight + pipe])
            rf_pipe_z(verticalPipeStorageMiddle, -1, -1);
        // 上四通
        translate([0, 0, flangeHeight + storageFootHeight + pipe + verticalPipeStorageMiddle + fittingHeadExtraMm])
            rotate([0, 0, 180])
                fourway3d(pipe_params);
    }
}

// 右前立柱：下/上四通均 rotate([0,0,-90])
module table_right_front_lower() {
    union() {
        threaded_flange(flange_params);
        translate([0, 0, flangeHeight])
            rf_pipe_z(storageFootHeight, 1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
            rotate([0, 0, -90])
                fourway3d(pipe_params);
        translate([0, 0, flangeHeight + storageFootHeight + pipe])
            rf_pipe_z(verticalPipeStorageMiddle, 1, -1);
        translate([0, 0, flangeHeight + storageFootHeight + pipe + verticalPipeStorageMiddle + fittingHeadExtraMm])
            rotate([0, 0, -90])
                fourway3d(pipe_params);
    }
}

// 左后立柱：与右前四通朝向相同，整柱绕 Z 180° 置于 (0, dy)
module table_left_back_lower() {
    rotate([0, 0, 180])
        union() {
            threaded_flange(flange_params);
            // 整柱 Z180° 后，局部 (1,-1) → 世界左后外法向 (−X,+Y)
            translate([0, 0, flangeHeight])
                rf_pipe_z(storageFootHeight, 1, -1);
            translate([0, 0, flangeHeight + storageFootHeight + fittingHeadExtraMm])
                rotate([0, 0, -90])
                    fourway3d(pipe_params);
            translate([0, 0, flangeHeight + storageFootHeight + pipe])
                rf_pipe_z(verticalPipeStorageMiddle, 1, -1);
            translate([0, 0, flangeHeight + storageFootHeight + pipe + verticalPipeStorageMiddle + fittingHeadExtraMm])
                rotate([0, 0, -90])
                    fourway3d(pipe_params);
        }
}

// 兼容旧名：单根左前下半
module table_right_frame_lower() {
    table_left_front_lower();
}

// -----------------------------------------------------------------------------
// 3. 横管 — 拉结四通侧口
// -----------------------------------------------------------------------------

// 沿桌长 +X 的直管（前后横拉）；ey：前缘 −1，后缘 +1
module table_storage_span_x(length, ey = 0) {
    rf_pipe_x(length, ey);
}

// 沿桌深 +Y 的直管（左右纵拉）；ex：左缘 −1，右缘 +1
module table_storage_span_y(length, ex = 0) {
    rf_pipe_y(length, ex);
}

// -----------------------------------------------------------------------------
// 4. 左缘垂挂 — 左前/左后三通 + 深向两段管 + 中位三通
// -----------------------------------------------------------------------------

// 垂挂顶面 Z（桌板底 / 结构顶）
function table_left_edge_drop_z_top() = desktopUndersideZ;

// 垂挂中段三通中心 Z
function table_left_edge_drop_z_tee_center() =
    table_left_edge_drop_z_top() - rightFrameLeftEdgeDropMm / 2;

// 垂挂底端 Z
function table_left_edge_drop_z_bottom() =
    table_left_edge_drop_z_top() - rightFrameLeftEdgeDropMm;

// 左缘垂挂下段、深向半跨：厘米级目标
function table_left_edge_drop_lower_pipe_len() = rfPipeEdgeLowerMm;

function table_left_edge_tie_half_len() = rfPipeEdgeHalfMm;

// 左缘单点垂挂：下段竖管 + 三通（tee_rot_z 绕 +Z，俯视顺时针为负角）
module table_right_frame_left_edge_drop(y_world, tee_rot_z) {
    z_tee = table_left_edge_drop_z_tee_center();

    translate([0, y_world, table_left_edge_drop_z_bottom()])
        rf_pipe_z(table_left_edge_drop_lower_pipe_len(), -1, y_world <= 0 ? -1 : 1);

    translate([0, y_world, z_tee])
        rotate([0, 0, tee_rot_z])
            tee(pipe_params);
}

// 左缘一组：左前/左后垂挂 + 深向两段管 + 中位三通
module table_right_frame_left_edge_drops_pair() {
    z_tee = table_left_edge_drop_z_tee_center();
    y_mid = legSpacingDepthY / 2;
    seg = table_left_edge_tie_half_len();

    // 左前垂挂三通：绕 Z 0°
    table_right_frame_left_edge_drop(0, 0);
    // 左后垂挂三通：绕 Z −180°
    table_right_frame_left_edge_drop(legSpacingDepthY, -180);

    // 左前 → 中位：深向半跨（左缘，沿 X 向外）
    translate([0, fittingHeadExtraMm, z_tee])
        table_storage_span_y(seg, -1);
    // 中位三通：绕 X 主通沿 +Y，再绕 Z 逆时针 90°
    translate([0, y_mid, z_tee])
        rotate([90, 0, 0])
            rotate([0, 0, 90])
                tee(pipe_params);
    // 中位 → 左后：深向半跨
    translate([0, y_mid + fittingHeadExtraMm, z_tee])
        table_storage_span_y(seg, -1);
}

// -----------------------------------------------------------------------------
// 5. Z 轴高度参考线（彩色分段，便于核对腿高与各层标高）
// -----------------------------------------------------------------------------

module rf_z_ref_bar(z0, z1, col) {
    if (z1 > z0)
        color(col)
            translate([0, 0, z0])
                cylinder(r = 1.2, h = z1 - z0, $fn = 16);
}

module rf_z_ref_tick(z, col, len = 28) {
    color(col)
        translate([0, 0, z])
            rotate([0, 90, 0])
                cylinder(r = 0.8, h = len, $fn = 12);
}

module table_right_frame_z_reference() {
    z_lo = flangeHeight + storageFootHeight + fittingHeadExtraMm;
    z_hi = lower_frame_upper_fourway_z(verticalPipeStorageMiddle, flangeHeight, storageFootHeight, pipe, fittingHeadExtraMm);
    z_stem = table_upper_stem_start_z();
    z_top = table_upper_fourway_world_z();
    z_tee = table_left_edge_drop_z_tee_center();
    z_foot_top = flangeHeight + storageFootHeight;
    z_mid_start = flangeHeight + storageFootHeight + pipe;

    translate([rightFrameZRefX, -12, 0])
        union() {
            // 竖向色段（自下而上）
            rf_z_ref_bar(0, flangeHeight, [0.45, 0.45, 0.45]);                      // 法兰厚度
            rf_z_ref_bar(flangeHeight, z_foot_top, [0.15, 0.55, 0.95]);            // 脚高 storageFootHeight
            rf_z_ref_bar(z_mid_start, z_hi, [0.15, 0.75, 0.25]);                    // 下半中立管 → 腿高顶 z_hi
            rf_z_ref_bar(z_hi, z_stem, [0.55, 0.85, 0.2]);                          // 上四通层间隙
            rf_z_ref_bar(z_stem, z_top, [0.95, 0.75, 0.1]);                         // 上半衔接短立管
            rf_z_ref_bar(z_top, desktopUndersideZ, [0.95, 0.45, 0.1]);              // 顶托（法兰+对丝+四通）
            rf_z_ref_bar(desktopUndersideZ, frameHeight, [0.9, 0.15, 0.15]);        // 桌板厚 tabletopThickness

            // 刻度线（同色）
            rf_z_ref_tick(0, [0.45, 0.45, 0.45]);
            rf_z_ref_tick(flangeHeight, [0.15, 0.55, 0.95]);
            rf_z_ref_tick(z_lo, [0.4, 0.4, 0.9]);
            rf_z_ref_tick(z_hi, [0.15, 0.75, 0.25]);
            rf_z_ref_tick(z_tee, [0.6, 0.3, 0.8]);
            rf_z_ref_tick(z_top, [0.95, 0.75, 0.1]);
            rf_z_ref_tick(desktopUndersideZ, [0.95, 0.45, 0.1]);
            rf_z_ref_tick(frameHeight, [0.9, 0.15, 0.15]);
        }

    echo(str("[Z参考] 灰=法兰  蓝=脚高(", storageFootHeight, "mm)  绿=腿高顶 z_hi=", z_hi,
        " (lowerFrameHeight=", lowerFrameHeight, ")  黄绿=上衔接  黄=顶四通  橙=顶托  红=桌板 ",
        tabletopThickness, "mm  总高 frameHeight=", frameHeight));
}

// -----------------------------------------------------------------------------
// 6. 总装 — 右框架完整预览
// -----------------------------------------------------------------------------

module table_right_frame_preview() {
    dy = legSpacingDepthY;
    z_lo = flangeHeight + storageFootHeight + fittingHeadExtraMm;
    z_hi = lower_frame_upper_fourway_z(verticalPipeStorageMiddle, flangeHeight, storageFootHeight, pipe, fittingHeadExtraMm);
    z_top = table_upper_fourway_world_z();
    span_x = storageHeight;

    union() {
        // --- 四角下半立柱 ---
        table_left_front_lower();
        translate([storageLegSpacingX, 0, 0])
            table_right_front_lower();
        translate([0, dy, 0])
            table_left_back_lower();
        translate([storageLegSpacingX, dy, 0])
            rotate([0, 0, 180])
                table_left_front_lower();

        // --- 前、后沿 X 横管（分解：前 −Y，后 +Y）---
        translate([fittingHeadExtraMm, 0, z_lo])
            table_storage_span_x(span_x, -1);
        translate([fittingHeadExtraMm, dy, z_lo])
            table_storage_span_x(span_x, 1);
        translate([fittingHeadExtraMm, 0, z_hi])
            table_storage_span_x(span_x, -1);
        translate([fittingHeadExtraMm, dy, z_hi])
            table_storage_span_x(span_x, 1);

        // --- 左、右沿 Y 纵管（分解：左 −X，右 +X）---
        translate([0, fittingHeadExtraMm, z_lo])
            table_storage_span_y(depthLength, -1);
        translate([storageLegSpacingX, fittingHeadExtraMm, z_lo])
            table_storage_span_y(depthLength, 1);
        translate([0, fittingHeadExtraMm, z_hi])
            table_storage_span_y(depthLength, -1);
        translate([storageLegSpacingX, fittingHeadExtraMm, z_hi])
            table_storage_span_y(depthLength, 1);

        // --- 四角上半顶托 ---
        table_left_front_upper();
        translate([storageLegSpacingX, 0, 0])
            table_right_front_upper();
        translate([0, dy, 0])
            table_left_back_upper();
        translate([storageLegSpacingX, dy, 0])
            table_right_back_upper();

        // --- 顶四通层横管 ---
        translate([fittingHeadExtraMm, 0, z_top])
            table_storage_span_x(span_x, -1);
        translate([fittingHeadExtraMm, dy, z_top])
            table_storage_span_x(span_x, 1);
        translate([0, fittingHeadExtraMm, z_top])
            table_storage_span_y(depthLength, -1);
        translate([storageLegSpacingX, fittingHeadExtraMm, z_top])
            table_storage_span_y(depthLength, 1);

        // --- 左缘垂挂与深向拉结 ---
        table_right_frame_left_edge_drops_pair();

        // --- Z 轴彩色高度参考（见 table_module.rightFrameShowZReference）---
        if (rightFrameShowZReference)
            table_right_frame_z_reference();
    }
}

// 兼容 main.scad / 旧脚本入口名
module table_right_frame_lower_four_preview() {
    table_right_frame_preview();
}
