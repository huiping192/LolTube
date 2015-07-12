//
// Created by 郭 輝平 on 12/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoRelatedVideosViewController.h"
#import "RSVideoRelatedVideosViewModel.h"
#import "UIViewController+RSLoading.h"
#import "UIViewController+RSError.h"
#import "RSVideoRelatedVideoCell.h"
#import "UIImageView+Loading.h"
#import "RSVideoDetailViewController.h"

static CGFloat const kCellMinWidth = 280.0;
static CGFloat const kCellHeight = 100.0;

@interface RSVideoRelatedVideosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) RSVideoRelatedVideosViewModel *viewModel;

@property(nonatomic, weak) IBOutlet  UICollectionView *collectionView;
@property(nonatomic, strong) NSOperationQueue *imageLoadingOperationQueue;

@end

@implementation RSVideoRelatedVideosViewController {

}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.imageLoadingOperationQueue = [[NSOperationQueue alloc] init];

    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [self p_loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.collectionView.collectionViewLayout invalidateLayout];
}


- (void)p_loadData {
    self.viewModel = [[RSVideoRelatedVideosViewModel alloc] initWithVideoId:self.videoId];
    [self animateLoadingView];

    __weak typeof(self) weakSelf = self;
    [self.viewModel updateWithSuccess:^{
        self.collectionView.alpha = 0.0;
        
        [weakSelf stopAnimateLoadingView];
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.collectionView.alpha = 1.0;
            }                completion:^(BOOL finished) {
                [self.collectionView flashScrollIndicators];
            }];
        });
    }                         failure:^(NSError *error) {
        [weakSelf showError:error];
        [weakSelf stopAnimateLoadingView];
    }];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.relatedVideoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoRelatedVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"relatedVideoCell" forIndexPath:indexPath];
    RSRelatedVideoCollectionViewCellVo *cellVo = self.viewModel.relatedVideoList[(NSUInteger) indexPath.row];

    cell.titleLabel.text = cellVo.title;
    cell.channelLabel.text = cellVo.channelTitle;
    NSOperation *imageOperation = [UIImageView asynLoadingImageWithUrlString:cellVo.thumbnailImageUrl secondImageUrlString:nil needBlackWhiteEffect:NO success:^(UIImage *image) {
        cell.thumbnailImageView.image = image;
    }];
    [self.imageLoadingOperationQueue addOperation:imageOperation];

    if (cellVo.duration) {
        cell.durationLabel.text = cellVo.duration;
        cell.viewCountLabel.text = cellVo.viewCountpublishedAt;
    } else {
        [self.viewModel updateVideoDetailWithCellVo:cellVo success:^{
            cell.durationLabel.text = cellVo.duration;
            cell.viewCountLabel.text = cellVo.viewCountpublishedAt;

        }                                   failure:nil];
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoDetailViewController *videoDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoDetail"];
    RSRelatedVideoCollectionViewCellVo *cellVo = self.viewModel.relatedVideoList[(NSUInteger) indexPath.row];

    videoDetailViewController.videoId = cellVo.videoId;
    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    int cellCount = (int) (collectionWidth / kCellMinWidth);
    CGFloat cellWidth = collectionWidth  / cellCount;
    return CGSizeMake(cellWidth, kCellHeight);
}

@end