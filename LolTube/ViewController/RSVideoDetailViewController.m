//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "UIImageView+RSAsyncLoading.h"
#import "UIViewController+RSLoading.h"
#import "AMTumblrHud.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface RSVideoDetailViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;
@property(nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];

    [self configureLoadingView];
    [self.loadingView showAnimated:YES];

    self.spaceView.layer.borderColor = [UIColor colorWithWhite:0.9f
                                                         alpha:1.0f].CGColor;
    self.spaceView.layer.borderWidth = 0.25;
    self.spaceView.hidden = YES;

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];

    self.videoDetailViewModel = [[RSVideoDetailViewModel alloc] initWithVideoId:self.videoId];
    __weak typeof(self) weakSelf = self;
    [self.videoDetailViewModel updateWithSuccess:^{
        [weakSelf.loadingView hide];
        self.spaceView.hidden = NO;

        [self.thumbnailImageView asynLoadingImageWithUrlString:weakSelf.videoDetailViewModel.mediumThumbnailUrl];
        weakSelf.titleLabel.text = weakSelf.videoDetailViewModel.title;
        weakSelf.postedAtLabel.text = weakSelf.videoDetailViewModel.postedTime;
        weakSelf.descriptionTextView.text = weakSelf.videoDetailViewModel.description;

    }                                    failure:^(NSError *error) {
        NSLog(@"error:%@", error);
        [weakSelf.loadingView hide];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)playImageTapped:(id)sender {
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];
    [self.videoPlayerViewController presentInView:self.videoPlayerView];
    self.thumbnailImageView.hidden = NO;

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

@end