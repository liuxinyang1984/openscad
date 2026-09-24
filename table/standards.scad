// table/standards.scad — 桌项目派生尺寸（管件标准 / 套丝 / 下料函数见 common/standards）
//
// 依赖：须先 include <table_config.scad>（桌手填主参数）
// 本文件只放桌专属派生：legHeight、各框标高、对接横管等

include <../common/standards.scad>

// 桌板边到柱心预留 须 ≥ 法兰半径，否则法兰探出桌板
assert(frameInset >= flangeOD / 2,
    str("frameInset=", frameInset, " 须 ≥ 法兰半径 ", flangeOD / 2));

// =============================================================================
// 桌脚堆叠（落地法兰 + 脚短管 + 下四通）
// =============================================================================

// 脚短管净长：下料 footPipeCutMm − 两端成品螺纹段
footPipeNetMm = net_from_cut_mm(cut_must_xx0(footPipeCutMm, "footPipeCutMm"));

// 脚堆叠顶高 = 法兰厚 + 脚管净长 + 外缘搭接 + 半头
function foot_stack_top_z(
    flange_t = flangeThicknessMm,
    foot_net = footPipeNetMm,
    conn = fittingHeadExtraMm,
    half_head = fittingHalfHeadMm
) = flange_t + foot_net + conn + half_head;

// 腿高（地面 → 下四通上缘半头外端）
legHeight = foot_stack_top_z();

// =============================================================================
// 右框架派生（手填见 table_config；此处只计算）
// =============================================================================

// 前后柱心距（沿 +Y）= 整桌框架深向可用宽
rightFrameDepth = frameWidth;

// 下四通中心 Z：法兰盘顶 + 脚管净长 + 外缘搭接
rf_z_lo = flangeThicknessMm + footPipeNetMm + fittingHeadExtraMm;

// 下框上四通中心 Z（设计手填）
rf_z_hi = rightBottomFrameHeight;

// 下半中立管净长：下四通中心 ↔ 上四通中心，两端均停在管件搭接外缘
rfMidPipeNetMm = rf_z_hi - rf_z_lo - 2 * fittingHeadExtraMm;

// X / Y 横拉净长（柱心距 − 两端外缘搭接）
rfSpanXNetMm = pipe_net_between_tees_mm(rightFrameWidth);
rfSpanYNetMm = pipe_net_between_tees_mm(rightFrameDepth);

// 梯形右移后各段 X 净长（外缘约定）
// 前缘：左柱↔三通（长 rightFrameWidth−shift）、三通↔右前柱（长 shift）
// 后缘：左后柱↔右后柱（长 rightFrameWidth−shift；右后柱不右移）
rfSpanXFrontLeftNetMm = pipe_net_between_tees_mm(rightFrameWidth - rightFrameShiftX);
rfSpanXFrontRightNetMm = pipe_net_between_tees_mm(rightFrameShiftX);
rfSpanXRearNetMm = pipe_net_between_tees_mm(rightFrameWidth - rightFrameShiftX);

// 顶四通中心（虚拟基准）：仍用于反算 crossTieZ；右柜顶已改为立管直通法兰
rf_z_top = frameHeight - flangeThicknessMm - couplingTotalMm - fittingHeadExtraMm;

// 右缘上段：中圈四通上缘 → 顶翻法兰盘底（直通法兰，无顶四通/对丝）
rfStemStartZ = rightBottomFrameHeight + fittingHeadExtraMm;
rfStemNetMm = frameHeight - flangeThicknessMm - rfStemStartZ;

// 建议下料（xx0，供 BOM；模型几何用上面净长以保住标高）
rfMidPipeCutMm = cut_from_net_mm(rfMidPipeNetMm, "rfMidPipeCutMm");
rfSpanXCutMm = cut_from_net_mm(rfSpanXNetMm, "rfSpanXCutMm");
rfSpanXFrontLeftCutMm = cut_from_net_mm(rfSpanXFrontLeftNetMm, "rfSpanXFrontLeftCutMm");
rfSpanXFrontRightCutMm = cut_from_net_mm(rfSpanXFrontRightNetMm, "rfSpanXFrontRightCutMm");
rfSpanXRearCutMm = cut_from_net_mm(rfSpanXRearNetMm, "rfSpanXRearCutMm");
rfSpanYCutMm = cut_from_net_mm(rfSpanYNetMm, "rfSpanYCutMm");
rfStemCutMm = cut_from_net_mm(rfStemNetMm, "rfStemCutMm");

// 右框世界原点：按未右移的右后柱网定位（frameSpanLength）；左柱/右前再局部 +rightFrameShiftX
rightFrameOriginX = frameSpanLength - frameInset - rightFrameWidth;
rightFrameOriginY = frameInset;

// =============================================================================
// 垂挂 / 拉结层派生（左右框共用 crossTieZ）
// =============================================================================

// 顶管件中心 − 两端外缘搭接 − 垂挂直管净长 → 拉结三通中心
crossTieZ = rf_z_top - 2 * fittingHeadExtraMm - hangPipeNetMm;

// 垂挂直管起点 Z（拉结三通上缘）
hangPipeStartZ = crossTieZ + fittingHeadExtraMm;

// 下框上四通 → 拉结三通之间直通净长（右框左缘柱内）
rfStemBelowTieNetMm = crossTieZ - rf_z_hi - 2 * fittingHeadExtraMm;

