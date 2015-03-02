//
// Created by 郭 輝平 on 3/2/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "RSRSVideoRelatedVideoImageContainView.h"

static CGFloat const kCellCornerRadius = 3.0f;

@implementation RSRSVideoRelatedVideoImageContainView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.cornerRadius = kCellCornerRadius;
}

@end