// lib/socket.scad
// 模块：直接 / 内丝直接（两端内丝直通；相当于三通去掉支通）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len, ...]
// 端口：±Z；中心距取 params[4]（与三通主通相同）

module socket(params, thread_t = undef) {
    dn_name    = params[0];
    outer_d    = params[1];
    inner_d    = params[2];
    thread_l   = params[3];
    center_len = params[4];   // 中心 → 任一端口（同三通）

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    thread_l2 = thread_l / 2;
    name = str("Socket_", dn_name);

    echo(str("[socket] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 实际螺纹长度=", thread_l2,
        " 中心距=", center_len,
        " 主通总长=", center_len * 2,
        " 螺纹厚=", thread_t));

    difference() {
        union() {
            // 主体管段（Z 轴）
            color([0.2, 0.4, 1])
                translate([0, 0, -center_len])
                    cylinder(d = outer_d, h = center_len * 2);

            // +Z 口外螺纹区外观
            color([0.7, 0.7, 0.7])
                translate([0, 0, center_len])
                    cylinder(d = outer_d + 2 * thread_t, h = thread_l2);

            // −Z 口外螺纹区外观
            color([0.7, 0.7, 0.7])
                translate([0, 0, -center_len - thread_l2])
                    cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
        }

        // 通腔内腔
        translate([0, 0, -center_len - thread_l2 - 0.5])
            cylinder(d = inner_d, h = 2 * (center_len + thread_l2) + 1);
    }
}
