# common/ — 跨项目共用

`table/` 与 `shelf/` 共用的管件标准、套丝 / 搭接尺寸、下料函数。

| 文件 | 说明 |
|------|------|
| `standards.scad` | DN15、法兰 / 直管参数、对丝、套丝拧入、外缘搭接、净长↔下料换算 |

设计手填量（位置 / 尺寸）不放在本目录；分别见各项目 `*_config.scad`。

## 关键约定

| 参数 | 值 | 含义 |
|------|-----|------|
| `standard` | `"DN15"` | 公称通径 |
| `pipeOD` | 21.3 | 管外径 |
| `pipeThreadMm` | 14 | 管端成品螺纹段长 |
| `fittingTeeCenterMm` | 18 | 三通/四通/直接中心 → 端口 |
| `fittingElbowCenterMm` | 12 | 直角弯头中心 → 端口（DN15） |
| `fittingCapTotalMm` | ~12 | 内丝堵头总长（螺纹段 + 盲端） |
| `flangeThicknessMm` | 10 | 法兰盘厚 |
| `flangeOD` | 65 | 法兰外径 |
| `couplingTotalMm` | 40 | 对丝全长 |
| `couplingHexMm` | 10 | 对丝六角段长 |
| `fittingMainRunMm` | 52 | 三通/四通主通总长 |
| `fittingHalfHeadMm` | 26 | 中心 → 端口（半头） |
| `threadEngageMm` | **10** | **套丝拧入长度 = 直管每端伸入管件的长度** |
| `fittingHeadExtraMm` | 16 | 派生：半头 − 套丝（中心 → 管端外缘） |

## 直管约定

- 几何净长：两端停在管件**搭接外缘**（不到中心）
- 套丝拧入 = 伸入管件 = `threadEngageMm`（10mm）；下料两端各加一次本值，再进位到整厘米 xx0
- `pipeThreadMm`（14mm）只是成品管自带螺纹段长，不进下料公式
