// lib/tee3d.scad
// 模块：立体三通（X/Y/Z 三方向标准螺纹镀锌件）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len]

module tee3d(params, thread_t = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];

    // 螺纹厚度与实际螺纹长度
    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    thread_l2 = thread_l / 2;
    name = str("Tee3D_", dn_name);

    echo(str("[tee3d] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t,
        " 实际螺纹长度=", thread_l2));

    difference() {
        // === 外部结构 ===
        union() {
            // === X轴通道 ===
            rotate([0, 90, 0]) {
                union() {
                    // 主体管段
                    color([0.2, 0.4, 1]) {
                        translate([0, 0, -center_len]) {
                            cylinder(d = outer_d, h = center_len);
                        }
                    }
                    // 螺纹段（从端口向外延伸）
                    color([0.7, 0.7, 0.7]) {
                        translate([0, 0, -center_len - thread_l2]) {
                            cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                        }
                    }
                }
            }

            // === Y轴通道 ===
            rotate([-90, 0, 0]) {
                union() {
                    // 主体管段
                    color([0.2, 0.4, 1]) {
                        translate([0, 0, -center_len]) {
                            cylinder(d = outer_d, h = center_len);
                        }
                    }
                    // 螺纹段
                    color([0.7, 0.7, 0.7]) {
                        translate([0, 0, -center_len - thread_l2]) {
                            cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                        }
                    }
                }
            }

            // === Z轴通道 ===
            union() {
                // 向下（主干方向）
                color([0.2, 0.4, 1]) {
                    translate([0, 0, -center_len]) {
                        cylinder(d = outer_d, h = center_len);
                    }
                }
                // 外螺纹
                color([0.7, 0.7, 0.7]) {
                    translate([0, 0, -center_len - thread_l2]) {
                        cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
                    }
                }
            }

            // === 内外交汇球体 ===
            color([0.2, 0.4, 1, 0.5]) {
                sphere(d = outer_d);
            }
        }

        // === 内腔 ===
        // X轴内腔
        rotate([0, 90, 0]) {
            translate([0, 0, -center_len - thread_l2 - 0.5]) {
                cylinder(d = inner_d, h = center_len + thread_l2 + 1);
            }
        }

        // Y轴内腔
        rotate([-90, 0, 0]) {
            translate([0, 0, -center_len - thread_l2 - 0.5]) {
                cylinder(d = inner_d, h = center_len + thread_l2 + 1);
            }
        }

        // Z轴内腔
        translate([0, 0, -center_len - thread_l2 - 0.5]) {
            cylinder(d = inner_d, h = center_len + thread_l2 + 1);
        }
    }
}

