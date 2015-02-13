//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListViewController.h"
#import "RSVideoCollectionViewCell.h"
#import "RSVideoListCollectionViewModel.h"
#import "RSVideoDetailViewController.h"
#import "UIViewController+RSLoading.h"
#import "RSChannelListViewController.h"
#import "RSChannelService.h"
#import "UIImageView+Loading.h"
#import "RSVideoService.h"
#import "UIViewController+RSError.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>

static NSString *const kVideoCellId = @"videoCell";

@interface RSVideoListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property(nonatomic, weak) IBOutlet UILabel *noVideoFoundLabel;

@property(nonatomic, weak) UIRefreshControl *refreshControl;
@property(nonatomic, weak) UISearchBar *searchBar;

@property(nonatomic, strong) RSVideoListCollectionViewModel *collectionViewModel;

@property(nonatomic, assign) BOOL collectionViewFirstShownFlag;

@property(atomic, assign) BOOL loading;

@property(nonatomic, strong) NSMutableDictionary *imageLoadingOperationDictionary;
@property(nonatomic, strong) NSOperationQueue *imageLoadingOperationQueue;

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

        self.imageLoadingOperationQueue = [[NSOperationQueue alloc] init];
        self.imageLoadingOperationDictionary = [[NSMutableDictionary alloc] init];
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

    [self p_loadVideosData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // hide search bar when first time show scroll view
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 44) animated:NO];

    // when return from other view recalculate collection view layout
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.imageLoadingOperationQueue cancelAllOperations];
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

        // change iamge to blackwhite when video tapped
        NSOperation *imageOperation = [UIImageView asynLoadingImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl needBlackWhiteEffect:YES success:^(UIImage *image) {
            cell.thumbnailImageView.image = image;
        }];
        [self.imageLoadingOperationQueue addOperation:imageOperation];

    } else if ([segue.identifier isEqualToString:@"channelList"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RSChannelListViewController *channelListViewController = (RSChannelListViewController *) navigationController.topViewController;
        channelListViewController.currentChannelIds = self.channelIds;
    }
}

- (void)p_configureViews {
    //configure refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(p_refreshData) forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:refreshControl];
}

- (void)p_configureNotifications {
    // system prefer font size changed notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - data loading

- (void)p_refreshData {
    NSInteger dataCount = [self.collectionView numberOfItemsInSection:0];
    __weak typeof(self) weakSelf = self;

    [self.collectionViewModel refreshWithSuccess:^(BOOL hasNewData) {
        if (!hasNewData) {
            [self.refreshControl endRefreshing];
            return;
        }
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < weakSelf.collectionViewModel.items.count - dataCount; ++i) {
            [insertIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        if (insertIndexPaths.count == 0) {
            [self.refreshControl endRefreshing];
            return;
        }
        [weakSelf.collectionView performBatchUpdates:^{
            [weakSelf.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        }                                 completion:^(BOOL finished) {
            [self.refreshControl endRefreshing];
        }];
    }                                    failure:^(NSError *error) {
        [self showError:error];
        [self.refreshControl endRefreshing];
    }];
}

- (void)p_loadVideosData {
    if (self.title) {
        self.navigationItem.title = self.title;
    }

    [self animateLoadingView];
    self.collectionViewFirstShownFlag = YES;
    self.collectionView.alpha = 0.0;
    [self.noVideoFoundLabel setHidden:YES];

    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateWithSuccess:^{
        [weakSelf.noVideoFoundLabel setHidden:weakSelf.collectionViewModel.items.count != 0];

        [weakSelf.collectionView reloadData];
        [weakSelf stopAnimateLoadingView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.collectionViewFirstShownFlag = NO;
                self.collectionView.alpha = 1.0;
            }                completion:^(BOOL finished) {
                [self.collectionView flashScrollIndicators];
            }];
        });
    }                                   failure:^(NSError *error) {
        [self showError:error];

        self.collectionViewFirstShownFlag = NO;
        self.collectionView.alpha = 1.0;
        [weakSelf stopAnimateLoadingView];
    }];
}

#pragma mark - notification

- (void)preferredContentSizeChanged:(id)preferredContentSizeChanged {
    [self.collectionView reloadData];
}

#pragma mark - publish method

