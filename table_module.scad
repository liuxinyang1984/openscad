include <config.scad>
include <utils.scad>
standard = "DN15";
// 获取参数
flange_params = get_threaded_flange_params(standard);
pipe_params = get_pipe_params(standard);

// 组件尺寸
pipe = pipe_params[1];
halfPipe = pipe_params[1]/2;
flangeHeight = flange_params[4];
threadLenght = pipe_params[3]/2;
pipeLinkHeight = pipe_params[4]/2;

// 实际尺寸
table_width = 700;
table_length = 2000;
table_height = 750; 


//框架尺寸
frameWidth = table_width - 50 * 2;
frameHeight = table_height;
frameLength = table_length - 50 *2;
verticalPipeHeight = frame_height - topSetHeight; 
verticalPipeTop = 120 ;
topSetHeight = flangeHeight * 2 + threadLenght + pipeLinkHeight + pipe;

// 柜子尺寸
storageHeight = 600;
storageWidth  = 400;

// 





depthLength = frame_width - pipe * 2;
// left
verticalPipeLeftBottom = verticalPipeHeight - verticalPipeTop - pipe;

// storage
storageFootHeight = 50;
verticalPipeStorage= verticalPipeHeight - storageFootHeight - pipe * 2;
verticalPipeStorageMiddle = (verticalPipeStorage - verticalPipeTop);

// 横向
horizontalPipeLength = frame_length - pipe * 4;
// 左
horizontalPipeLeftLength = horizontalPipeLength / 2;
// 右
horizontalPipeRightLength = horizontalPipeLength / 2 - storage_length;
horizontalPipeStorageLength = storage_length;

module depth_pipe(){
    pipeWidth = frame_width - pipe * 2;
    echo("纵向管长度:",pipeWidth);
    rotate([-90,0,0]){
        pipe(pipe_params, pipeWidth);
    }
}
module horizontal_pipe_left(){
    pipe(pipe_params, horizontalPipeLeftWidth);
}
module horizontal_pipe_right(){
    pipe(pipe_params, horizontalPipeRightWidth);
}
module left_vertical_bottom(){
    pipe(pipe_params, verticalPipeLeftBottom);
}
module left_vertical_top(){
    pipe(pipe_params, verticalPipeTop);
}
module top_set(){
    union() {
        translate([0,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        difference(){
            translate([0,0,verticalPipeHeight + pipe * 2]){
                pipe_link(pipe_params);
            }
            translate([0,0,frame_height]){
                cylinder(r=50,h=20);
            }
        }
        translate([0,0,verticalPipeHeight + pipe]){
            rotate([0,0,180]){
                fourway3d(pipe_params);
            }
        }
    }
}
module vertical_pipe_left_front(){
        union(){
            top_set();;
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            left_vertical_top();
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight]){
            left_vertical_bottom();
        }
        threaded_flange(flange_params);
    }
}
module vertical_pipe_left_backend(){
    union() {
        rotate([0,0,-90]){
            top_set();;
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeTop);
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            rotate([0,0,180]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight]){
            pipe(pipe_params, verticalPipeLeftBottom);
        }
        threaded_flange(flange_params);
    }
}
module frame_left(){
    union(){
        translate([0,frame_width - pipe,0]){
            vertical_pipe_left_backend();
        }
        vertical_pipe_left_front();
        // 上管
        translate([0,halfPipe,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            depth_pipe();
        }
        // 下管
        translate([0,halfPipe,frame_height - flangeHeight - pipeLinkHeight - pipe_params[4]]){
            depth_pipe();
        }
    }
}

module vertical_pipe_storage_right_front(){
    union(){
        rotate([0,0,90]){
            top_set();
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeTop);
        }
        translate([0,0,flangeHeight + storageFootHeight + pipe + verticalPipeStorageMiddle + halfPipe]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight + storageFootHeight + pipe]){
            pipe(pipe_params, verticalPipeStorageMiddle);
        }
        translate([0,0,flangeHeight + storageFootHeight + halfPipe]){
            rotate([0,0,90]){
                tee(pipe_params);
            }
        }

        translate([0,0,flangeHeight]){
            pipe(pipe_params, storageFootHeight);
        }
        threaded_flange(flange_params);
    }
}
module vertical_pipe_storage_left_front(){
    union(){
        rotate([0,0,0]){
            top_set();
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeTop);
        }
        translate([0,0,flangeHeight + storageFootHeight + pipe + verticalPipeStorageMiddle + halfPipe]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }

        translate([20,0,frame_height - topSetHeight + halfPipe]){
            rotate([180,0,0]){
                pipe(pipe_params,frame_height - topSetHeight - );
            }
        }
        translate([0,0,flangeHeight + storageFootHeight + pipe + storage_height + halfPipe ]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([20,0,flangeHeight + storageFootHeight + pipe]){
            pipe(pipe_params, storage_height);
        }
        translate([0,0,flangeHeight + storageFootHeight + halfPipe]){
            rotate([0,0,270]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight]){
            pipe(pipe_params, storageFootHeight);
        }
        threaded_flange(flange_params);
    }
}
module vertical_pipe_storage_left_backend(){
    rotate([0,0,180]){
        vertical_pipe_storage_right_front();
    }
}
module vertical_pipe_storage_right_backend(){
    rotate([0,0,180]){
        vertical_pipe_storage_left_front();
    }
}
module horizontal_pipe_storage(){
    rotate([0,90,0]){
        pipe(pipe_params,storage_length);
    }
}

module frame_storage(){
    // 左前
    vertical_pipe_storage_left_front();
    // 右前
    translate([storage_length + pipe,0,0]){
        vertical_pipe_storage_right_front();
    }
    // 左后
    translate([0,depthLength + pipe,0]){
        vertical_pipe_storage_left_backend();
    }
    // 右后
    translate([storage_length + pipe,depthLength + pipe,0]){
        vertical_pipe_storage_right_backend();
    }

    // 前横上
    translate([halfPipe,0,flangeHeight + storageFootHeight + halfPipe]){
        horizontal_pipe_storage();
    }
    // 前横下
    translate([halfPipe,0,frame_height - topSetHeight + pipe]){
        horizontal_pipe_storage();
    }
    // 后横上
    translate([halfPipe,depthLength + pipe,frame_height - topSetHeight + pipe]){
        horizontal_pipe_storage();
    }
    // 后横下
    translate([halfPipe,depthLength + pipe,flangeHeight + storageFootHeight + halfPipe]){
        horizontal_pipe_storage();
    }

    // 左纵
    translate([0,halfPipe,verticalPipeHeight - verticalPipeTop]){
        depth_pipe();
    }
    // 右纵
    translate([storage_length + pipe,halfPipe,verticalPipeHeight - verticalPipeTop]){
        depth_pipe();
    }
}
module test(){
    translate([20,20,0]){
        cube([5,5,frame_height]);
    }
    translate([20,0,20]){
        rotate([-90,0,0]){
            cube([5,5,frame_width]);
        }
    }
}

test();
//depth_pipe();
//frame_storage();
