// table_module.scad — 备份快照（仅 reference/pre-redesign 内使用，勿复制到根目录 table/）
//
// include 路径均相对本目录；lib/ 仍用项目根目录。

include <../../config.scad>
include <../../utils.scad>

standard = "DN15";
flange_params = get_threaded_flange_params(standard);
pipe_params = get_pipe_params(standard);

pipe = pipe_params[1];
halfPipe = pipe_params[1] / 2;

// DN15 对丝：实物总长约 40 mm、六角段约 8 mm；安装余量建模六角按 10 mm
couplingTotalMm = 40;
couplingHexMm = 10;
flangeHeight = flange_params[4];
threadLenght = pipe_params[3] / 2;
pipeLinkHeight = pipe_params[4] / 2;

// 桌面总高 700 mm；左右宽 = 左右框架拉结中心距；桌深 table_depth 独立
table_width = 2000;
table_depth = 700;
table_length = 2000;
table_height = 700;
frameInset = 15;
frameWidth = table_width - frameInset * 2;
frameHeight = table_height;
frameLength = table_length - frameInset * 2;

// 桌板厚（mm）；顶内丝法兰承在「桌面底」= 立面顶 frameHeight 减去板厚（暂按 2.5 cm）
tabletopThickness = 25;
desktopUndersideZ = frameHeight - tabletopThickness;

// 调试：顶法兰 + 对丝整体沿 +Z 抬高 (mm)，便于单独看件；正常装配请设 0
previewTopFlangeCouplingLiftZ = 0;

// 顶托法兰占水平空间：法兰外径（圆盘最大处），来自 threaded_flange 参数表第 2 列
flangeOD = flange_params[1];
// --- 右框架直管：下料一律 xx0 mm（厘米整）；模型净直段 = 下料 − 2×pipeThreadMm ---
pipeThreadMm = pipe_params[3];

// 商家实测 DN15 平面三通/四通/五通主通（对向两端口）：总长 52，中心→单头 26，拧入约 10 → 净直段外每端占 16
fittingMainRunMm = 52;
fittingHalfHeadMm = 26;
fittingThreadEngageMm = 10;
fittingHeadExtraMm = fittingHalfHeadMm - fittingThreadEngageMm;

// 直管净长 L：中心→外端 = fittingHeadExtraMm + L
// 半跨（中点分断 / 端部到跨中）：L = 半中心距 − fittingHeadExtraMm
function pipe_span_half_net_mm(center_half_mm) = center_half_mm - fittingHeadExtraMm;
// 相邻两管件中心之间一段直管：L = 中心距 − 2×fittingHeadExtraMm
function pipe_net_between_tees_mm(center_mm) = center_mm - 2 * fittingHeadExtraMm;
function fitting_center_to_center_mm(pipe_net_mm) = pipe_net_mm + 2 * fittingHeadExtraMm;

// 下料取整到整厘米（个位 0，即 xxx0 mm）
function cut_round_xx0(mm) = ceil(mm / 10) * 10;

function cut_must_xx0(cut_mm, name = "cut") =
    assert(cut_mm % 10 == 0, str(name, " 下料须为整厘米 xx0 mm"))
    cut_mm;

function cut_from_net_mm(net_mm, name = "cut") =
    cut_must_xx0(cut_round_xx0(net_mm + 2 * pipeThreadMm), name);

function rf_net_from_cut(cut_mm) = cut_mm - 2 * pipeThreadMm;

rfCutFootMm = 80;
rfCutMidMm = 220;
rfCutStemMm = 380;
rfCutSpanXmm = 280;
rfCutSpanYmm = 590;
rfCutEdgeLowerMm = 120;

rfPipeFootMm = rf_net_from_cut(rfCutFootMm);
rfPipeMidMm = rf_net_from_cut(rfCutMidMm);
rfPipeStemMm = rf_net_from_cut(rfCutStemMm);
rfPipeSpanXmm = rf_net_from_cut(rfCutSpanXmm);
rfPipeSpanYmm = rf_net_from_cut(rfCutSpanYmm);
rfPipeEdgeLowerMm = rf_net_from_cut(rfCutEdgeLowerMm);

