//
// Created by 郭 輝平 on 9/14/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSNavigationController.h"
#import "RSVideoDetailViewController.h"
#import "RSEnvironment.h"
#import "LolTube-Swift.h"

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


@end