// 左缘深向半跨（前三通↔中位三通、中位↔后三通）
// 两端都有三通：净长 = 半中心距 − 2×外缘搭接
rfEdgeHalfNetMm = pipe_net_between_tees_mm(rightFrameDepth / 2);
rfEdgeHalfCutMm = cut_from_net_mm(rfEdgeHalfNetMm, "rfEdgeHalfCutMm");
rfStemBelowTieCutMm = cut_from_net_mm(rfStemBelowTieNetMm, "rfStemBelowTieCutMm");
hangPipeCutMm = cut_from_net_mm(hangPipeNetMm, "hangPipeCutMm");

// =============================================================================
// 左框架派生（手填：leftFrameWidth；单层：底四通 → 垂挂/顶，无中间横拉层）
// =============================================================================

leftFrameDepth = frameWidth;

lf_z_lo = rf_z_lo;       // 左框下四通中心 Z（与右框同脚堆叠）
lf_z_top = rf_z_top;    // 右缘顶平面四通中心 Z（与右框同；左缘顶已无四通）

lfSpanXNetMm = pipe_net_between_tees_mm(leftFrameWidth);
lfSpanYNetMm = pipe_net_between_tees_mm(leftFrameDepth);

// 左缘（外侧）立柱：与右缘同高分段（便于下料同长）
// 下段 / 上段净长共用 lfStemBelowTieNetMm、lfHangToFlangeNetMm
lfStemStartZ = lf_z_lo + fittingHeadExtraMm;
// 旧连续立管长（已不用；保留公式备查）
lfStemNetMm = frameHeight - flangeThicknessMm - lfStemStartZ;
lfStemEndZ = lfStemStartZ + lfStemNetMm;

// 右缘垂挂立柱：底三通上缘 → 拉结三通下缘（标高与右框 crossTieZ 对齐）
lfStemBelowTieNetMm = crossTieZ - lf_z_lo - 2 * fittingHeadExtraMm;

// 右缘垂挂上段：拉结三通上缘 → 顶翻法兰盘底（无顶四通/对丝；与左缘同承面）
lfHangToFlangeNetMm = frameHeight - flangeThicknessMm - hangPipeStartZ;
lfHangToFlangeCutMm = cut_from_net_mm(lfHangToFlangeNetMm, "lfHangToFlangeCutMm");

// 右缘深向半跨（与右框左缘同公式；深向 = frameWidth）
lfEdgeHalfNetMm = pipe_net_between_tees_mm(leftFrameDepth / 2);

lfSpanXCutMm = cut_from_net_mm(lfSpanXNetMm, "lfSpanXCutMm");
lfSpanYCutMm = cut_from_net_mm(lfSpanYNetMm, "lfSpanYCutMm");
lfStemCutMm = cut_from_net_mm(lfStemNetMm, "lfStemCutMm");
lfStemBelowTieCutMm = cut_from_net_mm(lfStemBelowTieNetMm, "lfStemBelowTieCutMm");
lfEdgeHalfCutMm = cut_from_net_mm(lfEdgeHalfNetMm, "lfEdgeHalfCutMm");

// 左框世界原点：桌面左前 inset 内侧
leftFrameOriginX = frameInset;
leftFrameOriginY = frameInset;

// =============================================================================
// 左右框对接横管派生（前/后 @ z_top；中 @ crossTieZ；两端外缘）
// =============================================================================

// 左框右缘柱心 X、右框左缘柱心 X（世界；右框左缘已右移）
deskCrossLeftX = leftFrameOriginX + leftFrameWidth;
deskCrossRightX = rightFrameOriginX + rightFrameShiftX;

// 柱心距 − 两端外缘搭接（整根；中位无三通时用）
deskCrossCenterMm = deskCrossRightX - deskCrossLeftX;
deskCrossNetMm = pipe_net_between_tees_mm(deskCrossCenterMm);
deskCrossCutMm = cut_from_net_mm(deskCrossNetMm, "deskCrossCutMm");

// 管子起点：左缘柱心 + 外缘搭接
deskCrossPipeStartX = deskCrossLeftX + fittingHeadExtraMm;

// Y：前 / 中 / 后（与左右框局部 y=0 / mid / depth 对齐）
deskCrossYFront = leftFrameOriginY;
deskCrossYMid = leftFrameOriginY + leftFrameDepth / 2;
deskCrossYRear = leftFrameOriginY + leftFrameDepth;

// 前/后顶管中点桌面支撑：半跨净长（左柱/右柱 ↔ 中位三通，两端外缘）
deskCrossMidX = (deskCrossLeftX + deskCrossRightX) / 2;
deskCrossHalfNetMm = pipe_net_between_tees_mm(deskCrossCenterMm / 2);
deskCrossHalfCutMm = cut_from_net_mm(deskCrossHalfNetMm, "deskCrossHalfCutMm");

// 顶层中托支口（若恢复前/后顶管）：三通外缘 → 桌底法兰
deskCrossBranchStemNetMm = frameHeight - rf_z_top - fittingHeadExtraMm;
deskCrossBranchStemCutMm = cut_from_net_mm(deskCrossBranchStemNetMm, "deskCrossBranchStemCutMm");

// 垂挂层中托支口：crossTieZ 中三通外缘 → 桌底翻法兰（托中间对接横杆）
deskCrossMidBranchStemNetMm = frameHeight - crossTieZ - fittingHeadExtraMm;
deskCrossMidBranchStemCutMm = cut_from_net_mm(deskCrossMidBranchStemNetMm, "deskCrossMidBranchStemCutMm");
