//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (Loading)
-(void)asynLoadingImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage;

- (void)asynLoadingImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolderImage;

- (void)asynLoadingTonalImageWithUrlString:(NSString *)urlString secondImageUrlString:(NSString *)secondImageUrlString placeHolderImage:(UIImage *)placeHolderImage;

@end