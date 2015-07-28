//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSNavigationController.h"
#import "RSVideoListViewController.h"
#import "RSVideoDetailAnimator.h"
#import "RSVideoDetailViewController.h"
#import "RSEnvironment.h"
#import "LolTube-Swift.h"
#import "UINavigationController+Block.h"
#import <objc/runtime.h>

static char kNavigationBarKey;

@interface RSNavigationController () <UINavigationControllerDelegate>

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

- (void)restoreUserActivityState:(NSUserActivity *)activity {
    [super restoreUserActivityState:activity];

    if ([activity.activityType isEqualToString:kUserActivityTypeVideoDetail] && [activity.userInfo[kHandOffVersionKey] isEqualToString:kHandOffVersion]) {
        RSVideoDetailViewController *videoDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kViewControllerIdVideoDetail];
        videoDetailViewController.videoId = activity.userInfo[kUserActivityVideoDetailUserInfoKeyVideoId];
        videoDetailViewController.initialPlaybackTime = [((NSNumber *) activity.userInfo[kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime]) floatValue];

        [self pushViewController:videoDetailViewController animated:YES];
    }
}


- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated {
    UIViewController *topVC = [self.viewControllers lastObject];
    if ([viewController isKindOfClass:[ChannelDetailViewController class]]) {
        
        if([topVC isKindOfClass:[SearchViewController class]]){
            [[self.navigationBar valueForKey:@"_backgroundView"] setAlpha:0.0];

            [super pushViewController:viewController animated:animated];
            return;
        }
        
        if (topVC.navigationController.navigationBar &&
            !topVC.navigationController.navigationBarHidden) {
            // add navigation bar
            CGRect rect = self.navigationBar.frame;
            UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:rect];
            rect.origin = CGPointMake(0, -20);
            rect.size.height += 20;
            [[bar valueForKey:@"_backgroundView"] setFrame:rect];
            [bar setShadowImage:[self.navigationBar.shadowImage copy]];
            [topVC.view addSubview:bar];
            [[self.navigationBar valueForKey:@"_backgroundView"] setAlpha:0];
            objc_setAssociatedObject(topVC, &kNavigationBarKey, bar,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *topVC = [self.viewControllers lastObject];
    if ([topVC isKindOfClass:[ChannelDetailViewController class]]) {
        if ([self.viewControllers count] >= 2) {
            
            UIViewController *toVC = [self.viewControllers objectAtIndex:[self.viewControllers count] - 2];
            UINavigationBar *bar = objc_getAssociatedObject(toVC,&kNavigationBarKey);

            if([toVC isKindOfClass:[SearchViewController class]]){
                [[self.navigationBar valueForKey:@"_backgroundView"]
                 setAlpha:1];
                
                return [super popViewControllerAnimated:animated];;
            }
            
            
            [super popViewControllerAnimated:animated
                                onCompletion:^{
                                    [self.navigationBar setShadowImage:nil];
                                    [self.navigationBar
                                     setBackgroundImage:nil
                                     forBarMetrics:UIBarMetricsDefault];
                                    [[self.navigationBar valueForKey:@"_backgroundView"]
                                     setAlpha:1];
                                    [bar removeFromSuperview];
                                }];
            return topVC;
        }
    }
    return [super popViewControllerAnimated:animated];
}

@end