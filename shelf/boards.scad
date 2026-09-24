// shelf/boards.scad — 墙书架层板（视觉）
//
// 板底压在横管外径顶上；立管孔边距板边 ≥ shelfBoardHoleEdgeClearMm

module shelf_board_2d(size_xy, posts) {
    difference() {
        square(size_xy);
        for (p = posts)
            translate([p[0], p[1]])
                circle(d = shelfBoardHoleD);
    }
}

module shelf_board_rect(size_xy, posts) {
    linear_extrude(height = shelfThicknessMm)
        shelf_board_2d(size_xy, posts);
}

// 世界放置：原点 = 板后左角、板底；板内 +Y 朝房间（世界 −Y）
module shelf_board_place(origin_xyz, size_xy, posts) {
    translate(origin_xyz)
        mirror([0, 1, 0])
            shelf_board_rect(size_xy, posts);
}

module shelf_boards() {
    m  = shelfBoardSideMarginMm;
    dm = shelfBoardDepthMarginMm;
    d  = shelfBoardDepthMm;

    lower_posts = [
        [m, dm],
        [shelfMidPostX - shelfLowerBoardLeftX, dm],
        [shelfLowerBoardLenMm - m, dm],
        [m, d - dm],
        [shelfMidPostX - shelfLowerBoardLeftX, d - dm],
        [shelfLowerBoardLenMm - m, d - dm]
    ];
    upper_posts = [
        [m, dm],
        [shelfUpperBoardLenMm - m, dm],
        [m, d - dm],
        [shelfUpperBoardLenMm - m, d - dm]
    ];

    col = [0.62, 0.45, 0.28, 0.65];

    color(col)
        shelf_board_place(
            [shelfLowerBoardLeftX, shelfBoardBackY, shelfLowerBoardBottomZ],
            [shelfLowerBoardLenMm, d],
            lower_posts
        );

    color(col)
        shelf_board_place(
            [shelfUpperBoardLeftX, shelfBoardBackY, shelfUpperBoardBottomZ],
            [shelfUpperBoardLenMm, d],
            upper_posts
        );
}
