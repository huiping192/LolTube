//
// Created by 郭 輝平 on 12/20/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailSegmentViewController.h"
#import "RSVideoInfoViewController.h"
#import "RSVideoRelatedVideosViewController.h"
#import "RSVideoDetailSegmentViewModel.h"
#import "UIImageView+Loading.h"
#import "LolTube-Swift.h"

@interface RSVideoDetailSegmentViewController ()

@property(nonatomic, weak) IBOutlet UISegmentedControl *videoSegmentedControl;
@property(nonatomic, weak) IBOutlet UIView *segmentedContainerView;

@property(nonatomic, weak) IBOutlet UILabel *channelTitleLabel;
@property(nonatomic, weak) IBOutlet UIButton *channelRegisterButton;
@property(nonatomic, weak) IBOutlet UILabel *subscriberCountLabel;
@property(nonatomic, weak) IBOutlet UIImageView *channelThumbnailImageView;

@property(nonatomic, strong) RSVideoInfoViewController *infoViewController;
@property(nonatomic, strong) RSVideoRelatedVideosViewController *relatedVideosViewController;

@property(nonatomic, strong) RSVideoDetailSegmentViewModel *viewModel;
@property(nonatomic, strong) NSOperationQueue *imageLoadingOperationQueue;

@end

@implementation RSVideoDetailSegmentViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageLoadingOperationQueue = [[NSOperationQueue alloc] init];

    [self p_configureViews];
}

- (void)updateWithChannelId:(NSString *)channelId channelTitle:(NSString *)channelTitle{
    self.channelTitleLabel.text = channelTitle;

    self.viewModel = [[RSVideoDetailSegmentViewModel alloc] initWithChannelId:channelId];
    __weak typeof(self) weakSelf = self;
    [self.viewModel updateWithSuccess:^{
        weakSelf.subscriberCountLabel.text = weakSelf.viewModel.subscriberCount;

        NSOperation *imageOperation = [UIImageView asynLoadingImageWithUrlString:weakSelf.viewModel.channelThumbnailImageUrl secondImageUrlString:nil needBlackWhiteEffect:NO success:^(UIImage *image) {
            weakSelf.channelThumbnailImageView.image = image;
        }];
        [weakSelf.imageLoadingOperationQueue addOperation:imageOperation];

        NSString *title = weakSelf.viewModel.isSubscribed? NSLocalizedString(@"ChannelSubscribed", nil) : NSLocalizedString(@"ChannelUnsubscribe",nil);
        [weakSelf.channelRegisterButton setTitle:title forState:UIControlStateNormal];
    }                                    failure:^(NSError *error) {
        [weakSelf showError:error];
    }];
}

- (IBAction)channelRegisterButtonTapped:(UIButton *)button {
    __weak typeof(self) weakSelf = self;
    [self.viewModel subscribeChannelWithSuccess:^{
        NSString *title = weakSelf.viewModel.isSubscribed? NSLocalizedString(@"ChannelSubscribed", nil) : NSLocalizedString(@"ChannelUnsubscribe",nil);
        [weakSelf.channelRegisterButton setTitle:title forState:UIControlStateNormal];
    }                                    failure:^(NSError *error) {
        [weakSelf showError:error];
    }];
}

- (IBAction)channelViewTapped:(UIGestureRecognizer *)recognizer {
    UIStoryboard *channelDetailStoryboard = [UIStoryboard storyboardWithName:@"ChannelDetail" bundle:nil];
    ChannelDetailViewController *channelDetailViewController = [channelDetailStoryboard instantiateInitialViewController];
    channelDetailViewController.channelId = self.viewModel.channelId;
    [self.navigationController pushViewController:channelDetailViewController animated:YES];
}


- (void)p_configureViews {
    [self.videoSegmentedControl setTitle:NSLocalizedString(@"VideoDetailInfo", @"Info") forSegmentAtIndex:0];
    [self.videoSegmentedControl setTitle:NSLocalizedString(@"VideoDietalSuggestions", @"Suggestions") forSegmentAtIndex:1];
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
            [self.videoSegmentedControl setSelectedSegmentIndex:0];
            [self swapFromViewController:self.relatedVideosViewController toViewController:self.infoViewController];
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

    [fromViewController.view removeFromSuperview];
    [self addConstraintsForViewController:toViewController];
    [fromViewController removeFromParentViewController];
    [toViewController didMoveToParentViewController:self];
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