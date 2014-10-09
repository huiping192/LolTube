//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


@interface RSVideoListViewController : UIViewController

@property(nonatomic, copy) NSArray *channelIds;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) BOOL needShowChannelTitleView;

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

- (UICollectionViewCell *)selectedCell;

- (NSIndexPath *)indexPathWithVideoId:(NSString *)videoId;

// background fetch
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
@end