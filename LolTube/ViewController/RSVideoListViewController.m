//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListViewController.h"
#import "RSVideoCollectionViewCell.h"
#import "RSVideoListCollectionViewModel.h"
#import "UIImageView+RSAsyncLoading.h"
#import "RSVideoDetailViewController.h"
#import "AMTumblrHud.h"
#import "UIViewController+RSLoading.h"
#import "RSVideoDetailAnimator.h"
#import "RSChannelListViewController.h"

static NSString *const kVideoCellId = @"videoCell";

@interface RSVideoListViewController () <UICollectionViewDataSource, UINavigationControllerDelegate>

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong) RSVideoListCollectionViewModel *collectionViewModel;

@end

@implementation RSVideoListViewController {

}


#pragma mark - UICollectionViewDataSource

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        // TODO: when do not have channelId, search all exist channel
        _collectionViewModel = [[RSVideoListCollectionViewModel alloc] initWithChannelId:@"UCvqRdlKsE5Q8mf8YXbdIJLw"];
    }

    return self;
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
    _collectionViewModel = [[RSVideoListCollectionViewModel alloc] initWithChannelId:_channelId];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.delegate = self;

    // enable inter active pop gesture
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) self;

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];

    [self p_loadData];
}

- (void)p_loadData {
    if (self.channelTitle) {
        self.navigationItem.title = self.channelTitle;
    }

    [self configureLoadingView];
    [self.loadingView showAnimated:YES];

    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateWithSuccess:^{
        [weakSelf.loadingView hide];
        [weakSelf.collectionView reloadData];
    }                                   failure:^(NSError *error) {
        [weakSelf.loadingView hide];
    }];
}

- (void)preferredContentSizeChanged:(id)preferredContentSizeChanged {
    [self.collectionView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"videoDetail"]) {
        RSVideoDetailViewController *videoDetailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *) sender];
        RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

        videoDetailViewController.videoId = item.videoId;

        RSVideoCollectionViewCell *cell = (RSVideoCollectionViewCell *) sender;
        videoDetailViewController.thumbnailImage = cell.thumbnailImageView.image;

    } else if ([segue.identifier isEqualToString:@"channelList"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RSChannelListViewController *channelListViewController = (RSChannelListViewController *) navigationController.topViewController;
        channelListViewController.currentChannelId = self.channelId;
    }
}

- (UICollectionViewCell *)selectedCell {
    return [self.collectionView cellForItemAtIndexPath:self.collectionView.indexPathsForSelectedItems[0]];
}

- (UICollectionViewCell *)cellWithVideoId:(NSString *)videoId {
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

        if ([item.videoId isEqualToString:videoId]) {
            return cell;
        }
    }

    return nil;
}

/**
* when channel title view tapped, push the new video list view controller
*/
- (IBAction)channelTitleViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIStoryboard *storyboard = self.storyboard;
    RSVideoListViewController *videoListViewController = [storyboard instantiateViewControllerWithIdentifier:@"videoList"];

    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) tapGestureRecognizer.view.tag];
    videoListViewController.channelId = item.channelId;
    videoListViewController.channelTitle = item.channelTitle;

    [self.navigationController pushViewController:videoListViewController animated:YES];
}

- (IBAction)channelSelected:(UIStoryboardSegue *)segue {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];

    [self p_loadData];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewModel.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellId forIndexPath:indexPath];
    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

    [cell.thumbnailImageView setImage:[UIImage imageNamed:@"DefaultThumbnail"]];
    [cell.thumbnailImageView asynLoadingImageWithUrlString:item.mediumThumbnailUrl];

    cell.titleLabel.text = item.title;
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    cell.postedTimeLabel.text = item.postedTime;
    cell.postedTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    cell.channelLabel.text = item.channelTitle;


    cell.channelTitleView.tag = indexPath.row;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(channelTitleViewTapped:)];
    [cell.channelTitleView addGestureRecognizer:tapGestureRecognizer];

    cell.channelTitleView.hidden = [item.channelId isEqualToString:self.channelId];

    return cell;
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (([fromVC isKindOfClass:[RSVideoListViewController class]] && [toVC isKindOfClass:[RSVideoDetailViewController class]]) || ([fromVC isKindOfClass:[RSVideoDetailViewController class]] && [toVC isKindOfClass:[RSVideoListViewController class]])) {
        return [[RSVideoDetailAnimator alloc] initWithOperation:operation];
    }

    return nil;
}


@end