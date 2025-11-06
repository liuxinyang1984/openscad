include <config.scad>
include <lib/pipe.scad>
include <lib/tee.scad>
include <lib/tee3d.scad>
include <lib/fourway3d.scad>
include <lib/fiveway3d.scad>
include <lib/flange3.scad>

standard = "DN15";
// 获取参数
flange_params = get_threaded_flange_params(standard);
pipe_params = get_pipe_params(standard);

// 实际尺寸
table_width = 700;
table_length = 2000;
table_height = 800; 


// 框架尺寸
frame_width = table_width - 50 * 2;
frame_length = table_length - 50 *2;
frame_height = table_height;
storage_width = 400;

// 计算长度
vertical_pipe_all           = frame_height - pipe_params[4] * 4 - flange_params[4]; 
vertical_pipe_left_top      = frame_height /3 - pipe_params[4] *2;
vertical_pipe_left_bottom   = frame_height /3 * 2 - pipe_params[4] *2 - flange_params[4]; 
vertical_pipe_right_top     = frame_height /5 * 2 - pipe_params[4] *2;
vertical_pipe_right_middle  = frame_height /5 * 2 - pipe_params[4] *2;
vertical_pipe_right_bottom  = frame_height /5 - pipe_params[4] *2 - flange_params[4]; 
horizontal_pipe_all         = frame_length - pipe_params[4] * 6;
horizontal_pipe_left        = frame_length / 2 -  pipe_params[4] * 2;
horizontal_pipe_right_l     = frame_length / 2 - storage_width - pipe_params[4] * 2;
horizontal_pipe_right_r     = storage_width -  pipe_params[4] * 2;
depth_pipe_all = table_width - pipe_params[4] * 2;


module left_frame(){
    // 纵向左上管
    translate([0,flange_params[4],frame_height - pipe_params[4]]){
        rotate([-90,0,0]){
            pipe(pipe_params,depth_pipe_all);
        }
    }
    // 横向后左上管
    translate([0,depth_pipe_all,frame_height - pipe_params[4]]){
        rotate([0,90,0]){
            pipe(pipe_params,horizontal_pipe_left);
        }
    }
    // 横向前左上管
    translate([0,0,frame_height - pipe_params[4]]){
        rotate([0,90,0]){
            pipe(pipe_params,horizontal_pipe_left);
        }
    }
    union() {
        translate([0,0,frame_height - pipe_params[4]])
            rotate([0,0,180])
                fourway3d(pipe_params);
        translate([0,0,vertical_pipe_left_bottom + flange_params[4] + pipe_params[4] * 2])
            pipe(pipe_params, vertical_pipe_left_top);
        translate([0,0,vertical_pipe_left_bottom + flange_params[4] + pipe_params[4]])
            tee(pipe_params);
        translate([0,0,flange_params[4]])
            pipe(pipe_params, vertical_pipe_left_bottom);
        threaded_flange(flange_params);
    }

    // 纵向左下管
    translate([0,flange_params[4],vertical_pipe_left_bottom + flange_params[4] + pipe_params[4]]){
        rotate([-90,0,0]){
            pipe(pipe_params,depth_pipe_all);
        }
    }

    // 横向左下管
    translate([0,depth_pipe_all,vertical_pipe_left_bottom + flange_params[4] + pipe_params[4]]){
        rotate([0,90,0]){
            pipe(pipe_params,horizontal_pipe_left);
        }
    }

    translate([0,depth_pipe_all,0]){
        rotate([0,0,90]){
            union() {
                translate([0,0,frame_height - pipe_params[4]])
                    rotate([0,0,0])
                        fourway3d(pipe_params);
                translate([0,0,vertical_pipe_left_bottom + flange_params[4] + pipe_params[4] * 2])
                    pipe(pipe_params, vertical_pipe_left_top);
                translate([0,0,vertical_pipe_left_bottom + flange_params[4] + pipe_params[4]])
                    rotate([0,0,0])
                        fourway3d(pipe_params);
                translate([0,0,flange_params[4]])
                    pipe(pipe_params, vertical_pipe_left_bottom);
                threaded_flange(flange_params);
            }
        }
    }
}


