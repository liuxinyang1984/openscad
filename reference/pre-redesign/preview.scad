// 备份设计整体预览（自包含于 reference/pre-redesign/，不依赖根目录 table/）
//
// 在 main.scad 中：
//   include <reference/pre-redesign/preview.scad>
//   translate([0, 1000, 0]) reference_backup_preview();

include <table_module.scad>

module reference_backup_preview() {
    table_frames_both_preview();
}
