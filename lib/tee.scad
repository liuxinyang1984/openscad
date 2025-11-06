// lib/tee.scad
// 模块：平面三通（标准螺纹镀锌件 + 外螺纹区）
// 参数结构：[标准名, outer_d, inner_d, thread_len, tee_center_len]

module tee(params, thread_t = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];   // 距中心长度（三通中心到任一端口）

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    name = str("Tee_", dn_name);

    echo(str("[tee] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内径=", inner_d,
        " 螺纹长=", thread_l,
        " 中心距=", center_len,
        " 螺纹厚=", thread_t));

    difference() {
        union() {
            // === 主通主体（Z轴） ===
            // 从 -center_len 到 +center_len
            translate([0, 0, -center_len])
                cylinder(d = outer_d, h = center_len * 2, );

            // === 主通两端外螺纹区 ===
            // 上端 (+Z)
            translate([0, 0, center_len])
                cylinder(d = outer_d + 2 * thread_t, h = thread_l, );
            // 下端 (-Z)
            translate([0, 0, -center_len - thread_l])
                cylinder(d = outer_d + 2 * thread_t, h = thread_l, );

            // === 支通主体（Y轴） ===
            // 从 0 向负Y延伸
            rotate([90, 0, 0])
                translate([0, 0, -center_len])
                    cylinder(d = outer_d, h = center_len, );

            // === 支通外螺纹区 ===
            translate([0, center_len + thread_l, 0])
                rotate([90, 0, 0])
                    cylinder(d = outer_d + 2 * thread_t, h = thread_l, );
        }

        // === 内腔（全贯通） ===
        // 主通内腔
        translate([0, 0, -center_len - thread_l - 0.5])
            cylinder(d = inner_d, h = (center_len + thread_l) * 2 + 1, );

        // 支通内腔
        translate([0, -center_len - thread_l - 0.5, 0])
            rotate([90, 0, 0])
                cylinder(d = inner_d, h = center_len + thread_l + 1, );
    }
}

