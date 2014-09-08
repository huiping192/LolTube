//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "UIImageView+RSAsyncLoading.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface RSVideoDetailViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;
@property(nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *postedAtLabel;
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;

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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];

    self.videoDetailViewModel = [[RSVideoDetailViewModel alloc] initWithVideoId:self.videoId];

    [self.videoDetailViewModel updateWithSuccess:^{
        [self.thumbnailImageView asynLoadingImageWithUrlString:self.videoDetailViewModel.mediumThumbnailUrl];
        self.titleLabel.text = self.videoDetailViewModel.title;
        self.postedAtLabel.text = self.videoDetailViewModel.postedTime;
        self.descriptionTextView.text = self.videoDetailViewModel.description;

    }                                    failure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoPlayerViewController.moviePlayer stop];
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playImageTapped:(id)sender {
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];
    [self.videoPlayerViewController presentInView:self.videoPlayerView];
    self.thumbnailImageView.hidden = NO;

    [self.videoPlayerViewController.moviePlayer prepareToPlay];

}

#pragma mark -  UIScrollViewDelegate

@end