// main.scad — 渲染新项目 + 旧备份对照
//
// 新项目：include（当前设计变量）
// 旧备份：use（独立作用域，避免与新项目变量名冲突）

include <table/main.scad>
main();

use <reference/pre-redesign/preview.scad>
translate([0, 1000, 0])
    reference_backup_preview();
