//
// Created by 郭 輝平 on 12/8/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoInfoViewController.h"
#import "RSVideoInfoViewModel.h"
#import "UIViewController+RSLoading.h"
#import "UIViewController+RSError.h"

@interface RSVideoInfoViewController ()

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *postedAtLabel;
@property(nonatomic, weak) IBOutlet UILabel *rateLabel;
@property(nonatomic, weak) IBOutlet UILabel *viewCountLabel;
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;

@property(nonatomic, strong) RSVideoInfoViewModel *viewModel;
@end

@implementation RSVideoInfoViewController {

}


- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    [self p_configureViews];

    [self p_loadData];
}


- (void)p_configureViews {
}

- (void)p_loadData {
    self.viewModel = [[RSVideoInfoViewModel alloc] initWithVideoId:self.videoId];
    [self animateLoadingView];

    __weak typeof(self) weakSelf = self;
    [self.viewModel updateWithSuccess:^{
        self.view.alpha = 0.0;

        [weakSelf stopAnimateLoadingView];

        weakSelf.titleLabel.text = weakSelf.viewModel.title;
        weakSelf.postedAtLabel.text = weakSelf.viewModel.postedTime;
        weakSelf.descriptionTextView.text = weakSelf.viewModel.videoDescription;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.view.alpha = 1.0;
            }];
        });
    }                         failure:^(NSError *error) {
        [weakSelf showError:error];
        [weakSelf stopAnimateLoadingView];
    }];

    [self.viewModel updateVideoDetailWithSuccess:^{
        weakSelf.rateLabel.text = weakSelf.viewModel.rate;
        weakSelf.viewCountLabel.text = weakSelf.viewModel.viewCount;
    } failure:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.postedAtLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.rateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.viewCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.descriptionTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}
@end