module right_frame(){
    // 后右下腿
    union() {
        translate([0,depth_pipe_all,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 2]){
            pipe(pipe_params, vertical_pipe_right_middle);
        }
        translate([0,depth_pipe_all,0]){
            translate([0,0,vertical_pipe_right_bottom + flange_params[4] + pipe_params[4]]){
                rotate([0,0,90]){
                    tee(pipe_params);
                }
            }
            translate([0,0,flange_params[4]]){
                pipe(pipe_params, vertical_pipe_right_bottom);
            }
            threaded_flange(flange_params);
        }
    }
    // 后右横管
    translate([0,depth_pipe_all,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4]]){
        rotate([0,-90,0]){
            pipe(pipe_params,horizontal_pipe_right_r);
        }
    }



    // 后左下腿
    union() {
        translate([0,depth_pipe_all,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 3 + vertical_pipe_right_middle]){
            rotate([0,0,180]){
                tee(pipe_params);
            }
        }
        translate([-horizontal_pipe_right_r,depth_pipe_all,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 2]){
            pipe(pipe_params, vertical_pipe_right_middle);
        }
        translate([-horizontal_pipe_right_r,depth_pipe_all,0]){
            translate([0,0,vertical_pipe_right_bottom + flange_params[4] + pipe_params[4]]){
                rotate([0,0,270]){
                    tee(pipe_params);
                }
            }
            translate([0,0,flange_params[4]]){
                pipe(pipe_params, vertical_pipe_right_bottom);
            }
            threaded_flange(flange_params);
        }
    }




    // 前右下腿
    union() {
        translate([0,0,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 3 + vertical_pipe_right_middle]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([0,0,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 2]){
            pipe(pipe_params, vertical_pipe_right_middle);
        }
        translate([0,0,vertical_pipe_right_bottom + flange_params[4] + pipe_params[4]]){
            rotate([0,0,90]){
                tee(pipe_params);
            }
        }
        translate([0,0,flange_params[4]]){
            pipe(pipe_params, vertical_pipe_right_bottom);
        }
        threaded_flange(flange_params);
    }
    // 右前横管
    translate([0,0,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4]]){
        rotate([0,-90,0]){
            pipe(pipe_params,horizontal_pipe_right_r);
        }
    }
    // 前左下腿
    union() {

        translate([-horizontal_pipe_right_r,0,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 3 + vertical_pipe_right_middle]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([-horizontal_pipe_right_r,0,flange_params[4] + vertical_pipe_right_bottom + pipe_params[4] * 2]){
            pipe(pipe_params, vertical_pipe_right_middle);
        }
        translate([-horizontal_pipe_right_r,0,0]){
            translate([0,0,vertical_pipe_right_bottom + flange_params[4] + pipe_params[4]]){
                rotate([0,0,270]){
                    tee(pipe_params);
                }
            }
            translate([0,0,flange_params[4]]){
                pipe(pipe_params, vertical_pipe_right_bottom);
            }
            threaded_flange(flange_params);
        }
    }
}


module complete_table(){
    //color([0.6, 0.0, 0.0, 0.5])  // 深红 + 半透明
    //left_frame();
    color([0,0.6,0,0.5])
    right_frame();
}
complete_table();



















//// 桌子的四个角
//module table_corner(x, y, z,rotation) {
//    translate([x, y, z]) {
//        // 垂直管道（桌腿）
//        pipe(pipe_params, vertical_pipe_length);
//        
//        // 三通在顶部连接
//        translate([0, 0, vertical_pipe_length])
//            rotate([0,0,rotation])
//                tee3d(pipe_params);
//        
//    }
//}
//module table_3d_corner(x, y, z,rotation) {
//    translate([x, y, z]) {
//        // 垂直管道（桌腿）
//        pipe(pipe_params, vertical_pipe_length);
//        
//        // 三通在顶部连接
//        translate([0, 0, vertical_pipe_length])
//            rotate([0,0,rotation])
//                fourway3d(pipe_params);
//        
//        // 法兰在底部作为脚
//        translate([0, 0, -flange_params[4]])
//            rotate([0, 0, 0])
//                threaded_flange(flange_params);
//    }
//}
//
//module table_top_frame(){
//    table_corner(0, 0, 0,180);
//    table_corner(table_length,0,0,270);
//    table_corner(table_length,table_width,0);
//    table_corner(0,table_width,0,90);
//
//    translate([pipe_params[1], 0, vertical_pipe_length])
//        rotate([0, 90, 0])
//            pipe(pipe_params, horizontal_length_pipe);
//    translate([pipe_params[1], table_width, vertical_pipe_length])
//        rotate([0, 90, 0])
//            pipe(pipe_params, horizontal_length_pipe);
//   // 短边水平管道（左右）
//    translate([0, pipe_params[1], vertical_pipe_length])
//        rotate([-90, 0, 0])
//            pipe(pipe_params, horizontal_width_pipe);
//    
//    translate([table_length, pipe_params[1], vertical_pipe_length])
//        rotate([-90, 0, 0])
//            pipe(pipe_params, horizontal_width_pipe);
//
//}
//module table_bottom_frame(){
//    table_3d_corner(0,0,0,180);
//    table_3d_corner(table_length,0,0,270);
//    table_3d_corner(table_length,table_width,0);
//    table_3d_corner(0,table_width,0,90);
//
//    translate([pipe_params[1], 0, vertical_pipe_length])
//        rotate([0, 90, 0])
//            pipe(pipe_params, horizontal_length_pipe);
//    translate([pipe_params[1], table_width, vertical_pipe_length])
//        rotate([0, 90, 0])
//            pipe(pipe_params, horizontal_length_pipe);
//   // 短边水平管道（左右）
//    translate([0, pipe_params[1], vertical_pipe_length])
//        rotate([-90, 0, 0])
//            pipe(pipe_params, horizontal_width_pipe);
//    
//    translate([table_length, pipe_params[1], vertical_pipe_length])
//        rotate([-90, 0, 0])
//            pipe(pipe_params, horizontal_width_pipe);
//}
//
//// 创建桌子框架
//module table_frame() {
//    translate([0,0,top_vertical_pipe_z])
//        table_top_frame();
//
//    table_bottom_frame();
//}
//
//
//// 组装完整的桌子
//module complete_table() {
//    table_frame();
//}
//
//// 渲染完整的桌子
