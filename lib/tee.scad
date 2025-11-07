// lib/tee.scad
// 模块：平面三通（标准螺纹镀锌件 + 外螺纹区）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len]

module tee(params, thread_t = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];   // 距中心长度（三通中心到任一端口）

    // === 螺纹厚度与实际螺纹长度 ===
    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    thread_l2 = thread_l / 2;
    name = str("Tee_", dn_name);

    echo(str("[tee] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 实际螺纹长度=", thread_l2,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t));

    difference() {
        // === 外部结构 ===
        union() {
            // === 主通主体（Z轴） ===
            union() {
                // 主体管段
                color([0.2, 0.4, 1]) {
                    translate([0, 0, -center_len]) {
                        cylinder(d = outer_d, h = center_len * 2);
                    }
                }
                // 上端 (+Z) 外螺纹
                color([0.7, 0.7, 0.7]) {
                    translate([0, 0, center_len]) {
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                    }
                }
                // 下端 (-Z) 外螺纹
                color([0.7, 0.7, 0.7]) {
                    translate([0, 0, -center_len - thread_l2]) {
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                    }
                }
            }

            // === 支通主体（Y轴） ===
            union() {
                // 主体管段
                color([0.2, 0.4, 1]) {
                    rotate([90, 0, 0]) {
                        translate([0, 0, -center_len]) {
                            cylinder(d = outer_d, h = center_len);
                        }
                    }
                }
                // 外螺纹（从端口向外）
                color([0.7, 0.7, 0.7]) {
                    rotate([90, 0, 0]) {
                        translate([0, 0, -center_len - thread_l2]) {
                            cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                        }
                    }
                }
            }

            // === 内外交汇球体 ===
            color([0.2, 0.4, 1, 0.5]) {
                sphere(d = outer_d);
            }
        }

        // === 内腔 ===
        // 主通内腔
        translate([0, 0, -center_len - thread_l2 - 0.5]) {
            cylinder(d = inner_d, h = 2 * (center_len + thread_l2) + 1);
        }

        // 支通内腔
        rotate([90, 0, 0]) {
            translate([0, 0, -center_len - thread_l2 - 0.5]) {
                cylinder(d = inner_d, h = center_len + thread_l2 + 1);
            }
        }
    }
}