- (UICollectionViewCell *)selectedCell {
    if (self.collectionView.indexPathsForSelectedItems.count == 0) {
        return nil;
    }
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
        completionHandler(UIBackgroundFetchResultNewData);
    }                                   failure:^(NSError *error) {
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
    // scroll to top when new channel selected
    if ([self.collectionView numberOfItemsInSection:0] != 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }

    [self p_loadVideosData];
}


- (IBAction)searchButtonTapped {
    //TODO: show uisearchdisplaycontroller
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
    if (!item) {
        return cell;
    }
    NSOperation *imageOperation = [UIImageView asynLoadingImageWithUrlString:item.highThumbnailUrl secondImageUrlString:item.defaultThumbnailUrl needBlackWhiteEffect:[[RSVideoService sharedInstance] isPlayFinishedWithVideoId:item.videoId] success:^(UIImage *image) {
        RSVideoCollectionViewCell *collectionViewCell = (RSVideoCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        collectionViewCell.thumbnailImageView.image = image;
    }];

    [self.imageLoadingOperationQueue addOperation:imageOperation];
    self.imageLoadingOperationDictionary[item.videoId] = imageOperation;

    cell.titleLabel.text = item.title;
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    if (item.duration) {
        cell.durationLabel.text = item.duration;
        cell.viewCountLabel.text = item.viewCount;
    } else {
        [self.collectionViewModel updateVideoDetailWithCellVo:item success:^{
            cell.durationLabel.text = item.duration;
            cell.viewCountLabel.text = item.viewCount;

        }                                             failure:nil];
    }

    cell.durationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    cell.viewCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    cell.channelLabel.text = item.channelTitle;
    cell.channelTitleView.tag = indexPath.row;
    [cell.channelTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(channelTitleViewTapped:)]];
    cell.channelTitleView.hidden = !self.needShowChannelTitleView;

    //first time appear animation
    if (self.collectionViewFirstShownFlag) {
        cell.transform = CGAffineTransformMakeTranslation(0, collectionView.frame.size.height);
        [UIView animateWithDuration:0.5 delay:0.05 * indexPath.row usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.transform = CGAffineTransformIdentity;
        }                completion:nil];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= self.collectionViewModel.items.count){
       return;
    }
    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];
    if (item) {
        return;
    }
    NSOperation *operation = self.imageLoadingOperationDictionary[item.videoId];
    if (operation) {
        [operation cancel];
        [self.imageLoadingOperationDictionary removeObjectForKey:item.videoId];
    }

}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *searchCollectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"searchCollectionReusableView" forIndexPath:indexPath];

    // 重複search barを追加しないように判定する
    if (searchCollectionReusableView.subviews.count != 0) {
        return searchCollectionReusableView;
    }

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = NSLocalizedString(@"SearchVideos", @"Search Videos");
    searchBar.text = self.collectionViewModel.searchText;

    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [searchCollectionReusableView addSubview:searchBar];
    [searchCollectionReusableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[searchBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchBar)]];
    [searchCollectionReusableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchBar)]];

    self.searchBar = searchBar;

    return searchCollectionReusableView;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }

    if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) * 0.8) {
        // load more videos
        [self p_loadNextPageVideoData];
    }
}

- (void)p_loadNextPageVideoData {
    if (self.loading) {
        return;
    }
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    if (count == 0) { //no need to load more data when current data is empty
        return;
    }
    self.loading = YES;

    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateNextPageDataWithSuccess:^(BOOL hasNewData) {
        if (!hasNewData) {
            weakSelf.loading = NO;
            return;
        }

        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        for (NSInteger i = count; i < weakSelf.collectionViewModel.items.count; ++i) {
            [insertIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        if (insertIndexPaths.count == 0) {
            weakSelf.loading = NO;
            return;
        }
        [weakSelf.collectionView performBatchUpdates:^{
            [weakSelf.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        }                                 completion:^(BOOL finished) {
            weakSelf.loading = NO;
        }];
    }                                               failure:^(NSError *error) {
        [self showError:error];
        weakSelf.loading = NO;
    }];
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
    [self p_loadVideosData];

    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"video_list"
                                                          action:@"video_search"
                                                           label:searchBar.text
                                                           value:nil] build]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    if (self.collectionViewModel.searchText) {
        [self.collectionViewModel setSearchText:nil];
        [self p_loadVideosData];
    }
}

@end