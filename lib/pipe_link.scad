// lib/pipe_link.scad
// 模块：管道连接器（对丝/直接头）
// 参数结构：[标准名, outer_d, inner_d, thread_len, center_len]

module pipe_link(params) {
    dn_name      = params[0];
    outer_d      = params[1];
    inner_d      = params[2];
    thread_l     = params[3];
    center_len   = params[4];  // 对于对丝，这是中间管体长度
    
    // 对丝的总长度 = 中间管体长度 + 两端螺纹长度
    total_length = center_len + thread_l * 2;
    
    echo(str("[pipe_link] ", dn_name, 
             " 总长=", total_length, "mm", 
             " 中间段=", center_len, "mm",
             " 螺纹长=", thread_l, "mm",
             " 外径=", outer_d, "mm"));

    difference() {
        // 主体外壳
        cylinder(d = outer_d, h = total_length, center = true);
        
        // 内孔通道
        cylinder(d = inner_d, h = total_length + 1, center = true);
    }
    
    // 中间管体区域（半透明蓝色）
    color([0.2, 0.4, 1, 1]) {
        cylinder(d = outer_d, h = center_len, center = true);
    }
    
    // 两端螺纹区域（实心蓝色）
    color([0.7, 0.7, 0.7]) {
        // 左端螺纹区域
        translate([0, 0, -total_length/2])
        cylinder(d = outer_d, h = thread_l);
        
        // 右端螺纹区域  
        translate([0, 0, total_length/2 - thread_l])
        cylinder(d = outer_d, h = thread_l);
    }
}

// 针对 DN15 对丝的具体参数（基于您的配置表）
//DN15_coupling = ["DN15", 21.3, 15.8, 14, 18];

// 使用示例：
// pipe_link(DN15_coupling);
