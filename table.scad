include <table_module.scad>

frame_left();

translate([horizontalPipeLength - pipe,0,0]){
    frame_storage();
}
