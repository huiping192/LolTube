//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "RSVideoService.h"
#import "UIViewController+RSError.h"
#import "GAIDictionaryBuilder.h"
#import "RSEnvironment.h"
#import "RSVideoDetailSegmentViewController.h"
#import "RSVideoRelatedVideosViewController.h"
#import "UIImageView+Loading.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>

static const CGFloat kCompactPadWidth = 768.0f;
static const CGFloat kRelatedVideosViewWidthRegularWidth = 320.0f;
static const CGFloat kRelatedVideosViewWidthCompactWidth = 0.0f;

@interface RSVideoDetailViewController () <UIActionSheetDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;

@property(nonatomic, strong) RSVideoDetailViewModel *videoDetailViewModel;

@property(nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@property(nonatomic, weak) UIBarButtonItem *videoQualitySwitchButton;
@property(nonatomic, weak) UIBarButtonItem *shareButton;
@property(nonatomic, assign) XCDYouTubeVideoQuality currentVideoQuality;

@property(nonatomic, strong) RSVideoDetailSegmentViewController *videoDetailSegmentViewController;
@property(nonatomic, strong) RSVideoRelatedVideosViewController *relatedVideosViewController;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *relatedVideosViewWidthConstraint;

@end

@implementation RSVideoDetailViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self p_configureViews];
    [self p_addNotifications];
    [self p_loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self p_overrideChildViewControllerTraitCollectionWithSize:self.view.frame.size withTransitionCoordinator:nil];
}

- (void)p_overrideChildViewControllerTraitCollectionWithSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithHorizontalSizeClass:size.width <= kCompactPadWidth ? UIUserInterfaceSizeClassCompact : UIUserInterfaceSizeClassRegular];
        [self setOverrideTraitCollection:traitCollection forChildViewController:self.relatedVideosViewController];
        [self setOverrideTraitCollection:traitCollection forChildViewController:self.videoDetailSegmentViewController];

        if (coordinator) {
            [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
                self.relatedVideosViewWidthConstraint.constant = [traitCollection containsTraitsInCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular]] ? kRelatedVideosViewWidthRegularWidth : kRelatedVideosViewWidthCompactWidth;
                [self.view layoutIfNeeded];
            }                            completion:nil];
        } else {
            self.relatedVideosViewWidthConstraint.constant = [traitCollection containsTraitsInCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular]] ? kRelatedVideosViewWidthRegularWidth : kRelatedVideosViewWidthCompactWidth;
            [self.view layoutIfNeeded];
        }
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.videoPlayerViewController.moviePlayer isFullscreen]) {
        [self p_playVideo];
    }
}


- (void)p_loadData {
    self.videoDetailViewModel = [[RSVideoDetailViewModel alloc] initWithVideoId:self.videoId];

    __weak typeof(self) weakSelf = self;
    [self.videoDetailViewModel updateWithSuccess:^{
        [weakSelf.thumbnailImageView asynLoadingImageWithUrlString:self.videoDetailViewModel.thumbnailImageUrl placeHolderImage:nil];
        weakSelf.shareButton.enabled = YES;
    }                                    failure:^(NSError *error) {
        [weakSelf showError:error];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"videoDetailSegmentEmbed"]) {
        RSVideoDetailSegmentViewController *videoDetailSegmentViewController = segue.destinationViewController;
        videoDetailSegmentViewController.videoId = self.videoId;
        self.videoDetailSegmentViewController = videoDetailSegmentViewController;
    } else if ([segue.identifier isEqualToString:@"relatedVideosEmbed"]) {
        RSVideoRelatedVideosViewController *relatedVideosViewController = segue.destinationViewController;
        relatedVideosViewController.videoId = self.videoId;
        self.relatedVideosViewController = relatedVideosViewController;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self p_overrideChildViewControllerTraitCollectionWithSize:size withTransitionCoordinator:coordinator];
}


- (void)p_startActivity {
    if (![NSUserActivity class]) {
        return;
    }
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.huiping192.LolTube.videoDetail"];
    activity.title = @"VideoDeital";
    int videoCurrentPlayTime = (int) self.videoPlayerViewController.moviePlayer.currentPlaybackTime;
    activity.userInfo = @{@"videoId" : self.videoId, @"videoCurrentPlayTime" : @(videoCurrentPlayTime), kHandOffVersionKey : kHandOffVersion};
    activity.webpageURL = [NSURL URLWithString:[NSString stringWithFormat:self.videoDetailViewModel.handoffUrlStringFormat, self.videoId, videoCurrentPlayTime]];

    self.userActivity = activity;
    [activity becomeCurrent];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    [super updateUserActivityState:activity];
    int videoCurrentPlayTime = (int) self.videoPlayerViewController.moviePlayer.currentPlaybackTime;
    [activity addUserInfoEntriesFromDictionary:@{@"videoId" : self.videoId, @"videoCurrentPlayTime" : @(videoCurrentPlayTime), kHandOffVersionKey : kHandOffVersion}];
    activity.webpageURL = [NSURL URLWithString:[NSString stringWithFormat:self.videoDetailViewModel.handoffUrlStringFormat, self.videoId, videoCurrentPlayTime]];

    activity.needsSave = YES;
}

- (void)p_configureViews {
    UIBarButtonItem *videoQualitySwitchButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"VideoQualityHigh", @"High") style:UIBarButtonItemStylePlain target:self action:@selector(switchVideoQualityButtonTapped:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)];
    shareButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[shareButton, videoQualitySwitchButton];
    self.videoQualitySwitchButton = videoQualitySwitchButton;
    self.shareButton = shareButton;
}

