//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "UIViewController+RSLoading.h"
#import "Reachability.h"
#import "RSVideoService.h"
#import "UIViewController+RSError.h"
#import "GAIDictionaryBuilder.h"
#import "RSEnvironment.h"
#import "UIImageView+Loading.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>

@interface RSVideoDetailViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *postedAtLabel;
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property(nonatomic, weak) IBOutlet UIView *spaceView;

@property(nonatomic, strong) RSVideoDetailViewModel *videoDetailViewModel;

@property(nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;


@property(nonatomic, strong) NSOperation *imageLoadingOperation;
@property(nonatomic, strong) NSOperationQueue *imageLoadingOperationQueue;

@end

@implementation RSVideoDetailViewController {

}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _imageLoadingOperationQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self p_configureViews];

    [self p_addNotifications];

    [self p_loadData];

    [self p_playVideo];
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
    self.spaceView.layer.borderColor = [UIColor colorWithWhite:0.7f
                                                         alpha:1.0f].CGColor;
    self.spaceView.layer.borderWidth = 0.25;
    self.spaceView.hidden = YES;

    self.thumbnailImageView.image = self.thumbnailImage;
    self.thumbnailImage = nil;
}

- (void)p_loadData {
    self.videoDetailViewModel = [[RSVideoDetailViewModel alloc] initWithVideoId:self.videoId];
    [self animateLoadingView];

    __weak typeof(self) weakSelf = self;
    [self.videoDetailViewModel updateWithSuccess:^{
        [weakSelf stopAnimateLoadingView];
        weakSelf.spaceView.hidden = NO;

        NSOperation *imageLoadingOperation = [UIImageView asynLoadingImageWithUrlString:weakSelf.videoDetailViewModel.highThumbnailUrl secondImageUrlString:weakSelf.videoDetailViewModel.mediumThumbnailUrl needBlackWhiteEffect:NO success:^(UIImage *image) {
            if ([weakSelf.imageLoadingOperation isCancelled]) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.thumbnailImageView.image = image;
            });
            weakSelf.imageLoadingOperation = nil;
        }];
        [weakSelf.imageLoadingOperationQueue addOperation:imageLoadingOperation];
        weakSelf.imageLoadingOperation = imageLoadingOperation;

        weakSelf.titleLabel.text = weakSelf.videoDetailViewModel.title;
        weakSelf.postedAtLabel.text = weakSelf.videoDetailViewModel.postedTime;
        weakSelf.descriptionTextView.text = weakSelf.videoDetailViewModel.videoDescription;

    }                                    failure:^(NSError *error) {
        [weakSelf showError:error];

        [weakSelf stopAnimateLoadingView];
    }];
}

- (void)p_addNotifications {
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];

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
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail"
                                                          action:@"video_play"
                                                           label:self.videoId
                                                           value:nil] build]];

    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus != ReachableViaWiFi) {
        self.videoPlayerViewController.preferredVideoQualities = @[@(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    }

    // prevent mute switch from switching off audio from movie player
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self.videoPlayerViewController presentInView:self.videoPlayerView];

    NSTimeInterval initialPlaybackTime = self.initialPlaybackTime == 0.0 ? [[RSVideoService sharedInstance] lastPlaybackTimeWithVideoId:self.videoId] : self.initialPlaybackTime;
    [self.videoPlayerViewController.moviePlayer setInitialPlaybackTime:initialPlaybackTime];
    [self.videoPlayerViewController.moviePlayer prepareToPlay];
}

- (IBAction)shareButtonTapped:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];

    [sharingItems addObject:self.videoDetailViewModel.shareTitle];
    [sharingItems addObject:self.thumbnailImageView.image];
    [sharingItems addObject:[NSURL URLWithString:self.videoDetailViewModel.shareUrlString]];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        //TODO: success alert
        id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail"
                                                              action:@"video_share"
                                                               label:self.videoId
                                                               value:nil] build]];
    }];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.postedAtLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.descriptionTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

#pragma mark -  UIScrollViewDelegate

#pragma mark - orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.videoPlayerViewController.moviePlayer setFullscreen:toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight animated:YES];
}


@end