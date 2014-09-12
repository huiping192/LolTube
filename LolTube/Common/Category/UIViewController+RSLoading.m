//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+RSLoading.h"
#import "AMTumblrHud.h"
#import "RSAppDelegate.h"

static void const *kViewControllerLoadingViewKey = @"kViewControllerLoadingViewKey";

@implementation UIViewController (RSLoading)


-(void)configureLoadingView {
    AMTumblrHud *tumblrHUD = [[AMTumblrHud alloc] init];
    tumblrHUD.translatesAutoresizingMaskIntoConstraints = NO;
    //tumblrHUD.hudColor = [UIColor colorWithRed:90.0f/255.0f green:200.0f/255.0f blue:250.0f/255.0f alpha:1.0];

    RSAppDelegate *appDelegate =  (RSAppDelegate *)[[UIApplication sharedApplication] delegate];
    tumblrHUD.hudColor = [appDelegate.window tintColor];
    [self.view addSubview:tumblrHUD];

    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:tumblrHUD attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:tumblrHUD attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];

    NSArray *widthConstraints =
            [NSLayoutConstraint constraintsWithVisualFormat:@"[tumblrHUD(==width)]"
                                                    options:0 metrics:@{@"width":@(55)} views:NSDictionaryOfVariableBindings(tumblrHUD)];

    NSArray *heightConstraints =
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tumblrHUD(==height)]"
                                                    options:0 metrics:@{@"height":@(20)} views:NSDictionaryOfVariableBindings(tumblrHUD)];

    [self.view addConstraints:@[centerX,centerY]];
    [self.view addConstraints:widthConstraints];
    [self.view addConstraints:heightConstraints];

    [self.view layoutIfNeeded];

    [self p_setLoadingView:tumblrHUD];
}

-(AMTumblrHud *)loadingView {
    return objc_getAssociatedObject(self,kViewControllerLoadingViewKey);
}

-(void)p_setLoadingView:(AMTumblrHud *)loadingView{
    objc_setAssociatedObject(self, kViewControllerLoadingViewKey, loadingView, OBJC_ASSOCIATION_ASSIGN);
}

@end