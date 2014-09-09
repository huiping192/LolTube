//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListViewController.h"
#import "RSVideoCollectionViewCell.h"
#import "RSVideoListCollectionViewModel.h"
#import "UIImageView+RSAsyncLoading.h"
#import "RSVideoDetailViewController.h"

static NSString *const kVideoCellId = @"videoCell";

@interface RSVideoListViewController () <UICollectionViewDataSource>

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

    // enable inter active pop gesture
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) self;

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];

    if (self.channelTitle) {
        self.navigationItem.title = self.channelTitle;
    }

    __weak typeof(self) weakSelf = self;
    [self.collectionViewModel updateWithSuccess:^{
        [weakSelf.collectionView reloadData];
    }                                   failure:^(NSError *error) {

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
    }
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

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewModel.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RSVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellId forIndexPath:indexPath];
    RSVideoCollectionViewCellVo *item = self.collectionViewModel.items[(NSUInteger) indexPath.row];

    [cell.thumbnailImageView asynLoadingImageWithUrlString:item.mediumThumbnailUrl];

    cell.titleLabel.text = item.title;
    cell.titleLabel.font =  [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    cell.postedTimeLabel.text = item.postedTime;
    cell.postedTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    cell.channelLabel.text = item.channelTitle;


    cell.channelTitleView.tag = indexPath.row;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(channelTitleViewTapped:)];
    [cell.channelTitleView addGestureRecognizer:tapGestureRecognizer];

    cell.channelTitleView.hidden = [item.channelId isEqualToString:self.channelId];

    return cell;
}

@end