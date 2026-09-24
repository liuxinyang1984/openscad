// shelf/main.scad — 墙书架总装
//
// 依赖：common/standards.scad（管件参数、套丝、对丝、lib 几何模块）
//       shelf/standards.scad（书架派生尺寸）
//       shelf/shelf_config.scad（书架手填原点 / 净空）
//
// 坐标约定：局部 −Z = 世界 −Y（朝房间）；局部 −Y = 世界 +Z（向上）
// 法兰承面贴墙（shelfOriginY）；管件沿 −Y 依次伸出

include <standards.scad>
include <boards.scad>

// 显示开关：书架整体 / 层板
showShelf = false;
showShelfBoards = false;

// -----------------------------------------------------------------------------
// 底部侧框架（YZ 平面一格）
// 墙面法兰 → 对丝 → 下前后五通 + 下层深管 → 立管 → 上前后五通 + 上层深管
// 上层侧框架复用时不带「下层深管」与墙锚（另模块再写）
// 局部：原点 = 法兰承面中心
// -----------------------------------------------------------------------------
flangeT   = flangeThicknessMm;      // 法兰盘厚度
couplingL = couplingTotalMm;        // 对丝全长
extra     = fittingHeadExtraMm;     // 中心 → 管端外缘
depthNet  = shelfDepthPipeNetMm;    // 层深直管净长（上下层同）
vertNet   = shelfVerticalPipeNetMm; // 立管净长
stubNet   = shelfStubPipeNetMm;     // 端柱短管净长

// 后/前下接头、上接头（与 standards 派生一致）
backLowerFiveZ   = shelfBackFittingLocalZ;
frontLowerFiveZ  = shelfFrontFittingLocalZ;
upperFiveY       = shelfUpperFittingLocalY;
lowerDepthStartZ = backLowerFiveZ - extra;
upperDepthStartZ = backLowerFiveZ - extra;

module base(){
    // 基础框架
    union() {
        // --- 墙锚 ---
        threaded_flange(flange_params);

        translate([0, 0, -(flangeT + couplingL / 2)])
            pipe_link(pipe_params, couplingL, couplingHexMm);

        // --- 下层：后五通 + 层深管 + 前五通 ---
        translate([0, 0, backLowerFiveZ])
            tee(pipe_params);
        translate([0, 0, frontLowerFiveZ])
            elbow(pipe_params);
    }
}

module left_side(){
    base();
    translate([0,0,upperDepthStartZ - depthNet])
        pipe(pipe_params, depthNet);
    // 前短管 + 堵头
    translate([0, -fittingHalfHeadMm, frontLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, stubNet);
    translate([0, -fittingHalfHeadMm - stubNet, frontLowerFiveZ])
        rotate([90, 0, 0])
            cap(pipe_params);
    // 后短管 + 堵头
    translate([0, -fittingHalfHeadMm, backLowerFiveZ])
        rotate([90, 0, 0])
            pipe(pipe_params, stubNet);
    translate([0, -fittingHalfHeadMm - stubNet, backLowerFiveZ])
        rotate([90, 0, 0])
            cap(pipe_params);
}
module right_side(){

    // 后下接头
    translate([0, - fittingHalfHeadMm, backLowerFiveZ]){
        rotate([270,90,0]){
            cap(pipe_params);
        }
    }
    // 前下接头
    translate([0,  - fittingHalfHeadMm, frontLowerFiveZ]){
        rotate([270,90,0]){
            cap(pipe_params);
        }
    }

    // 后下管
    translate([0, -extra, backLowerFiveZ]){
        rotate([90, 0, 0]){
            pipe(pipe_params, vertNet);
        }
    }
    // 前下管
    translate([0, -extra, frontLowerFiveZ]){
        rotate([90, 0, 0]){
            pipe(pipe_params, vertNet);
        }
    }

    //后上接头
    translate([0, upperFiveY, backLowerFiveZ]){
        fourway(pipe_params);
    }

    // 前上接头
    translate([0, upperFiveY, frontLowerFiveZ]){
        rotate([-90,0,0]){
            tee(pipe_params);
        }
    }
    // 上纵管
    translate([0, upperFiveY, upperDepthStartZ - depthNet]){
        pipe(pipe_params, depthNet);
    }
    // 上部锚点
    translate([0,upperFiveY,0]){
        union (){
        threaded_flange(flange_params);

        translate([0, 0, -(flangeT + couplingL / 2)])
            pipe_link(pipe_params, couplingL, couplingHexMm);
        }
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
module shelf_bottom_side_frame() {
    translate([shelfLeftPostX, shelfOriginY, shelfFrameOriginZ])
        rotate([-90, 0, 0])
            left_side();

    translate([shelfMidPostX, shelfOriginY, shelfFrameOriginZ])
        rotate([-90, 0, 0])
            right_side();

    translate([shelfRightPostX, shelfOriginY, shelfFrameOriginZ])
        rotate([-90, 0, 0])
            right_side();
}

// -----------------------------------------------------------------------------
// 总装入口
// -----------------------------------------------------------------------------

module shelf_main() {
    if (showShelf)
        shelf_bottom_side_frame();
    if (showShelfBoards)
        shelf_boards();
}
