//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+Loading.h"
#import "UIImageView+WebCache.h"
#import "UIImage+RSImageEffect.h"


@implementation UIImageView (Loading)
- (void)asynLoadingImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage {
    __weak typeof(self) weakSelf = self;

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image) {
            [manager downloadImageWithURL:[NSURL URLWithString:secondImageUrlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!image) {
                    [weakSelf p_setImage:[UIImage imageNamed:@"DefaultThumbnail"]];
                    return;
                }
                [weakSelf p_setImage:image];
            }];
            return;
        }

        [weakSelf p_setImage:image];
    }];
}

- (void)p_setImage:(UIImage *)image {
    self.alpha = 0.0;
    [UIView transitionWithView:self
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self setImage:image];
                        self.alpha = 1.0;
                    } completion:NULL];
}

- (void)asynLoadingImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolderImage {
    if (!urlString) {
        return;
    }
    [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage];
}

- (void)asynLoadingTonalImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage {
    __weak typeof(self) weakSelf = self;


    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image) {
            [manager downloadImageWithURL:[NSURL URLWithString:secondImageUrlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!image) {
                    [weakSelf p_setImage:[UIImage imageNamed:@"DefaultThumbnail"]];
                    return;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *blackAndWhiteImage = [image blackAndWhiteImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf p_setImage:blackAndWhiteImage];
                    });
                });
            }];
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *blackAndWhiteImage = [image blackAndWhiteImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf p_setImage:blackAndWhiteImage];
            });
        });
    }];
}

@end