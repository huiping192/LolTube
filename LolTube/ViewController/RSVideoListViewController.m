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
#import "RSVideoService.h"

static NSString *const kVideoCellId = @"videoCell";
static CGFloat const kCellMinWidth = 250.0f;
static CGFloat const kCellRatio = 180.0f / 320.0f;

@interface RSVideoListViewController () <UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UIRefreshControl *refreshControl;
@property(nonatomic, weak) UISearchBar *searchBar;

@property(nonatomic, strong) RSVideoListCollectionViewModel *collectionViewModel;

@property(nonatomic, assign) BOOL collectionViewFirstShownFlag;

@property(atomic, assign) BOOL loading;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // hide search bar when first time show scroll view
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 44) animated:NO];

    // when return from other view recalculate collection view layout
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)p_configureViews {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(p_refresh) forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:refreshControl];

    self.collectionView.alwaysBounceVertical = YES;
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
                }                completion:^(BOOL finished) {
                    [self.collectionView flashScrollIndicators];
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
        // change video image to played video image
        [cell.thumbnailImageView asynLoadingTonalImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl];
    } else if ([segue.identifier isEqualToString:@"channelList"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RSChannelListViewController *channelListViewController = (RSChannelListViewController *) navigationController.topViewController;
        channelListViewController.currentChannelIds = self.channelIds;
    }
}

- (UICollectionViewCell *)selectedCell {
    return [self.collectionView cellForItemAtIndexPath:self.collectionView.indexPathsForSelectedItems[0]];
}

- (NSIndexPath *)indexPathWithVideoId:(NSString *)videoId {
    for (RSVideoCollectionViewCellVo *cellVo in self.collectionViewModel.items) {
        if ([cellVo.videoId isEqualToString:videoId]) {
            return [NSIndexPath indexPathForItem:[self.collectionViewModel.items indexOfObject:cellVo] inSection:0];
        }
    }
    return nil;
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateWithSuccess:^{
        [weakSelf.collectionView reloadData];
        NSLog(@"fetch success");
        completionHandler(UIBackgroundFetchResultNewData);
    }                                   failure:^(NSError *error) {
        NSLog(@"fetch failure");
        completionHandler(UIBackgroundFetchResultFailed);
    }];
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


- (IBAction)searchButtonTapped {
    [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewModel.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellId forIndexPath:indexPath];
    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

    [cell.thumbnailImageView setImage:[UIImage imageNamed:@"DefaultThumbnail"]];
    if ([[RSVideoService sharedInstance] isPlayFinishedWithVideoId:item.videoId]) {
        [cell.thumbnailImageView asynLoadingTonalImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl];
    } else {
        [cell.thumbnailImageView asynLoadingImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];
    }

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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *searchCollectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"searchCollectionReusableView" forIndexPath:indexPath];

    if (searchCollectionReusableView.subviews.count == 0) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.placeholder = NSLocalizedString(@"SearchVideos", @"Search Videos");
        searchBar.text = self.collectionViewModel.searchText;
        searchBar.translatesAutoresizingMaskIntoConstraints = NO;

        [searchCollectionReusableView addSubview:searchBar];
        NSArray *hConstraints =
                [NSLayoutConstraint constraintsWithVisualFormat:@"|[searchBar]|"
                                                        options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchBar)];
        NSArray *VConstraints =
                [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar]|"
                                                        options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchBar)];

        [searchCollectionReusableView addConstraints:hConstraints];
        [searchCollectionReusableView addConstraints:VConstraints];

        self.searchBar = searchBar;
    }

    return searchCollectionReusableView;
}


#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }

    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        // load more videos
        if (self.loading) {
            return;
        }
        self.loading = YES;
        __weak typeof(self) weakSelf = self;
        [self.collectionViewModel updateNextPageDataWithSuccess:^(BOOL hasNewData) {
            if (hasNewData) {
                [weakSelf.collectionView reloadData];
            }
            self.loading = NO;

        }                                               failure:^(NSError *error) {
            NSLog(@"error:%@", error);
            self.loading = NO;
        }];
    }
}

#pragma mark - orientation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - search bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    [self.collectionViewModel setSearchText:searchBar.text];
    [self p_loadDataWithAnimated:YES];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    if (self.collectionViewModel.searchText) {
        [self.collectionViewModel setSearchText:nil];
        [self p_loadDataWithAnimated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionWidth = self.view.frame.size.width;
    int cellCount = (int) (collectionWidth / kCellMinWidth);
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) collectionViewLayout;

    CGFloat cellWidth = (collectionWidth - flowLayout.sectionInset.left * (cellCount + 1)) / cellCount;

    return CGSizeMake(cellWidth, cellWidth * kCellRatio);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

@end