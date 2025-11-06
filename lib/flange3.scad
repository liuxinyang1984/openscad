// lib/threaded_flange.scad
// 模块：镀锌三孔内丝法兰
// 参数结构: [公称通径, 法兰外径, 螺栓孔中心圆直径, 螺栓孔直径, 法兰厚度, 螺纹接口直径, 螺纹接口长度]

module threaded_flange(params, thread_thickness = 1.0) {
    dn_name          = params[0];
    flange_od        = params[1];    // 法兰外径
    bolt_circle_d    = params[2];    // 螺栓孔中心圆直径
    bolt_hole_d      = params[3];    // 螺栓孔直径
    flange_thickness = params[4];    // 法兰厚度
    thread_od        = params[5];    // 螺纹接口外径（与钢管外径相同）
    thread_length    = params[6];    // 螺纹接口长度
    
    bolt_count = 3;  // 三孔法兰固定为3个螺栓孔
    
    name = str("ThreadedFlange_", dn_name);

    echo(str("[threaded_flange] 渲染镀锌三孔内丝法兰: ", name,
        " 法兰外径=", flange_od,
        " 螺栓孔中心圆=", bolt_circle_d,
        " 螺栓孔径=", bolt_hole_d,
        " 法兰厚度=", flange_thickness,
        " 螺纹接口直径=", thread_od));

    difference() {
        union() {
            // === 法兰盘主体 ===
            cylinder(d = flange_od, h = flange_thickness);
            
            // === 接口颈部（内丝法兰的接口部分）===
            cylinder(d = thread_od + 4, h = thread_length);
        }
        
        // === 中心管道通孔 ===
        translate([0, 0, -0.5])
            cylinder(d = thread_od, h = thread_length + 1);
        
        // === 三个螺栓孔（120度均布）===
        for (i = [0:bolt_count-1]) {
            angle = i * 120;
            rotate([0, 0, angle])
                translate([bolt_circle_d/2, 0, -0.5])
                    cylinder(d = bolt_hole_d, h = flange_thickness + 1, $fn = 24);
        }
        
        // === 法兰背面倒角 ===
        translate([0, 0, flange_thickness - 1])
            cylinder(d1 = thread_od + 2, 
                    d2 = thread_od + 4, 
                    h = 1);
                    
        // === 内螺纹表示（在孔内壁上做凹槽）===
        for(i = [0:thread_length/2-1]) {
            translate([0, 0, i * 2])
                translate([thread_od/2 - thread_thickness/2, 0, 0])
                    circle(d = thread_thickness, $fn = 16);
        }
    }
}

// 法兰对模块（两个内丝法兰背对背，中间加垫片）
module threaded_flange_pair(params, gasket_thickness = 3, bolt_length = 25) {
    flange_thickness = params[4];
    thread_length = params[6];
    bolt_circle_d = params[2];
    bolt_hole_d = params[3];
    
    total_height = thread_length * 2 + flange_thickness * 2 + gasket_thickness;
    
    // 下方法兰
    threaded_flange(params);
    
    // 上方法兰（翻转）
    translate([0, 0, thread_length + flange_thickness + gasket_thickness])
        rotate([180, 0, 0])
            threaded_flange(params);
    
    // 螺栓（简化表示）
    bolt_count = 3;
    for (i = [0:bolt_count-1]) {
        angle = i * 120;
        rotate([0, 0, angle])
            translate([bolt_circle_d/2, 0, thread_length + flange_thickness]) {
                // 螺栓杆
                color("Silver")
                cylinder(d = bolt_hole_d - 1, h = bolt_length, $fn = 24);
                
                // 螺栓头
                color("DimGray")
                translate([0, 0, -4])
                    cylinder(d = bolt_hole_d * 1.8, h = 4, $fn = 6);
                
                // 螺母
                color("DimGray")
                translate([0, 0, bolt_length])
                    cylinder(d = bolt_hole_d * 1.8, h = 4, $fn = 6);
            }
    }
    
    // 垫片
    color("Red")
    translate([0, 0, thread_length + flange_thickness])
        cylinder(d = bolt_circle_d - 5, h = gasket_thickness);
}