rfPipeEdgeDropMm = 200;

function table_leg_spacing_depth_y(table_depth_mm, edge_mm_each, flange_outer_d) =
    table_depth_mm - 2 * edge_mm_each - flange_outer_d;

legSpacingDepthY = fitting_center_to_center_mm(rfPipeSpanYmm);
depthEdgeMargin = (table_depth - flangeOD - legSpacingDepthY) / 2;
depthLength = rfPipeSpanYmm;

rfPipeEdgeHalfNetMm = pipe_net_between_tees_mm(legSpacingDepthY / 2);
rfCutEdgeHalfMm = cut_from_net_mm(rfPipeEdgeHalfNetMm, "rfCutEdgeHalfMm");
rfPipeEdgeHalfMm = rf_net_from_cut(rfCutEdgeHalfMm);

topSetHeight = flangeHeight * 2 + threadLenght + fittingHeadExtraMm + pipe;
verticalPipeHeight = frameHeight - topSetHeight;
verticalPipeTop = 120;
verticalPipeLeftBottom = verticalPipeHeight - verticalPipeTop - pipe;

storageFootHeight = rfPipeFootMm;
verticalPipeStorage = verticalPipeHeight - storageFootHeight - pipe * 2;

function lower_frame_upper_fourway_z(mid_pipe_len, fh, foot_h, p, conn = fittingHeadExtraMm) =
    fh + foot_h + p + mid_pipe_len + conn;

// 上半衔接短立管净长：顶四通 legacy 标高 − 下半上四通中心下缘（桌面总高不变时用）
function upper_stem_net_mm(lower_frame_h, p = pipe, conn = fittingHeadExtraMm) =
    verticalPipeHeight + p - (lower_frame_h + conn) - p;

function lf_net_from_cut(cut_mm) = rf_net_from_cut(cut_mm);

lowerFrameHeight = flangeHeight + storageFootHeight + pipe + rfPipeMidMm + fittingHeadExtraMm;
verticalPipeStorageMiddle = rfPipeMidMm;

upperFrameResidualZ = frameHeight - lowerFrameHeight;

storageHeight = rfPipeSpanXmm;
storageLegSpacingX = fitting_center_to_center_mm(rfPipeSpanXmm);

rightFrameLeftEdgeDropMm = rfPipeEdgeDropMm;
leftFrameTieStubMm = 80;

// 右框架显示模式："assembled" 组合 | "exploded" 分解（管件不动，直管仅在 XY 外移 rightFrameExplodeMm）
rightFrameDisplayMode = "assembled";
rightFrameExplodeMm = 50;

// Z 轴彩色高度参考线（框架左侧）；false 可关闭
rightFrameShowZReference = true;
rightFrameZRefX = -45;

include <table/right_frame.scad>

// --- 左框架直管：下料一律 xx0 mm；模型净直段 = 下料 − 2×pipeThreadMm ---
lfCutFootMm = cut_must_xx0(80, "lfCutFootMm");
// 下部框 z_hi 四横管：四角下四通↔上四通立管（放机箱，与右框 R-11 分工不同）
lfCutLowerShelfVertMm = cut_must_xx0(400, "lfCutLowerShelfVertMm");
lfCutMidMm = lfCutLowerShelfVertMm;
lfCutSpanXmm = cut_must_xx0(280, "lfCutSpanXmm");
lfCutSpanYmm = cut_must_xx0(590, "lfCutSpanYmm");
lfCutEdgeLowerMm = cut_must_xx0(120, "lfCutEdgeLowerMm");

lfPipeFootMm = lf_net_from_cut(lfCutFootMm);
lfPipeMidMm = lf_net_from_cut(lfCutLowerShelfVertMm);
lfPipeSpanXmm = lf_net_from_cut(lfCutSpanXmm);
lfPipeSpanYmm = lf_net_from_cut(lfCutSpanYmm);
lfPipeEdgeLowerMm = lf_net_from_cut(lfCutEdgeLowerMm);

