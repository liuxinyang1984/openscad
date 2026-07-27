# table/ — 新项目

| 文件 | 说明 |
|------|------|
| `table_config.scad` | **全部设计手填量**（主参数 / 左右框分区）+ 派生尺寸 |
| `standards.scad` | DN15、法兰/搭接、下料函数、`legHeight`、右框派生标高 |
| `right_frame.scad` | 右框架：四柱 + 三层拉管 + 顶托 + **左缘垂挂** |
| `reference_lines.scad` | Z 参考线；`referenceLinesEnabled` |
| `main.scad` | `main()` 总装入口 |

根目录 `main.scad` 只负责渲染；旧设计见 `reference/pre-redesign/`。

## `table_config.scad` 约定

1. **共用**手填 →「主参数」
2. 注释写清 **位置 + 作用**
3. **派生一律计算**；仅某框特殊时在「左/右框架参数」覆盖

## 当前默认尺寸

### 主参数

| 参数 | 值 | 含义 |
|------|-----|------|
| `table_length` | 2000 | 桌面长（X） |
| `table_width` | 700 | 桌面深（Y） |
| `table_height` | 700 | 桌面顶（Z） |
| `frameInset` | 15 | 桌边 → 框架预留（每侧） |
| `tabletopThickness` | 25 | 桌面板厚 |
| `footPipeCutMm` | 80 | 脚短管下料（xx0） |
| `crossTieBelowDesktopMm` | 0 | 拉结横管相对桌面底下沉 |

### 右 / 左框架

| 参数 | 值 | 含义 |
|------|-----|------|
| `rightFrameWidth` | 550 | 右框柱心距 X（机柜 505 + 两侧 10 + 管径，取整） |
| `rightBottomFrameHeight` | 350 | 右框底框高 → 上四通中心（机柜高 333） |
| `leftFrameWidth` | = 右 | 默认同右框 |
| `leftBottomFrameHeight` | = 右 | 默认同右框 |

### 派生（勿手改）

| 参数 | 约值 | 公式 |
|------|------|------|
| `frameHeight` | 675 | `table_height − tabletopThickness` |
| `frameLength` | 1970 | `table_length − 2×frameInset` |
| `frameWidth` | 670 | `table_width − 2×frameInset` |
| `crossTieZ` | 675 | `frameHeight − crossTieBelowDesktopMm` |
| `legHeight` | ~104 | 见 `standards.scad`（法兰+脚管+三通） |
