// shelf/standards.scad — 书架派生尺寸（全部由手填 + 公共管件标准算出）
//
// 手填见 shelf_config.scad；公共套丝 / 管径见 common/standards.scad

include <../common/standards.scad>
include <shelf_config.scad>

// =============================================================================
// 层板穿孔与柱心内缩（孔边距板边 ≥ shelfBoardHoleEdgeClearMm）
// =============================================================================

shelfBoardHoleD = pipeOD + shelfBoardHoleExtraMm;

// 柱心距板边最小值 = 孔边距 + 孔半径
shelfBoardPostInsetMinMm = shelfBoardHoleEdgeClearMm + shelfBoardHoleD / 2;

assert(shelfBoardSideMarginMm >= shelfBoardPostInsetMinMm,
    str("shelfBoardSideMarginMm=", shelfBoardSideMarginMm,
        " 须 ≥ 孔边距+孔半径 ", shelfBoardPostInsetMinMm));

// 前后边距下限：取最小开孔要求（左右用手填边距，已 assert）
shelfBoardDepthMarginMinMm = shelfBoardPostInsetMinMm;

// =============================================================================
// 前后框架：板深 → 最大柱心距 → 层深管下料整厘米 → 反推净长/柱心/边距
// =============================================================================

shelfDepthCentersMaxMm =
    shelfBoardDepthMm - 2 * shelfBoardDepthMarginMinMm;

assert(shelfDepthCentersMaxMm > 2 * fittingHeadExtraMm,
    str("板深/边距过紧：柱心距上限 ", shelfDepthCentersMaxMm,
        " 须 > 2×外缘搭接 ", 2 * fittingHeadExtraMm));

shelfDepthPipeNetMaxMm =
    shelfDepthCentersMaxMm - 2 * fittingHeadExtraMm;

// 下料整厘米；若进位后净长超出板深允许，则降一档 10mm
shelfDepthPipeCutCandidateMm =
    cut_round_xx0(shelfDepthPipeNetMaxMm + 2 * threadEngageMm);
shelfDepthPipeCutMm =
    (net_from_cut_mm(shelfDepthPipeCutCandidateMm) <= shelfDepthPipeNetMaxMm)
        ? shelfDepthPipeCutCandidateMm
        : (shelfDepthPipeCutCandidateMm - 10);

assert(shelfDepthPipeCutMm >= 10 && shelfDepthPipeCutMm % 10 == 0,
    str("shelfDepthPipeCutMm=", shelfDepthPipeCutMm, " 须为整厘米"));

shelfDepthPipeNetMm = net_from_cut_mm(shelfDepthPipeCutMm);
shelfDepthCentersMm = fitting_center_to_center_mm(shelfDepthPipeNetMm);
shelfBoardDepthMarginMm = (shelfBoardDepthMm - shelfDepthCentersMm) / 2;

assert(shelfBoardDepthMarginMm + 1e-6 >= shelfBoardDepthMarginMinMm,
    str("层深取整后边距 ", shelfBoardDepthMarginMm,
        " < 孔边距下限 ", shelfBoardDepthMarginMinMm));

// 格内净深（柱间管内侧跨距，近似 = 层深管净长）
shelfClearDepthMm = shelfDepthPipeNetMm;

// =============================================================================
// 高度：板顶手填 → 板压管顶 → 管轴 → 立管净长
// =============================================================================

shelfLowerBoardTopZ    = shelfOriginZ;
shelfLowerBoardBottomZ = shelfLowerBoardTopZ - shelfThicknessMm;
// 板底压在横管/管件外径顶上
shelfLowerPipeCenterZ  = shelfLowerBoardBottomZ - pipeOD / 2;

shelfUpperBoardBottomZ = shelfLowerBoardTopZ + shelfClearHeightMm;
shelfUpperBoardTopZ    = shelfUpperBoardBottomZ + shelfThicknessMm;
shelfUpperPipeCenterZ  = shelfUpperBoardBottomZ - pipeOD / 2;

// 上下管轴心距 = 净高 + 板厚
shelfPipeCenterSpanZ = shelfUpperPipeCenterZ - shelfLowerPipeCenterZ;