- (void)p_addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_moviePreloadDidFinish:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)p_moviePlayBackDidFinish:(id)moviePlayerPlaybackDidFinishNotification {
    self.videoPlayerViewController.moviePlayer.currentPlaybackTime = 3.0;
}

- (void)p_moviePreloadDidFinish:(id)moviePlayerLoadStateDidChangeNotification {
    if (self.videoPlayerViewController.moviePlayer.loadState == MPMovieLoadStatePlayable) {
        [[RSVideoService sharedInstance] savePlayFinishedVideoId:self.videoId];

        [self p_startActivity];

        // TODO: fun animation
        [UIView animateWithDuration:0.25 animations:^{
            self.thumbnailImageView.alpha = 0.0;
        }];
    }
}

- (void)dealloc {
    [[RSVideoService sharedInstance] updateLastPlaybackTimeWithVideoId:self.videoId lastPlaybackTime:self.videoPlayerViewController.moviePlayer.currentPlaybackTime];

    [self.videoPlayerViewController.moviePlayer stop];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([NSUserActivity class]) {
        [self.userActivity invalidate];
    }
}

- (void)p_playVideo {
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail" action:@"video_play" label:self.videoId value:nil] build]];

    NSTimeInterval initialPlaybackTime = self.initialPlaybackTime == 0.0 ? [[RSVideoService sharedInstance] lastPlaybackTimeWithVideoId:self.videoId] : self.initialPlaybackTime;
    [self p_playVideoWithInitialPlaybackTime:initialPlaybackTime videoQualities:@[@(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)]];
    self.currentVideoQuality = XCDYouTubeVideoQualityHD720;
}

- (IBAction)shareButtonTapped:(id)sender {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (self.videoDetailViewModel.shareTitle) {
        [items addObject:self.videoDetailViewModel.shareTitle];
    }
    if (self.thumbnailImageView.image) {
        [items addObject:self.thumbnailImageView.image];
    }
    if (self.videoDetailViewModel.shareUrlString) {
        [items addObject:[NSURL URLWithString:self.videoDetailViewModel.shareUrlString]];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        //TODO: success alert
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail" action:@"video_share" label:self.videoId value:nil] build]];
    }];
}


- (IBAction)switchVideoQualityButtonTapped:(id)sender {
    UIActionSheet *videoQualityActionSheet = [[UIActionSheet alloc] init];
    videoQualityActionSheet.delegate = self;
    videoQualityActionSheet.title = NSLocalizedString(@"SwitchVideoQuality", @"Switch Video Quality");
    [videoQualityActionSheet addButtonWithTitle:NSLocalizedString(@"VideoQualityHigh", @"High")];
    [videoQualityActionSheet addButtonWithTitle:NSLocalizedString(@"VideoQualityMedium", @"Medium")];
    [videoQualityActionSheet addButtonWithTitle:NSLocalizedString(@"VideoQualityLow", @"Low")];
    [videoQualityActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];

    videoQualityActionSheet.cancelButtonIndex = 3;

    switch (_currentVideoQuality) {
        case XCDYouTubeVideoQualityHD720: {
            videoQualityActionSheet.destructiveButtonIndex = 0;
            break;
        }
        case XCDYouTubeVideoQualityMedium360: {
            videoQualityActionSheet.destructiveButtonIndex = 1;
            break;
        }
        case XCDYouTubeVideoQualitySmall240: {
            videoQualityActionSheet.destructiveButtonIndex = 2;
            break;
        }
    }
    [videoQualityActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSTimeInterval initialPlaybackTime = self.videoPlayerViewController.moviePlayer.currentPlaybackTime;

    switch (buttonIndex) {
        case 0:
            if (self.currentVideoQuality == XCDYouTubeVideoQualityHD720) {
                return;
            }
            [self p_playVideoWithInitialPlaybackTime:initialPlaybackTime videoQualities:@[@(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)]];
            self.videoQualitySwitchButton.title = NSLocalizedString(@"VideoQualityHigh", @"High");
            self.currentVideoQuality = XCDYouTubeVideoQualityHD720;

            break;
        case 1:
            if (self.currentVideoQuality == XCDYouTubeVideoQualityMedium360) {
                return;
            }
            [self p_playVideoWithInitialPlaybackTime:initialPlaybackTime videoQualities:@[@(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)]];
            self.videoQualitySwitchButton.title = NSLocalizedString(@"VideoQualityMedium", @"Medium");
            self.currentVideoQuality = XCDYouTubeVideoQualityMedium360;

            break;
        case 2:
            if (self.currentVideoQuality == XCDYouTubeVideoQualitySmall240) {
                return;
            }
            [self p_playVideoWithInitialPlaybackTime:initialPlaybackTime videoQualities:@[@(XCDYouTubeVideoQualitySmall240)]];
            self.videoQualitySwitchButton.title = NSLocalizedString(@"VideoQualityLow", @"Low");
            self.currentVideoQuality = XCDYouTubeVideoQualitySmall240;

            break;
    }

}

- (void)p_playVideoWithInitialPlaybackTime:(NSTimeInterval)initialPlaybackTime videoQualities:(NSArray *)videoQualities {
    [self.videoPlayerViewController.moviePlayer stop];
    [self.videoPlayerViewController.moviePlayer.view removeFromSuperview];
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];

    self.videoPlayerViewController.preferredVideoQualities = videoQualities;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self.videoPlayerViewController presentInView:self.videoPlayerView];
    [self.videoPlayerViewController.moviePlayer setInitialPlaybackTime:initialPlaybackTime];
    [self.videoPlayerViewController.moviePlayer prepareToPlay];

}

#pragma mark -  UIScrollViewDelegate

#pragma mark - orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (self.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassRegular) {
        [self.videoPlayerViewController.moviePlayer setFullscreen:toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight animated:YES];
    }
}


@end