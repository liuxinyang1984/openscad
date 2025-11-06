// lib/fiveway3d.scad
// 模块：立体五通（X/Y/Z 双向 + X 额外接口）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len]

module fiveway3d(params, thread_t = undef,) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    name = str("Fiveway3D_", dn_name);

    echo(str("[fiveway3d] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t));

    difference() {
        union() {
            // === 原 X/Y 轴通道 ===
            rotate([0, 90, 0])
                union() {
                    translate([0, 0, -center_len])
                        cylinder(d = outer_d, h = center_len);
                    translate([0, 0, -center_len - thread_l])
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l);
                }

            rotate([-90, 0, 0])
                union() {
                    translate([0, 0, -center_len])
                        cylinder(d = outer_d, h = center_len);
                    translate([0, 0, -center_len - thread_l])
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l);
                }

            // === Z轴上下通道 ===
            union() {
                // 向下
                translate([0, 0, -center_len])
                    cylinder(d = outer_d, h = center_len);
                translate([0, 0, -center_len - thread_l])
                    cylinder(d = outer_d + 2 * thread_t, h = thread_l);
                // 向上
                translate([0, 0, 0])
                    cylinder(d = outer_d, h = center_len);
                translate([0, 0, center_len])
                    cylinder(d = outer_d + 2 * thread_t, h = thread_l);
            }

            // === 新增 X 轴接口（负方向） ===
            rotate([0,90,0])
                union() {
                    translate([0,0,0])
                        cylinder(d = outer_d, h = center_len);
                    translate([0,0,center_len])
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l);
                }

            // 内外交汇球体
            translate([0,0,0])
                sphere(d = outer_d);
        }

        // === 内腔差集 ===
        // X轴内腔
        rotate([0, 90, 0])
            translate([0,0,-center_len - thread_l - 0.5])
                cylinder(d = inner_d, h = center_len + thread_l + 1);

        // Y轴内腔
        rotate([-90,0,0])
            translate([0,0,-center_len - thread_l - 0.5])
                cylinder(d = inner_d, h = center_len + thread_l + 1);

        // Z轴内腔上下贯通
        translate([0,0,-center_len - thread_l - 0.5])
            cylinder(d = inner_d, h = 2 * center_len + thread_l*2 + 1);

        // 新增 X 轴接口内腔
        rotate([0,90,0])
            translate([0,0,0])
                cylinder(d = inner_d, h = center_len + thread_l + 1);
    }
}

