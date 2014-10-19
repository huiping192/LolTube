//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+Loading.h"
#import "UIImageView+WebCache.h"
#import "UIImage+RSImageEffect.h"


@implementation UIImageView (Loading)
- (void)asynLoadingImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage {
    [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self sd_setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                [self sd_setImageWithURL:[NSURL URLWithString:secondImageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if(!image){
                        self.image = placeHolderImage;
                    }
                }];
            }
        }];
    }               completion:nil];
}

- (void)asynLoadingImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolderImage {
    [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage];
}

- (void)asynLoadingTonalImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
        if (!image) {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:secondImageUrlString]]];
        }
        UIImage *tonalImage = [image blackAndWhiteImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self setImage:tonalImage];
            }               completion:nil];
        });
    });
}

@end