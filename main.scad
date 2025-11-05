use <config.scad>
use <lib/tee.scad>
use <tee3d.scad>

params = get_pipe_params("DN15");

//tee(params);
tee3d(params);
