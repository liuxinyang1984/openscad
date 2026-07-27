// lib/pipe_link.scad
// 模块：管道连接器（对丝/直接头）
// 参数结构：[标准名, outer_d, inner_d, thread_len, center_len]
//
// 可选 coupling_total_mm / coupling_hex_mm：指定对丝总长与六角段轴向长度（两端螺纹各占剩余一半），用于安装余量等建模

module pipe_link(params, coupling_total_mm = undef, coupling_hex_mm = undef) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];  // 三通/四通的距中心长度

    body_length = center_len / 2;
    use_coupling_dims = !is_undef(coupling_total_mm);

    total_length = use_coupling_dims
        ? coupling_total_mm
        : (body_length + thread_l * 2);

    hex_length = !is_undef(coupling_hex_mm)
        ? coupling_hex_mm
        : (body_length * 0.6);

    thread_each = use_coupling_dims
        ? ((total_length - hex_length) / 2)
        : thread_l;

    body_cyl_h = use_coupling_dims ? hex_length : body_length;
    hex_diameter = outer_d * 1.6;

    echo(str("[pipe_link] ", dn_name,
             " 总长=", total_length, "mm",
             " 六角段=", hex_length, "mm",
             " 端螺纹段=", thread_each, "mm",
             " 外径=", outer_d, "mm"));

    difference() {
        union() {
            color([0.2, 0.4, 1, 1]) {
                cylinder(d = outer_d, h = body_cyl_h, center = true);
            }

            color([0.2, 0.4, 1, 1]) {
                cylinder(d = hex_diameter, h = hex_length, center = true, $fn = 6);
            }

            color([0.7, 0.7, 0.7]) {
                translate([0, 0, -total_length / 2])
                    cylinder(d = outer_d, h = thread_each);
                translate([0, 0, total_length / 2 - thread_each])
                    cylinder(d = outer_d, h = thread_each);
            }
        }

        cylinder(d = inner_d, h = total_length + 1, center = true);
    }
}
