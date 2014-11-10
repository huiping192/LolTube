//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "UIViewController+RSLoading.h"
#import "AMTumblrHud.h"
#import "UIImageView+Loading.h"
#import "Reachability.h"
#import "RSVideoService.h"
#import "UIViewController+RSError.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RSVideoDetailViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *postedAtLabel;
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property(nonatomic, weak) IBOutlet UIView *spaceView;

@property(nonatomic, strong) RSVideoDetailViewModel *videoDetailViewModel;

@property(nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

@implementation RSVideoDetailViewController {

}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
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
        self.spaceView.hidden = NO;

        [self.thumbnailImageView asynLoadingImageWithUrlString:weakSelf.videoDetailViewModel.highThumbnailUrl secondImageUrlString:weakSelf.videoDetailViewModel.mediumThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];
        weakSelf.titleLabel.text = weakSelf.videoDetailViewModel.title;
        weakSelf.postedAtLabel.text = weakSelf.videoDetailViewModel.postedTime;
        weakSelf.descriptionTextView.text = weakSelf.videoDetailViewModel.videoDescription;

    }                                    failure:^(NSError *error) {
        [self showError:error];

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

- (void)p_moviePlayBackDidFinish:(id)DidFinish {
    self.videoPlayerViewController.moviePlayer.currentPlaybackTime = 1.0;
}

- (void)p_moviePreloadDidFinish:(id)p_moviePreloadDidFinish {
    [[RSVideoService sharedInstance] savePlayFinishedVideoId:self.videoId];

    // TODO: fun animation
    [UIView animateWithDuration:0.25 animations:^{
        self.thumbnailImageView.alpha = 0.0;
    }];
}

- (void)dealloc {
    [[RSVideoService sharedInstance] updateLastPlaybackTimeWithVideoId:self.videoId lastPlaybackTime:self.videoPlayerViewController.moviePlayer.currentPlaybackTime];

    [self.videoPlayerViewController.moviePlayer stop];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)p_playVideo {
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus != ReachableViaWiFi) {
        self.videoPlayerViewController.preferredVideoQualities = @[@(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    }

    // prevent mute switch from switching off audio from movie player
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self.videoPlayerViewController presentInView:self.videoPlayerView];

    [self.videoPlayerViewController.moviePlayer setInitialPlaybackTime:[[RSVideoService sharedInstance] lastPlaybackTimeWithVideoId:self.videoId]];
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