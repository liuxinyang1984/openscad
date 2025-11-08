// lib/pipe_link.scad
// 模块：管道连接器（对丝/直接头）
// 参数结构：[标准名, outer_d, inner_d, thread_len, center_len]

module pipe_link(params) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];  // 三通/四通的距中心长度
    
    // 对丝的中间管体长度 = 三通距中心长度的一半
    body_length = center_len / 2;
    
    // 对丝的总长度 = 中间管体长度 + 两端螺纹长度
    total_length = body_length + thread_l * 2;
    
    // 六角螺母的外接圆直径（比管道外径稍大）
    hex_diameter = outer_d * 1.6;
    // 六角部分的长度（约为中间管体长度的60%）
    hex_length = body_length * 0.6;
    
    echo(str("[pipe_link] ", dn_name, 
             " 总长=", total_length, "mm", 
             " 中间段=", body_length, "mm",
             " 螺纹长=", thread_l, "mm",
             " 外径=", outer_d, "mm"));

    difference() {
        union() {
            // 中间管体区域（圆柱部分）
            color([0.2, 0.4, 1, 1]) {
                cylinder(d = outer_d, h = body_length, center = true);
            }
            
            // 中间六角部分（整体）
            color([0.2, 0.4, 1, 1]) {
                cylinder(d = hex_diameter, h = hex_length, center = true, $fn = 6);
            }
            
            // 两端螺纹区域
            color([0.7, 0.7, 0.7]) {
                // 左端螺纹区域
                translate([0, 0, -total_length/2])
                cylinder(d = outer_d, h = thread_l);
                
                // 右端螺纹区域  
                translate([0, 0, total_length/2 - thread_l])
                cylinder(d = outer_d, h = thread_l);
            }
        }
        
        // 内孔通道
        cylinder(d = inner_d, h = total_length + 1, center = true);
    }
}