shelfVerticalPipeNetMm = shelfPipeCenterSpanZ - 2 * fittingHeadExtraMm;
shelfVerticalPipeCutMm = cut_from_net_mm(shelfVerticalPipeNetMm, "shelfVert");

assert(shelfVerticalPipeNetMm > 0,
    str("立管净长须 > 0，当前=", shelfVerticalPipeNetMm));

// =============================================================================
// 侧框接头中心（局部坐标；原点 = 墙法兰承面中心，高度 = 下管轴）
// 局部 −Z = 世界 −Y；局部 −Y = 世界 +Z
// =============================================================================

shelfBackFittingLocalZ =
    -(flangeThicknessMm + couplingTotalMm + fittingHeadExtraMm);

shelfFrontFittingLocalZ =
    shelfBackFittingLocalZ - shelfDepthCentersMm;

shelfUpperFittingLocalY = -shelfPipeCenterSpanZ;

// =============================================================================
// 层板世界外包（+X：立柱留缝 → 板缘 → 柱心）
// =============================================================================

shelfLowerBoardRightX = shelfPillarLeftX - shelfBoardPillarGapMm;
shelfLowerBoardLeftX  = shelfLowerBoardRightX - shelfLowerBoardLenMm;

shelfUpperBoardRightX = shelfLowerBoardRightX;
shelfUpperBoardLeftX  = shelfUpperBoardRightX - shelfUpperBoardLenMm;

shelfLeftPostX  = shelfLowerBoardLeftX + shelfBoardSideMarginMm;
shelfRightPostX = shelfLowerBoardRightX - shelfBoardSideMarginMm;
shelfMidPostX   = shelfUpperBoardLeftX + shelfBoardSideMarginMm;

shelfLowerPostSpanMm = shelfRightPostX - shelfLeftPostX;
shelfUpperPostSpanMm = shelfRightPostX - shelfMidPostX;
shelfLeftToMidMm     = shelfMidPostX - shelfLeftPostX;
shelfMidToRightMm    = shelfRightPostX - shelfMidPostX;

shelfOriginX = shelfLeftPostX;

// 后柱世界 Y；板后缘
shelfBackPostY  = shelfOriginY + shelfBackFittingLocalZ;
shelfBoardBackY = shelfBackPostY + shelfBoardDepthMarginMm;

// 框架放置高度 = 下层层深管轴心
shelfFrameOriginZ = shelfLowerPipeCenterZ;

// =============================================================================
// 短立管下料
// =============================================================================

shelfStubPipeCutMm = cut_from_net_mm(shelfStubPipeNetMm, "shelfStub");

// =============================================================================
// 柱间横管净长（供以后拉结 / BOM）
// =============================================================================

shelfLeftToMidPipeNetMm  = pipe_net_between_tees_mm(shelfLeftToMidMm);
shelfMidToRightPipeNetMm = pipe_net_between_tees_mm(shelfMidToRightMm);
shelfLeftToMidPipeCutMm  = cut_from_net_mm(shelfLeftToMidPipeNetMm, "shelfL2M");
shelfMidToRightPipeCutMm = cut_from_net_mm(shelfMidToRightPipeNetMm, "shelfM2R");

lHorizNetMm = shelfLeftToMidMm;
lHorizCutMm = shelfLeftToMidPipeCutMm;

// =============================================================================
// 左墙书架派生（上下层同长；中柱居中分跨）
// =============================================================================

shelfLeftBoardLeftX  = shelfLeftWallEndX + shelfLeftBoardWallGapMm;
shelfLeftBoardRightX = shelfLeftBoardLeftX + shelfLeftBoardLenMm;

shelfLeftLeftPostX  = shelfLeftBoardLeftX + shelfBoardSideMarginMm;
shelfLeftRightPostX = shelfLeftBoardRightX - shelfBoardSideMarginMm;
shelfLeftMidPostX   = (shelfLeftLeftPostX + shelfLeftRightPostX) / 2;

shelfLeftPostSpanMm = shelfLeftRightPostX - shelfLeftLeftPostX;
shelfLeftBayPipeNetMm = pipe_net_between_tees_mm(shelfLeftPostSpanMm / 2);
shelfLeftBayPipeCutMm = cut_from_net_mm(shelfLeftBayPipeNetMm, "shelfLeftBay");

