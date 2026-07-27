# 设计参考备份

重设计前的完整桌架代码快照：**[pre-redesign/](pre-redesign/)**

| 文件 | 说明 |
|------|------|
| `pre-redesign/preview.scad` | 模块 `reference_backup_preview()`，整体渲染备份 |
| `pre-redesign/table_module.scad` | 备份参数链（include `pre-redesign/table/`） |
| `pre-redesign/table/` | 左框 / 右框 / 拉结 |

根目录 **main.scad** 只渲染新项目；需要对照时自行 `use` 本目录 `preview.scad`。

不含 `lib/`、`readme.md`（仍在项目根目录）。
