//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListViewController.h"
#import "RSVideoCollectionViewCell.h"
#import "RSVideoListCollectionViewModel.h"
#import "RSVideoDetailViewController.h"
#import "AMTumblrHud.h"
#import "UIViewController+RSLoading.h"
#import "RSChannelListViewController.h"
#import "RSChannelService.h"
#import "UIImageView+Loading.h"

static NSString *const kVideoCellId = @"videoCell";
static CGFloat const kCellMinWidth = 250.0f;
static CGFloat const kCellRatio = 180.0f / 320.0f;

@interface RSVideoListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, weak) UIRefreshControl *refreshControl;

@property(nonatomic, strong) RSVideoListCollectionViewModel *collectionViewModel;

@property(nonatomic, assign) BOOL collectionViewFirstShownFlag;

@end

@implementation RSVideoListViewController {

}


#pragma mark - UICollectionViewDataSource

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        RSChannelService *channelService = [[RSChannelService alloc] init];
        _channelIds = [channelService channelIds];
        _collectionViewModel = [[RSVideoListCollectionViewModel alloc] initWithChannelIds:_channelIds];

        _needShowChannelTitleView = YES;
    }

    return self;
}

- (void)setChannelIds:(NSArray *)channelIds {
    _channelIds = channelIds;
    _collectionViewModel = [[RSVideoListCollectionViewModel alloc] initWithChannelIds:channelIds];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // enable inter active pop gesture
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) self;

    [self p_configureViews];

    [self p_configureNotifications];

    [self p_loadDataWithAnimated:YES];
}

- (void)p_configureViews {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(p_refresh) forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView addSubview:refreshControl];
}

- (void)p_configureNotifications {
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];
}

- (void)p_refresh {
    [self p_loadDataWithAnimated:NO];
    [self.refreshControl endRefreshing];
}

- (void)p_loadDataWithAnimated:(BOOL)animated {
    if (self.title) {
        self.navigationItem.title = self.title;
    }

    if (animated) {
        [self configureLoadingView];
        [self.loadingView showAnimated:YES];
        self.collectionViewFirstShownFlag = YES;
        self.collectionView.alpha = 0.0;
    }

    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateWithSuccess:^{
        [weakSelf.collectionView reloadData];
        if (animated) {
            [weakSelf.loadingView hide];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 animations:^{
                    self.collectionViewFirstShownFlag = NO;
                    self.collectionView.alpha = 1.0;
                }];
            });
        }
    }                                   failure:^(NSError *error) {
        if (animated) {
            [weakSelf.loadingView hide];
        }
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
        channelListViewController.currentChannelIds = self.channelIds;
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
    videoListViewController.channelIds = @[item.channelId];
    videoListViewController.title = item.channelTitle;
    videoListViewController.needShowChannelTitleView = NO;

    [self.navigationController pushViewController:videoListViewController animated:YES];
}

- (IBAction)channelSelected:(UIStoryboardSegue *)segue {
    if ([self.collectionView numberOfItemsInSection:0] != 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }

    [self p_loadDataWithAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewModel.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellId forIndexPath:indexPath];
    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

    [cell.thumbnailImageView setImage:[UIImage imageNamed:@"DefaultThumbnail"]];
    [cell.thumbnailImageView asynLoadingImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];

    cell.titleLabel.text = item.title;
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    cell.postedTimeLabel.text = item.postedTime;
    cell.postedTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    cell.channelLabel.text = item.channelTitle;


    cell.channelTitleView.tag = indexPath.row;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(channelTitleViewTapped:)];
    [cell.channelTitleView addGestureRecognizer:tapGestureRecognizer];

    cell.channelTitleView.hidden = !self.needShowChannelTitleView;

    if (self.collectionViewFirstShownFlag) {
        cell.transform = CGAffineTransformMakeTranslation(0, collectionView.frame.size.height);
        [UIView animateWithDuration:0.4 delay:0.03 * indexPath.row usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.transform = CGAffineTransformIdentity;
        }                completion:nil];
    }

    return cell;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == roundf(scrollView.contentSize.height - scrollView.frame.size.height)) {
        // load more videos
        __weak typeof(self) weakSelf = self;
        [self.collectionViewModel updateNextPageDataWithSuccess:^{
            [weakSelf.collectionView reloadData];

        }                                               failure:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
    }
}

#pragma mark - orientation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    CGFloat collectionWidth = self.collectionView.frame.size.width;
    int cellCount = (int) (collectionWidth / kCellMinWidth);
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;

    CGFloat cellWidth = (self.collectionView.frame.size.width - flowLayout.sectionInset.left * (cellCount + 1)) / cellCount;

    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth * kCellRatio);
}

@end