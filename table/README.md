# table/ — 新项目

| 文件 | 说明 |
|------|------|
| `table_config.scad` | **全部设计手填量**（主参数 / 左右框分区）+ 派生尺寸 |
| `standards.scad` | DN15、法兰/搭接、下料函数、`legHeight`、右框派生标高 |
| `right_frame.scad` | 右框架（机柜侧 550×350） |
| `left_frame.scad` | 左框架（机箱侧 300 宽；单层 + 右缘垂挂） |
| `desk_cross.scad` | 左右对接横管（前/后顶层中点托桌 + 中垂挂层） |
| `tabletop.scad` | 桌面板（`tabletopThickness`，半透明） |
| `shelves.scad` | 框上层板（左下框 + 右下/中框，厚 `shelfThicknessMm`） |
| `panel_plans.scad` | **桌板/层板 2D 下料平面图**（尺寸标注；可 Export SVG/DXF） |
| `reference_lines.scad` | Z 参考线；`referenceLinesEnabled` |
| `main.scad` | `main()` 总装入口 |

根目录 `main.scad` 只负责渲染；旧设计快照仍在 `reference/pre-redesign/`（默认不渲染）。

面板下料：直接打开 `table/panel_plans.scad`，Preview 后可 Export SVG/DXF。

## `table_config.scad` 约定

1. **共用**手填 →「主参数」
2. 注释写清 **位置 + 作用**
3. **派生一律计算**；仅某框特殊时在「左/右框架参数」覆盖

## 当前默认尺寸

### 主参数

| 参数 | 值 | 含义 |
|------|-----|------|
| `table_length` | 2560 | 桌面板长（X；右侧相对骨架多 300） |
| `frameSpanLength` | 2260 | 骨架布置跨距（X；右框按此定位） |
| `tabletopCutoutX` | 300 | 桌板右后开洞横向（X，板内） |
| `tabletopCutoutY` | 270 | 桌板右后开洞纵向（Y，板内） |
| `tabletopCutoutOvercutMm` | 20 | 向板外扩切（去外缘边框） |
| `tabletopCornerR` | 5 | 桌板左前/左后/右前圆角；右后开洞直角 |
| `table_width` | 600 | 桌面深（Y） |
| `frameClearHeight` | 740 | 地面 → 桌面底（不含木板） |
| `tabletopThickness` | 25 | 桌面板厚 |
| `table_height` | 765 | `frameClearHeight + tabletopThickness`（桌面顶） |
| `frameInset` | 80 | 桌边 → 柱心（法兰外缘到板边约 47） |
| `footPipeCutMm` | 80 | 脚短管下料（xx0） |
| `hangPipeNetMm` | 100 | 顶四通外缘 ↔ 拉结三通外缘垂挂净长 |
| `shelfThicknessMm` | 12 | 框上层板厚 |

### 右 / 左框架

| 参数 | 值 | 含义 |
|------|-----|------|
| `rightFrameWidth` | 550 | 右框前缘柱心距 X（机柜 505） |
| `rightFrameShiftX` | 300 | 左柱与右前柱右移；右后柱不移 |
| `rightBottomFrameHeight` | 350 | 右框底框高（机柜 333） |
| `leftFrameWidth` | 300 | 左框柱心距 X（中塔机箱；单层无中间横拉） |

### 派生（勿手改）

| 参数 | 约值 | 公式 |
|------|------|------|
| `frameHeight` | 740 | `= frameClearHeight` |
| `frameLength` | 2100 | `frameSpanLength − 2×frameInset` |
| `frameWidth` | 440 | `table_width − 2×frameInset` |
| `crossTieZ` | ~477 | `rf_z_top − 2×extra − hangPipeNetMm`（左右垂挂共用） |
| `deskCrossNetMm` | ~1088 | 中位整根净长（垂挂层） |
| `deskCrossHalfNetMm` | ~528 | 前/后半跨净长（柱 ↔ 中点三通） |
| `deskCrossBranchStemNetMm` | ~50 | 中点支口 → 翻法兰承面 |
| `legHeight` | ~104 | 见 `standards.scad`（法兰+脚管+三通） |
