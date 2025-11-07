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


module vertical_pipe_left_front(){
    pipeHeight = frame_height - flangeHeight * 2 - threadLenght; 
    verticalPipeLeftBottom = pipeHeight/3*2 - pipe;
    verticalPipeLeftTop = pipeHeight/3 - pipe;
    union() {
        translate([0,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        translate([0,0,pipeHeight]){
            rotate([0,0,180]){
                fourway3d(pipe_params);
            }
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeLeftTop);
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            tee(pipe_params);
        }
        translate([0,0,flangeHeight]){
            pipe(pipe_params, verticalPipeLeftBottom);
        }
        threaded_flange(flange_params);
    }
}
module vertical_pipe_right_front(){
    pipeHeight = frame_height - flangeHeight * 2 - threadLenght; 
    verticalPipeLeftBottom = pipeHeight/3*2 - pipe;
    verticalPipeLeftTop = pipeHeight/3 - pipe;
    union() {
        translate([50,0,frame_height]){
            rotate([0,180,0]){
                threaded_flange(flange_params);
            }
        }
        translate([0,0,pipeHeight + 50]){
            pipe_link(pipe_params);
        }
        translate([0,0,pipeHeight]){
            rotate([0,0,180]){
                fourway3d(pipe_params);
            }
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + pipe]){
            pipe(pipe_params, verticalPipeLeftTop);
        }
        translate([0,0,flangeHeight + verticalPipeLeftBottom + halfPipe]){
            tee(pipe_params);
        }
        translate([0,0,flangeHeight]){
            pipe(pipe_params, verticalPipeLeftBottom);
        }
        threaded_flange(flange_params);
    }
}
module test(){
    translate([20,20,0]){
        cube([5,5,frame_height]);
    }
}

test();
vertical_pipe_right_front();
