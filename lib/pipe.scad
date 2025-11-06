// lib/pipe.scad
module pipe(params, len=100,fn=16) {
    dn_name    = params[0];
    outer_d    = params[2];
    inner_d    = params[3];
    length     = len;

    name = str("Pipe_", dn_name, "_", length);

    echo(str("[pipe] ", name, " 外径=", outer_d, " 内径=", inner_d, " 长=", length));

    difference() {
        cylinder(d = outer_d, h = length, $fn = fn);
        translate([0, 0, -1])
            cylinder(d = inner_d, h = length + 2, $fn = fn);
    }
}

