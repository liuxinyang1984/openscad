// table/standards.scad — 管件标准、商家搭接尺寸、下料 / 标高计算
//
// 依赖：须先 include <table_config.scad>（手填与派生主尺寸）
// 本文件不放「设计手填量」；legHeight 等由主参数 + 标准件算出

include <../config.scad>
include <../utils.scad>

standard = "DN15";
flange_params = get_threaded_flange_params(standard);
pipe_params = get_pipe_params(standard);

pipe = pipe_params[1];
pipeThreadMm = pipe_params[3];
flangeThicknessMm = flange_params[4];
flangeThreadLengthMm = flange_params[6];
flangeOD = flange_params[1];

assert(frameInset >= flangeOD / 2,
    str("frameInset=", frameInset, " 须 ≥ 法兰半径 ", flangeOD / 2, "，否则法兰探出桌板"));

couplingTotalMm = 40;
couplingHexMm = 10;

fittingMainRunMm = 52;
fittingHalfHeadMm = 26;
fittingThreadEngageMm = 10;
fittingHeadExtraMm = fittingHalfHeadMm - fittingThreadEngageMm;

function cut_round_xx0(mm) = ceil(mm / 10) * 10;

function cut_must_xx0(cut_mm, name = "cut") =
    assert(cut_mm % 10 == 0, str(name, " 下料须为整厘米 xx0 mm"))
    cut_mm;

function cut_from_net_mm(net_mm, name = "cut") =
    cut_must_xx0(cut_round_xx0(net_mm + 2 * pipeThreadMm), name);

function net_from_cut_mm(cut_mm) = cut_mm - 2 * pipeThreadMm;

function fitting_center_to_center_mm(pipe_net_mm) =
    pipe_net_mm + 2 * fittingHeadExtraMm;

function pipe_span_half_net_mm(center_half_mm) =
    // 仅一端有管件、另一端为几何中点时用；两端皆为管件请用 pipe_net_between_tees_mm
    center_half_mm - fittingHeadExtraMm;

function pipe_net_between_tees_mm(center_mm) =
    center_mm - 2 * fittingHeadExtraMm;

// 桌脚：落地法兰盘顶 + 脚短管净长 + 拧入余量 + 三通上半头（至主通 +Z 外端）
footPipeNetMm = net_from_cut_mm(cut_must_xx0(footPipeCutMm, "footPipeCutMm"));

function foot_stack_top_z(
    flange_t = flangeThicknessMm,
    foot_net = footPipeNetMm,
    conn = fittingHeadExtraMm,
    half_head = fittingHalfHeadMm
) = flange_t + foot_net + conn + half_head;

legHeight = foot_stack_top_z();

// =============================================================================
// 右框架派生（手填见 table_config；此处只计算）
// =============================================================================

// 前后柱心距（沿 +Y）= 整桌框架深向可用宽
rightFrameDepth = frameWidth;

// 下四通中心 Z：法兰盘顶 + 脚管净长 + 拧入余量
rf_z_lo = flangeThicknessMm + footPipeNetMm + fittingHeadExtraMm;

// 下框上四通中心 Z（设计手填）
rf_z_hi = rightBottomFrameHeight;

// 下半中立管净长：下四通中心 ↔ 上四通中心，两端均停在管件搭接外缘（非外径/中心）
rfMidPipeNetMm = rf_z_hi - rf_z_lo - 2 * fittingHeadExtraMm;

rfSpanXNetMm = pipe_net_between_tees_mm(rightFrameWidth);
rfSpanYNetMm = pipe_net_between_tees_mm(rightFrameDepth);

// 梯形右移后各段 X 净长（外缘约定）
// 前缘：左柱↔三通（长 rightFrameWidth−shift）、三通↔右前柱（长 shift）
// 后缘：左后柱↔右后柱（长 rightFrameWidth−shift；右后柱不右移）
rfSpanXFrontLeftNetMm = pipe_net_between_tees_mm(rightFrameWidth - rightFrameShiftX);
rfSpanXFrontRightNetMm = pipe_net_between_tees_mm(rightFrameShiftX);
rfSpanXRearNetMm = pipe_net_between_tees_mm(rightFrameWidth - rightFrameShiftX);

// 顶四通中心：桌面底向下 = 法兰盘厚 + 对丝全长 + 拧入余量
rf_z_top = frameHeight - flangeThicknessMm - couplingTotalMm - fittingHeadExtraMm;

// 上半衔接管：下框上四通顶侧 → 顶四通底侧
rfStemStartZ = rightBottomFrameHeight + fittingHeadExtraMm;
rfStemNetMm = rf_z_top - rfStemStartZ - fittingHeadExtraMm;

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
// 两端都有三通：净长 = 半中心距 − 2×搭接（管子停在管件外缘，不到中心）
rfEdgeHalfNetMm = pipe_net_between_tees_mm(rightFrameDepth / 2);
rfEdgeHalfCutMm = cut_from_net_mm(rfEdgeHalfNetMm, "rfEdgeHalfCutMm");
rfStemBelowTieCutMm = cut_from_net_mm(rfStemBelowTieNetMm, "rfStemBelowTieCutMm");
hangPipeCutMm = cut_from_net_mm(hangPipeNetMm, "hangPipeCutMm");

// =============================================================================
// 左框架派生（手填：leftFrameWidth；单层：底四通 → 垂挂/顶，无中间横拉层）
// =============================================================================

leftFrameDepth = frameWidth;

lf_z_lo = rf_z_lo;
lf_z_top = rf_z_top;

lfSpanXNetMm = pipe_net_between_tees_mm(leftFrameWidth);
lfSpanYNetMm = pipe_net_between_tees_mm(leftFrameDepth);

// 左缘（外侧）立柱：底四通上缘 → 顶四通下缘（单段）
lfStemStartZ = lf_z_lo + fittingHeadExtraMm;
lfStemNetMm = lf_z_top - lfStemStartZ - fittingHeadExtraMm;

// 右缘垂挂立柱：底四通上缘 → 拉结三通下缘（标高与右框 crossTieZ 对齐）
lfStemBelowTieNetMm = crossTieZ - lf_z_lo - 2 * fittingHeadExtraMm;

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

// 柱心距 − 两端搭接外缘（整根；中位无三通时用）
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

// 中位三通支口上缘 → 翻法兰承面（frameHeight = 桌面底；与角柱顶托同约定）
deskCrossBranchStemNetMm = frameHeight - rf_z_top - fittingHeadExtraMm;
deskCrossBranchStemCutMm = cut_from_net_mm(deskCrossBranchStemNetMm, "deskCrossBranchStemCutMm");
