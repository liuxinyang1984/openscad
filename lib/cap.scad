// lib/cap.scad
// 模块：内丝堵头 / 管帽（盲端内螺纹，拧在管子外丝上）
// 参数结构：[标准名, outer_d, inner_d, thread_len, ...]
// 坐标：开口平面在 z=0，本体沿 +Z，盲端在 +total_h

module cap(params, thread_t = undef) {
    dn_name  = params[0];
    outer_d  = params[1];
    inner_d  = params[2];
    thread_l = params[3];

    thread_t  = is_undef(thread_t) ? (outer_d * 0.1) : thread_t;
    thread_l2 = thread_l / 2;           // 可视螺纹段长（与三通/弯头一致）
    end_wall  = max(4, outer_d * 0.25); // 盲端壁厚
    total_h   = thread_l2 + end_wall;
    hex_d     = outer_d * 1.6;
    bore_d    = outer_d;                // 内丝孔径 ≈ 管外径（与法兰一致）
    name = str("Cap_", dn_name);

    echo(str("[cap] 渲染标准件: ", name,
        " 外径=", outer_d,
        " 内丝孔=", bore_d,
        " 螺纹段=", thread_l2,
        " 总长=", total_h,
        " 六角对边≈", hex_d,
        " 盲端壁厚=", end_wall));

    difference() {
        union() {
            // 六角主体（扳手位）
            color([0.2, 0.4, 1])
                cylinder(d = hex_d, h = total_h, $fn = 6);

            // 开口端外螺纹区外观（加厚环）
            color([0.7, 0.7, 0.7])
                cylinder(d = outer_d + 2 * thread_t, h = thread_l2);
        }

        // 内丝盲孔（不到底）
        translate([0, 0, -0.5])
            cylinder(d = bore_d, h = thread_l2 + 0.5);
    }
}
