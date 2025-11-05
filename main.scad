include <config.scad>
include <lib/tee.scad>
include <lib/tee3d.scad>

params = get_pipe_params("DN15");

//tee(params);
tee3d(params);
