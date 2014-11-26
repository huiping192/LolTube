//
// Created by 郭 輝平 on 11/27/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListCollectionViewLayout.h"

static CGFloat const kCellMinWidth = 280.0f;
static CGFloat const kCellRatio = 180.0f / 320.0f;

@implementation RSVideoListCollectionViewLayout {

}

- (CGSize)itemSize {
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    int cellCount = (int) (collectionWidth / kCellMinWidth);

    CGFloat cellWidth = (collectionWidth - 5 * (cellCount + 1)) / cellCount;

    return CGSizeMake(cellWidth, cellWidth * kCellRatio);
}

- (UIEdgeInsets)sectionInset {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


@end