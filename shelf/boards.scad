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

// 一层板：board_left_x / board_len / 柱心世界 X 列表
module shelf_board_layer(board_left_x, board_len, post_xs, board_bottom_z) {
    m  = shelfBoardSideMarginMm;
    dm = shelfBoardDepthMarginMm;
    d  = shelfBoardDepthMm;
    posts = [
        for (px = post_xs)
            for (py = [dm, d - dm])
                [px - board_left_x, py]
    ];
    shelf_board_place(
        [board_left_x, shelfBoardBackY, board_bottom_z],
        [board_len, d],
        posts
    );
}

module shelf_boards_right() {
    col = [0.62, 0.45, 0.28, 0.65];
    post_lower = [shelfLeftPostX, shelfMidPostX, shelfRightPostX];
    post_upper = [shelfMidPostX, shelfRightPostX];

    color(col) {
        shelf_board_layer(
            shelfLowerBoardLeftX, shelfLowerBoardLenMm, post_lower,
            shelfLowerBoardBottomZ
        );
        shelf_board_layer(
            shelfUpperBoardLeftX, shelfUpperBoardLenMm, post_upper,
            shelfUpperBoardBottomZ
        );
    }
}

// 左墙：上下层同长，三柱（中柱居中）
module shelf_boards_left() {
    col = [0.55, 0.40, 0.28, 0.65];
    posts = [shelfLeftLeftPostX, shelfLeftMidPostX, shelfLeftRightPostX];

    color(col) {
        shelf_board_layer(
            shelfLeftBoardLeftX, shelfLeftBoardLenMm, posts,
            shelfLowerBoardBottomZ
        );
        shelf_board_layer(
            shelfLeftBoardLeftX, shelfLeftBoardLenMm, posts,
            shelfUpperBoardBottomZ
        );
    }
}

module shelf_boards() {
    shelf_boards_right();
    if (showShelfLeft)
        shelf_boards_left();
}
