//
// Created by 郭 輝平 on 11/27/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListCollectionViewLayout.h"

static CGFloat const kCellMinWidth = 280.0f;
static CGFloat const kCellRatio = 180.0f / 320.0f;


static CGFloat const kCellMarginPhone = 5.0f;
static CGFloat const kCellMarginPad = 10.0f;

@implementation RSVideoListCollectionViewLayout {

}

- (void)prepareLayout {
    [super prepareLayout];

    CGFloat cellMargin = [self p_cellMargin];
    [self setSectionInset:UIEdgeInsetsMake(cellMargin, cellMargin, cellMargin, cellMargin)];
}

- (CGSize)itemSize {
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    int cellCount = (int) (collectionWidth / kCellMinWidth);

    CGFloat cellWidth = (collectionWidth - [self p_cellMargin] * (cellCount + 1)) / cellCount;
    return CGSizeMake(cellWidth, cellWidth * kCellRatio);
}

- (CGFloat)minimumLineSpacing {
    return [self p_cellMargin];
}

- (CGFloat)p_cellMargin {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? kCellMarginPhone : kCellMarginPad;
}


@end