//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImageView+Loading.h"
#import "UIImageView+WebCache.h"
#import "UIImage+RSImageEffect.h"


@implementation UIImageView (Loading)

+ (NSOperation *)asynLoadingImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString needBlackWhiteEffect:(BOOL)needBlackWhiteEffect success:(void (^)(UIImage *image))success{
    NSBlockOperation *imageOperation = [NSBlockOperation blockOperationWithBlock:^{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if(imageOperation.isCancelled){
                return;
            }
            if (!image) {
                [manager downloadImageWithURL:[NSURL URLWithString:secondImageUrlString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if(imageOperation.isCancelled){
                        return;
                    }
                    if (!image) {
                        image = [UIImage imageNamed:@"DefaultThumbnail"];
                    }
                    if(needBlackWhiteEffect){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *blackAndWhiteImage = [image blackAndWhiteImage];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(success){
                                    success(blackAndWhiteImage);
                                }
                            });
                        });
                    } else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(success){
                                success(image);
                            }
                        });
                    }
                }];
                return;
            }
            if(needBlackWhiteEffect){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *blackAndWhiteImage = [image blackAndWhiteImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success){
                            success(blackAndWhiteImage);
                        }
                    });
                });
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(success){
                        success(image);
                    }
                });
            }
        }];
    }];

    return imageOperation;
}

- (void)asynLoadingImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolderImage {
    if (!urlString) {
        return;
    }
    [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage];
}

@end