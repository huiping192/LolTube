//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSNavigationController.h"
#import "RSVideoListViewController.h"
#import "RSVideoDetailAnimator.h"
#import "RSVideoDetailViewController.h"

@interface RSNavigationController()<UINavigationControllerDelegate>

@end

@implementation RSNavigationController {

}


#pragma mark - UINavigationControllerDelegate\


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
       self.delegate = self;
    }

    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (([fromVC isKindOfClass:[RSVideoListViewController class]] && [toVC isKindOfClass:[RSVideoDetailViewController class]]) || ([fromVC isKindOfClass:[RSVideoDetailViewController class]] && [toVC isKindOfClass:[RSVideoListViewController class]])) {
        return [[RSVideoDetailAnimator alloc] initWithOperation:operation];
    }

    return nil;
}


@end