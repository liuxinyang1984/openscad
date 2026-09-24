// lib/elbow.scad
// 模块：直角弯头 / 90°（标准螺纹镀锌件 + 外螺纹区）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len, elbow_center_len]
// 端口：+Z 与 −Y，夹角 90°；中心距取 params[5]（弯头距中心长度）

module elbow(params, thread_t = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[5];   // 弯头中心 → 任一端口

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    thread_l2 = thread_l / 2;
    name = str("Elbow_", dn_name);

    echo(str("[elbow] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 实际螺纹长度=", thread_l2,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t));

    difference() {
        union() {
            // === +Z 口 ===
            union() {
                color([0.2, 0.4, 1]) {
                    translate([0, 0, 0])
                        cylinder(d = outer_d, h = center_len);
                }
                color([0.7, 0.7, 0.7]) {
                    translate([0, 0, center_len])
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                }
            }

            // === −Y 口 ===
            union() {
                color([0.2, 0.4, 1]) {
                    rotate([90, 0, 0])
                        translate([0, 0, -center_len])
                            cylinder(d = outer_d, h = center_len);
                }
                color([0.7, 0.7, 0.7]) {
                    rotate([90, 0, 0])
                        translate([0, 0, -center_len - thread_l2])
                            cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                }
            }

            color([0.2, 0.4, 1, 0.5])
                sphere(d = outer_d);
        }

        // +Z 内腔
        translate([0, 0, -0.5])
            cylinder(d = inner_d, h = center_len + thread_l2 + 1);

        // −Y 内腔
        rotate([90, 0, 0])
            translate([0, 0, -center_len - thread_l2 - 0.5])
                cylinder(d = inner_d, h = center_len + thread_l2 + 1);
    }
}