lfPipeEdgeDropMm = rfPipeEdgeDropMm;

lfLegSpacingDepthY = fitting_center_to_center_mm(lfPipeSpanYmm);
lfDepthLength = lfPipeSpanYmm;
lfStorageHeight = lfPipeSpanXmm;
lfStorageLegSpacingX = fitting_center_to_center_mm(lfStorageHeight);

lfPipeEdgeHalfNetMm = pipe_net_between_tees_mm(lfLegSpacingDepthY / 2);
lfCutEdgeHalfMm = cut_from_net_mm(lfPipeEdgeHalfNetMm, "lfCutEdgeHalfMm");
lfPipeEdgeHalfMm = lf_net_from_cut(lfCutEdgeHalfMm);

// --- 左右拉结：三根沿 +X 横管（前 / 中 / 后）---
rightFrameOriginX = table_width - storageLegSpacingX;
deskCrossPipeNetMm = rightFrameOriginX - lfStorageLegSpacingX - 2 * fittingHeadExtraMm;
deskCrossWholePipeNetMm = deskCrossPipeNetMm - 2 * fittingHeadExtraMm;
deskCrossCutMm = cut_from_net_mm(deskCrossWholePipeNetMm, "deskCrossCutMm");
deskCrossPipeLenMm = rf_net_from_cut(deskCrossCutMm);
// 前缘拉结半管；中位整根；后缘整根 @ z_top
deskCrossHalfLenMm = pipe_span_half_net_mm(deskCrossPipeNetMm / 2);
deskCrossHalfCutMm = cut_from_net_mm(deskCrossHalfLenMm, "deskCrossHalfCutMm");
deskCrossHalfPipeLenMm = lf_net_from_cut(deskCrossHalfCutMm);

// 中位拉结整根 @ 左框上半竖向中点；前缘三通 @ z_top（与柱顶五通/四通主通同高）
function lf_upper_section_z_hi(mid_len = lfPipeMidMm) =
    lower_frame_upper_fourway_z(mid_len, flangeHeight, storageFootHeight, pipe);

function lf_upper_section_z_mid(mid_len = lfPipeMidMm) =
    (lf_upper_section_z_hi(mid_len) + table_upper_fourway_world_z()) / 2;

deskCrossMidRowZMm = lf_upper_section_z_mid();
deskCrossTeeZMm = table_upper_fourway_world_z();
deskCrossBranchStemNetMm = max(
    fittingHeadExtraMm,
    desktopUndersideZ - deskCrossTeeZMm - fittingHeadExtraMm - flangeHeight);
deskCrossBranchStemCutMm = cut_from_net_mm(deskCrossBranchStemNetMm, "deskCrossBranchStemCutMm");
deskCrossBranchStemLenMm = lf_net_from_cut(deskCrossBranchStemCutMm);

lfLowerFrameHeight = flangeHeight + storageFootHeight + pipe + lfPipeMidMm + fittingHeadExtraMm;
lfVerticalPipeStorageMiddle = lfPipeMidMm;
lfCutStemMm = cut_from_net_mm(
    max(80, upper_stem_net_mm(lfLowerFrameHeight)),
    "lfCutStemMm");
lfPipeStemMm = lf_net_from_cut(lfCutStemMm);

leftFrameDisplayMode = "assembled";
leftFrameExplodeMm = 50;
leftFrameShowZReference = false;
// 左框装配原点（世界 X=0）；合模预览不再侧移
leftFrameOriginX = 0;

include <table/left_frame.scad>
include <table/desk_cross.scad>

// 三孔内丝镀锌法兰（与 table_module_legacy 中用法一致；几何来自 lib/flange3.scad）
module table_flange() {
    threaded_flange(flange_params);
}

// 对丝（镀锌外丝接头）：法兰、四通等无法直接对接，中间须短管或本件转接；几何见 lib/pipe_link.scad
module table_threaded_coupling() {
    pipe_link(pipe_params, couplingTotalMm, couplingHexMm);
}
