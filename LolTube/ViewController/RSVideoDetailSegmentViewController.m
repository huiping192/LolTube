//
// Created by 郭 輝平 on 12/20/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailSegmentViewController.h"
#import "RSVideoInfoViewController.h"
#import "RSVideoRelatedVideosViewController.h"

@interface RSVideoDetailSegmentViewController ()

@property(nonatomic, weak) IBOutlet UISegmentedControl *videoSegmentedControl;
@property(nonatomic, weak) IBOutlet UIView *segmentedContainerView;

@property(nonatomic, strong) RSVideoInfoViewController *infoViewController;
@property(nonatomic, strong) RSVideoRelatedVideosViewController *relatedVideosViewController;

@end

@implementation RSVideoDetailSegmentViewController {

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"infoEmbed"]) {
        RSVideoInfoViewController *infoViewController = segue.destinationViewController;
        infoViewController.videoId = self.videoId;
        self.infoViewController = infoViewController;
    }
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    UITraitCollection *currentTraitCollection = self.traitCollection;

    if ([currentTraitCollection containsTraitsInCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular]]) {
        if (self.videoSegmentedControl.selectedSegmentIndex == 1) {
            [self swapFromViewController:self.relatedVideosViewController toViewController:self.infoViewController];
            self.videoSegmentedControl.selectedSegmentIndex = 0;
        }

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    self.infoViewController = nil;
    self.relatedVideosViewController = nil;
}


- (IBAction)videoDetailSegmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            if (!self.infoViewController) {
                self.infoViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoInfo"];
                self.infoViewController.videoId = self.videoId;
            }
            [self swapFromViewController:self.relatedVideosViewController toViewController:self.infoViewController];
            break;
        }
        case 1: {
            if (!self.relatedVideosViewController) {
                self.relatedVideosViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"relatedVideos"];
                self.relatedVideosViewController.videoId = self.videoId;
            }
            [self swapFromViewController:self.infoViewController toViewController:self.relatedVideosViewController];
            break;
        }
    }
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        [self addConstraintsForViewController:toViewController];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}

- (void)addConstraintsForViewController:(UIViewController *)viewController {
    UIView *containerView = self.segmentedContainerView;
    UIView *childView = viewController.view;
    [childView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [containerView addSubview:childView];

    NSDictionary *views = NSDictionaryOfVariableBindings(childView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
}

@end