# shelf/ — 墙书架

独立项目：坐标用世界绝对值；不引用桌项目变量。
公共管件标准见 `common/standards.scad`。

| 文件 | 说明 |
|------|------|
| `shelf_config.scad` | **只放手填** |
| `standards.scad` | **只放派生**（柱心、板位、管净长/下料） |
| `main.scad` | `shelf_main()` 侧框架 |
| `boards.scad` | 层板（底面压在横管顶上） |
| `panel_plans.scad` | **层板 2D 下料平面图**（尺寸标注；可 Export SVG/DXF） |

面板下料：直接打开 `shelf/panel_plans.scad`，Preview 后可 Export SVG/DXF。

## 定位逻辑

**左右：** 板右缘 = 立柱 − 缝 → 板左缘 → 柱心内缩边距  
**前后：** 板深手填 → 柱心边距 = 孔边距 + 孔半径 → `depthNet`  
**高度：** `shelfOriginZ` = 下层板顶 → 板底压管顶 → 管轴下移 `pipeOD/2`

## 手填

| 参数 | 值 | 含义 |
|------|-----|------|
| `shelfOriginY` | 610 | 墙法兰承面 Y |
| `shelfOriginZ` | 1565 | **下层板上表面** |
| `shelfClearHeightMm` | 340 | 下层板顶 → 上层板底 |
| `shelfLowerBoardLenMm` | 1200 | 下层板长 |
| `shelfUpperBoardLenMm` | 800 | 上层板长 |
| `shelfBoardDepthMm` | 360 | 层板深（前后） |
| `shelfBoardSideMarginMm` | 50 | 左右柱心边距 |
| `shelfBoardHoleEdgeClearMm` | 20 | 孔边距板边 ≥ |
| `shelfBoardHoleExtraMm` | 5 | 孔径 = `pipeOD` + 本值 |
| `shelfStubPipeNetMm` | 50 | 端柱短管净长 |
| `shelfPillarLeftX` | 2270 | 占位立柱左缘 |
| `shelfBoardPillarGapMm` | 10 | 板右缘 ↔ 立柱 |

## 派生（节选）

| 参数 | 含义 |
|------|------|
| `shelfDepthPipeNetMm` | 层深直管净长（由板深与开孔边距反推） |
| `shelfBoardDepthMarginMm` | 前后柱心边距 = 20 + 孔径/2 |
| `shelfFrameOriginZ` | 框架放置 Z（下管轴心） |
| `shelfLowerBoardBottomZ` | 下层板底（= 管顶） |

由根目录 `main.scad` 总装。
