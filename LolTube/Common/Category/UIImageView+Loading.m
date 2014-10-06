//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+Loading.h"
#import "UIImageView+WebCache.h"


@implementation UIImageView (Loading)
- (void)asynLoadingImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage {

    [self sd_setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            [self sd_setImageWithURL:[NSURL URLWithString:secondImageUrlString] placeholderImage:placeHolderImage];
        }
    }];
}

- (void)asynLoadingImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolderImage {
    [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage];
}

@end