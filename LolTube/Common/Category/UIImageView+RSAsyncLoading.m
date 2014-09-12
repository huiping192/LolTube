//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+RSAsyncLoading.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (RSAsyncLoading)

- (void)asynLoadingImageWithUrlString:(NSString *)urlString {
    [self sd_setImageWithURL:[NSURL URLWithString:urlString]
                   placeholderImage:[UIImage imageNamed:@"DefaultThumbnail"]];
}

@end