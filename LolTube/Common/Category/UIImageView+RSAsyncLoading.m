//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+RSAsyncLoading.h"


@implementation UIImageView (RSAsyncLoading)

- (void)asynLoadingImageWithUrlString:(NSString *)urlString {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *image = [UIImage imageWithData:imageData];

        dispatch_sync(dispatch_get_main_queue(), ^{
            if (image) {
                [UIView transitionWithView:weakSelf duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    weakSelf.image = image;
                }               completion:nil];
            }
        });
    });
}

@end