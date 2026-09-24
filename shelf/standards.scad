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

// 前后边距：取最小开孔要求（左右用手填边距，已 assert）
shelfBoardDepthMarginMm = shelfBoardPostInsetMinMm;

// =============================================================================
// 前后框架：板深 → 柱心距 → 层深直管净长
// =============================================================================

shelfDepthCentersMm = shelfBoardDepthMm - 2 * shelfBoardDepthMarginMm;

assert(shelfDepthCentersMm > 2 * fittingHeadExtraMm,
    str("板深/边距过紧：柱心距 ", shelfDepthCentersMm,
        " 须 > 2×外缘搭接 ", 2 * fittingHeadExtraMm));

shelfDepthPipeNetMm = shelfDepthCentersMm - 2 * fittingHeadExtraMm;
shelfDepthPipeCutMm = cut_from_net_mm(shelfDepthPipeNetMm, "shelfDepth");

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
