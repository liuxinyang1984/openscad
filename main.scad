include <config.scad>
include <lib/pipe.scad>
include <lib/tee.scad>
include <lib/tee3d.scad>
include <lib/fourway3d.scad>
include <lib/fiveway3d.scad>
include <lib/flange3.scad>

standard = "DN15";
// 获取DN15三孔内丝法兰参数
flange_params = get_threaded_flange_params(standard);

// 获取对应的管道参数
pipe_params = get_pipe_params(standard);

// 水平管道
translate([0, 0, 0])
    pipe(pipe_params, 100);

// 三通
translate([100, 0, 0])
    tee3d(pipe_params);

// 从三通向上的垂直管道
translate([100, 0, 0])
    rotate([0, 0, 90])
    pipe(pipe_params, 80);

// 在三通顶部添加法兰
translate([100, 80, 0])
    rotate([0, 0, 90])
    threaded_flange(flange_params);
