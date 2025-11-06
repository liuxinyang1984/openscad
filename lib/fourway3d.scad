// lib/fourway3d.scad
// 模块：立体四通（X/Y/Z 两端方向标准螺纹镀锌件）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len]

module fourway3d(params, thread_t = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    name = str("Fourway3D_", dn_name);

    echo(str("[fourway3d] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t));

    //color([00,99,ff,0.3])  // 红色，30% 透明
    difference() {
        union() {
            // === X轴通道 ===
            rotate([0, 90, 0])
                union() {
                    translate([0, 0, -center_len])
                        cylinder(d = outer_d, h = center_len);
                    translate([0, 0, -center_len - thread_l])
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l);
                }

            // === Y轴通道 ===
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

            // 内外交汇球体
            translate([0,0,0])
                sphere(d = outer_d);
        }

        // === 内腔：四轴贯通 ===
        // X轴内腔
        rotate([0, 90, 0])
            translate([0, 0, -center_len - thread_l - 0.5])
                cylinder(d = inner_d, h = center_len + thread_l + 1);

        // Y轴内腔
        rotate([-90, 0, 0])
            translate([0, 0, -center_len - thread_l - 0.5])
                cylinder(d = inner_d, h = center_len + thread_l + 1);

        // Z轴内腔上下贯通
        translate([0, 0, -center_len - thread_l - 0.5])
            cylinder(d = inner_d, h = 2 * center_len + thread_l * 2 +1 );
    }
}

