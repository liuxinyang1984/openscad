// shelf/main.scad — 墙书架总装
//
// 依赖：common/standards.scad（管件参数、套丝、对丝、lib 几何模块）
//       shelf/standards.scad（书架派生尺寸）
//       shelf/shelf_config.scad（书架手填原点 / 净空）
//
// 坐标约定：局部 −Z = 世界 −Y（朝房间）；局部 −Y = 世界 +Z（向上）
// 法兰承面贴墙（shelfOriginY）；管件沿 −Y 依次伸出

include <standards.scad>

// 显示开关：右书架 / 左墙书架 / 层板
showShelf = true;
showShelfLeft = true;
showShelfBoards = true;

include <boards.scad>

// -----------------------------------------------------------------------------
// 侧框架基准：最右侧组件（各柱共用）
// 下端堵头 → 立管 → 上前后接头 + 层深管 → 上墙锚
// -----------------------------------------------------------------------------
flangeT   = flangeThicknessMm;      // 法兰盘厚度
couplingL = couplingTotalMm;        // 对丝全长
extra     = fittingHeadExtraMm;     // 中心 → 管端外缘
depthNet  = shelfDepthPipeNetMm;    // 层深直管净长
vertNet   = shelfVerticalPipeNetMm; // 立管净长
stubNet   = shelfStubPipeNetMm;     // 端柱短管净长

backLowerFiveZ   = shelfBackFittingLocalZ;
frontLowerFiveZ  = shelfFrontFittingLocalZ;
upperFiveY       = shelfUpperFittingLocalY;
upperDepthStartZ = backLowerFiveZ - extra;

// 侧框架一柱
module shelf_side_frame() {
    // 后下堵头
    translate([0, -fittingHalfHeadMm, backLowerFiveZ])
        rotate([270, 90, 0])
            cap(pipe_params);
    // 前下堵头
    translate([0, -fittingHalfHeadMm, frontLowerFiveZ])
        rotate([270, 90, 0])
            cap(pipe_params);

    // 后立管
    translate([0, -extra, backLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, vertNet);
    // 前立管
    translate([0, -extra, frontLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, vertNet);

    // 后上四通
    translate([0, upperFiveY, backLowerFiveZ])
        fourway(pipe_params);
    // 前上三通：支口朝墙（局部 +Z / 向里），接层深管
    translate([0, upperFiveY, frontLowerFiveZ])
        rotate([90, 0, 0])
            tee(pipe_params);
    // 上层深管
    translate([0, upperFiveY, upperDepthStartZ - depthNet])
        pipe(pipe_params, depthNet);

    // 上墙锚：法兰 + 对丝
    translate([0, upperFiveY, 0]) {
        threaded_flange(flange_params);
        translate([0, 0, -(flangeT + couplingL / 2)])
            pipe_link(pipe_params, couplingL, couplingHexMm);
    }

    // 后上短管 + 堵头
    translate([0, -extra - vertNet - fittingHalfHeadMm, backLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, stubNet);
    translate([0, -extra - vertNet - fittingHalfHeadMm - stubNet, backLowerFiveZ])
        rotate([90, 0, 0])
            cap(pipe_params);
    // 前上短管 + 堵头
    translate([0, -extra - vertNet - fittingHalfHeadMm, frontLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, stubNet);
    translate([0, -extra - vertNet - fittingHalfHeadMm - stubNet, frontLowerFiveZ])
        rotate([90, 0, 0])
            cap(pipe_params);
}

module shelf_side_frames_at(post_xs) {
    for (px = post_xs)
        translate([px, shelfOriginY, shelfFrameOriginZ])
            rotate([-90, 0, 0])
                shelf_side_frame();
}

module shelf_bottom_side_frame() {
    shelf_side_frames_at([shelfLeftPostX, shelfMidPostX, shelfRightPostX]);
}

module shelf_left_side_frame() {
    // 左墙两层 1200：左 / 中 / 右三柱（中柱居中）
    shelf_side_frames_at([
        shelfLeftLeftPostX, shelfLeftMidPostX, shelfLeftRightPostX
    ]);
}

// -----------------------------------------------------------------------------
// 总装入口
// -----------------------------------------------------------------------------

module shelf_main() {
    if (showShelf)
        shelf_bottom_side_frame();
    if (showShelfLeft)
        shelf_left_side_frame();
    if (showShelfBoards)
        shelf_boards();
}
