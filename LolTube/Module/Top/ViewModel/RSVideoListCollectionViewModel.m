//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListCollectionViewModel.h"
#import "RSSearchModel.h"
#import "NSDate+RSFormatter.h"
#import "RSThumbnails.h"
#import "LolTube-Swift.h"
#import "RSVideoDetailModel.h"
#import "RSVideoInfoUtil.h"

@interface RSVideoListCollectionViewModel ()

@property(nonatomic, strong) YoutubeService *service;
@property(nonatomic, copy) NSArray *channelIds;

@property(nonatomic, copy) NSArray *searchModelList;

@end

@implementation RSVideoListCollectionViewModel {

}
- (instancetype)initWithChannelIds:(NSArray *)channelIds {
    self = [super init];
    if (self) {
        _channelIds = channelIds;
        _service = [YoutubeService new];
        _searchModelList = nil;
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    _items = nil;
    [self p_updateWithChannelIds:_channelIds pageTokens:nil searchText:self.searchText success:success failure:failure];
}

- (void)refreshWithSuccess:(void (^)(BOOL hasNewData))success failure:(void (^)(NSError *))failure {
    __weak typeof(self) weakSelf = self;
    [self.service videoList:_channelIds searchText:self.searchText nextPageTokenList:nil success:^(NSArray *searchModelList) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSMutableArray *items = [[NSMutableArray alloc] init];
            if (weakSelf.items) {
                items = weakSelf.items.mutableCopy;
            }

            NSArray *newItems = [weakSelf p_itemsFormSearchModelList:searchModelList desc:NO];
            for (RSVideoCollectionViewCellVo *cellVo in newItems) {
                if (![items containsObject:cellVo]) {
                    [items insertObject:cellVo atIndex:0];
                }
            }

            BOOL hasNewData = _items.count != items.count;
            _items = (NSArray <RSVideoCollectionViewCellVo> *) items;

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(hasNewData);
                }
            });
        });
    }               failure:failure];
}

- (void)updateNextPageDataWithSuccess:(void (^)(BOOL hasNewData))success failure:(void (^)(NSError *))failure {
    NSMutableArray *nextPageTokens = [[NSMutableArray alloc] init];
    NSMutableArray *channelIds = [[NSMutableArray alloc] init];
    for (RSSearchModel *searchModel in self.searchModelList) {
        if (searchModel.items.count > 0 && searchModel.nextPageToken) {
            RSItem *item = searchModel.items[0];
            [channelIds addObject:item.snippet.channelId];
            [nextPageTokens addObject:searchModel.nextPageToken];
        }
    }

    if (channelIds.count == 0) {
        success(NO);
        return;
    }
    [self p_updateWithChannelIds:channelIds pageTokens:nextPageTokens searchText:self.searchText success:^{
        if (success) {
            success(YES);
        }
    }                    failure:failure];
}

- (void)p_updateWithChannelIds:(NSArray *)channelIds pageTokens:(NSArray *)pageTokens searchText:(NSString *)searchText success:(void (^)())success failure:(void (^)(NSError *))failure {
    __weak typeof(self) weakSelf = self;
    [self.service videoList:channelIds searchText:searchText nextPageTokenList:pageTokens success:^(NSArray *searchModelList) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.searchModelList = searchModelList;

            NSMutableArray *items = [[NSMutableArray alloc] init];
            if (weakSelf.items) {
                items = weakSelf.items.mutableCopy;
            }

            NSArray *newItems = [self p_itemsFormSearchModelList:searchModelList desc:YES];
            for (RSVideoCollectionViewCellVo *cellVo in newItems) {
                if (![items containsObject:cellVo]) {
                    [items addObject:cellVo];
                }
            }

            _items = (NSArray <RSVideoCollectionViewCellVo> *) items;

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
        });
    }               failure:failure];
}

- (void)updateVideoDetailWithCellVo:(RSVideoCollectionViewCellVo *)cellVo success:(void (^)())success failure:(void (^)(NSError *))failure {
    // use cache data when already have video detail data
    if (cellVo.duration && cellVo.viewCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
        return;
    }

    [self.service videoDetailList:@[cellVo.videoId] success:^(RSVideoDetailModel *videoDetailModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (videoDetailModel.items.count != 1) {
                return;
            }
            RSVideoDetailItem *detailItem = videoDetailModel.items[0];
            cellVo.duration = [RSVideoInfoUtil convertVideoDuration:detailItem.contentDetails.duration];
            cellVo.viewCount = [RSVideoInfoUtil convertVideoViewCount:detailItem.statistics.viewCount.intValue];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
        });
    }                     failure:failure];
}

- (NSArray *)p_itemsFormSearchModelList:(NSArray *)searchModelList desc:(BOOL)desc {
    NSMutableArray *newItems = [[NSMutableArray alloc] init];

    for (RSSearchModel *searchModel in searchModelList) {
        for (RSItem *item in searchModel.items) {
            RSVideoCollectionViewCellVo *cellVo = [[RSVideoCollectionViewCellVo alloc] init];
            cellVo.videoId = item.id.videoId;

            if ([newItems containsObject:cellVo]) {
                continue;
            }
            cellVo.channelId = item.snippet.channelId;
            cellVo.channelTitle = item.snippet.channelTitle;
            cellVo.title = item.snippet.title;
            cellVo.highThumbnailUrl = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/maxresdefault.jpg", cellVo.videoId];
            cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url;

            cellVo.publishedAt = item.snippet.publishedAt;

            [newItems addObject:cellVo];
        }
    }

    return [self p_sortChannelItems:newItems desc:desc];
}

- (NSArray *)p_sortChannelItems:(NSArray *)items desc:(BOOL)desc {
    NSMutableArray *mutableItems = items.mutableCopy;
    [mutableItems sortUsingComparator:^NSComparisonResult(RSVideoCollectionViewCellVo *item1, RSVideoCollectionViewCellVo *item2) {
        return desc ? [[NSDate dateFromISO8601String:item2.publishedAt] compare:[NSDate dateFromISO8601String:item1.publishedAt]] : [[NSDate dateFromISO8601String:item1.publishedAt] compare:[NSDate dateFromISO8601String:item2.publishedAt]];
    }];
    return mutableItems;
}
@end

@implementation RSVideoCollectionViewCellVo
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass:[RSVideoCollectionViewCellVo class]]) {
        return [self.videoId isEqualToString:((RSVideoCollectionViewCellVo *) object).videoId];
    }

    return NO;
}
@end