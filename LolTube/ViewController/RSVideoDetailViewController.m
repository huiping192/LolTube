//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewController.h"
#import "RSVideoDetailViewModel.h"
#import "UIImageView+RSAsyncLoading.h"

@interface RSVideoDetailViewController ()<UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *videoPlayerView;
@property(nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *postedAtLabel;
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;

@property(nonatomic, strong) RSVideoDetailViewModel *videoDetailViewModel;

@end

@implementation RSVideoDetailViewController {

}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }

    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
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

    }                                failure:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(IBAction)closeButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  UIScrollViewDelegate

@end