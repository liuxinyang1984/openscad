// 单独预览：DN15 对丝（pipe_link），与桌架里活接为同一几何
include <config.scad>
include <lib/pipe_link.scad>

standard = "DN15";
pipe_params = get_pipe_params(standard);

// 斜一点便于看两端螺纹与六角中段
rotate([35, -28, 0])
    pipe_link(pipe_params, 40, 10);
