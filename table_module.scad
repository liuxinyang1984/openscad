include <config.scad>
include <utils.scad>
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

pipe = pipe_params[1];
halfPipe = pipe_params[1]/2;
flangeHeight = flange_params[4];
threadLenght = pipe_params[3]/2;
pipeLinkHeight = pipe_params[4]/2;


verticalPipeHeight = frame_height - flangeHeight * 2 - threadLenght - pipeLinkHeight; 
// left
verticalPipeLeftBottom = verticalPipeHeight/3*2 - pipe;
verticalPipeLeftTop = verticalPipeHeight/3 - pipe;

// storage
storageHeight = 50;
verticalPipeStorageTop = verticalPipeHeight/3 - pipe;
verticalPipeStorageMiddle = (verticalPipeHeight - storageHeight - verticalPipeStorageTop - pipe)/2 - pipe - halfPipe;

// 横向
horizontalPipeWidth = frame_width - pipe * 4;
// 左
horizontalPipeLeftWidth = horizontalPipeWidth / 2;
// 右
horizontalPipeRightWidth = horizontalPipeWidth / 2 - storage_width;
horizontalPipeStorageWidth = storage_width;

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
    pipe(pipe_params, verticalPipeLeftTop);
}
module vertical_pipe_left_front(){
    union() {
        translate([0,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        difference(){
            translate([0,0,verticalPipeHeight + pipe]){
                pipe_link(pipe_params);
            }
            translate([0,0,frame_height]){
                cylinder(r=50,h=20);
            }
        }
        translate([0,0,verticalPipeHeight]){
            rotate([0,0,180]){
                fourway3d(pipe_params);
            }
        }
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
        translate([0,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        difference(){
            translate([0,0,verticalPipeHeight + pipe]){
                pipe_link(pipe_params);
            }
            translate([0,0,frame_height]){
                cylinder(r=50,h=20);
            }
        }
        translate([0,0,verticalPipeHeight]){
            rotate([0,0,90]){
                fourway3d(pipe_params);
            }
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeLeftTop);
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
        translate([0,0,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            depth_pipe();
        }
        translate([0,0,frame_height - flangeHeight - pipeLinkHeight - pipe_params[4]]){
            depth_pipe();
        }
    }
}

module vertical_pipe_storage_front(){
    union(){
        translate([0,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        difference(){
            translate([0,0,verticalPipeHeight + pipe]){
                pipe_link(pipe_params);
            }
            translate([0,0,frame_height]){
                cylinder(r=50,h=20);
            }
        }
        translate([20,0,verticalPipeHeight - pipeLinkHeight]){
            rotate([0,0,90]){
                fourway3d(pipe_params);
            }
        }
        translate([0,0,flangeHeight + storageHeight + pipe + verticalPipeStorageMiddle + pipe]){
            pipe(pipe_params, verticalPipeStorageMiddle + verticalPipeStorageTop);
        }
        translate([20,0,flangeHeight + storageHeight + pipe + verticalPipeStorageMiddle + halfPipe]){
            rotate([0,0,0]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight + storageHeight + pipe]){
            pipe(pipe_params, verticalPipeStorageMiddle);
        }
        translate([20,0,flangeHeight + storageHeight + halfPipe]){
            rotate([0,0,90]){
                tee(pipe_params);
            }
        }
        translate([0,0,flangeHeight]){
            pipe(pipe_params, storageHeight);
        }
        threaded_flange(flange_params);
    }
}
module frame_storage(){
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
//frame_left();
vertical_pipe_storage_front();
