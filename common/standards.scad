// common/standards.scad — 跨项目共用：管件标准、套丝/搭接尺寸、下料函数
//
// 供 table/ 与 shelf/ 共用；本文件不放任何「设计手填量」（位置/尺寸等）
// 设计手填分别见 table/table_config.scad、shelf/shelf_config.scad
//
// 依赖：根 config.scad（pipe_table / threaded_flange_table / $fn）+ utils.scad（lib 几何模块）

include <../config.scad>
include <../utils.scad>

// =============================================================================
// 公称通径与管件参数组（查表）
// =============================================================================

// 公称通径（项目统一）
standard = "DN15";

// 法兰参数组（结构见 config.scad 的 threaded_flange_table）
flange_params = get_threaded_flange_params(standard);

// 直管参数组（结构见 config.scad 的 pipe_table）
pipe_params = get_pipe_params(standard);

// =============================================================================
// 直管 / 法兰几何（从参数组拆出，便于直接引用）
// =============================================================================

pipeOD = pipe_params[1];              // 管外径（mm）
pipeThreadMm = pipe_params[3];        // 管端成品螺纹段长（mm）
fittingTeeCenterMm = pipe_params[4];  // 三通/四通中心→端口（mm）
fittingElbowCenterMm = pipe_params[5]; // 弯头中心→端口（mm）；DN15=12

// 内丝堵头 / 管帽（派生自 pipe_params；几何见 lib/cap.scad）
fittingCapThreadMm = pipeThreadMm / 2;              // 可视螺纹段
fittingCapEndWallMm = max(4, pipeOD * 0.25);        // 盲端壁厚
fittingCapTotalMm = fittingCapThreadMm + fittingCapEndWallMm; // 总长

flangeOD = flange_params[1];          // 法兰盘外径（mm）
flangeThicknessMm = flange_params[4]; // 法兰盘厚度（mm）
flangeThreadLengthMm = flange_params[6]; // 法兰螺纹接口长度（mm）

// =============================================================================
// 对丝（pipe_link，成品不切断）
// =============================================================================

couplingTotalMm = 40; // 对丝全长（mm）
couplingHexMm = 10;   // 对丝六角段长（mm）

// =============================================================================
// 三通/四通/五通主通尺寸（商家实测）
// =============================================================================

fittingMainRunMm = 52; // 主通总长（两端端口间距）
fittingHalfHeadMm = 26; // 中心 → 任一端口（半头）

// =============================================================================
// 套丝 / 伸入（管件连接的「插件部分」）
// =============================================================================

// 套丝拧入长度：直管每端伸入管件的长度（mm）
// 下料两端各加一次本值；外缘搭接 = 半头 − 本值
threadEngageMm = 10;

// 中心 → 管端外缘（管子停在搭接外缘，不到管件中心）
fittingHeadExtraMm = fittingHalfHeadMm - threadEngageMm;

// =============================================================================
// 下料 / 净长换算函数
// =============================================================================

// 整厘米进位（xx0 mm）
function cut_round_xx0(mm) = ceil(mm / 10) * 10;

// 断言下料为整厘米
function cut_must_xx0(cut_mm, name = "cut") =
    assert(cut_mm % 10 == 0, str(name, " 下料须为整厘米 xx0 mm"))
    cut_mm;

// 净长 → 下料：两端各加 threadEngageMm（套丝拧入），再进位到 xx0
// 约定：套丝长度 = 伸入管件长度（threadEngageMm），不用成品管全长 pipeThreadMm
function cut_from_net_mm(net_mm, name = "cut") =
    cut_must_xx0(cut_round_xx0(net_mm + 2 * threadEngageMm), name);

// 下料 → 净长
function net_from_cut_mm(cut_mm) = cut_mm - 2 * threadEngageMm;

// 两管件中心距 → 直管净长（两端各扣外缘搭接）
function pipe_net_between_tees_mm(center_mm) =
    center_mm - 2 * fittingHeadExtraMm;

// 直管净长 → 两管件中心距
function fitting_center_to_center_mm(pipe_net_mm) =
    pipe_net_mm + 2 * fittingHeadExtraMm;

// 仅一端有管件、另一端为几何中点：净长 = 半中心距 − 外缘搭接
function pipe_span_half_net_mm(center_half_mm) =
    center_half_mm - fittingHeadExtraMm;
