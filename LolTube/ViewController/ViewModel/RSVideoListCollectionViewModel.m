//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListCollectionViewModel.h"
#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "NSDate+RSFormatter.h"
#import "RSThumbnails.h"
#import "NSString+Util.h"

@interface RSVideoListCollectionViewModel ()

@property(nonatomic, strong) RSYoutubeService *service;
@property(nonatomic, copy) NSArray *channelIds;

@property(nonatomic, copy) NSArray *searchModelList;

@end

@implementation RSVideoListCollectionViewModel {

}
- (instancetype)initWithChannelIds:(NSArray *)channelIds {
    self = [super init];
    if (self) {
        _channelIds = channelIds;
        _service = [[RSYoutubeService alloc] init];
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
    [self.service videoListWithChannelIds:_channelIds searchText:self.searchText nextPageTokens:nil success:^(NSArray *searchModelList) {
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
    }                             failure:failure];
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
    [self.service videoListWithChannelIds:channelIds searchText:searchText nextPageTokens:pageTokens success:^(NSArray *searchModelList) {
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
    }                             failure:failure];
}

- (void)updateVideoDetailWithCellVo:(RSVideoCollectionViewCellVo *)cellVo  success:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service videoDetailListWithVideoIds:@[cellVo.videoId] success:^(RSVideoDetailModel *videoDetailModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(videoDetailModel.items.count != 1){
                return;
            }
            RSVideoDetailItem *detailItem = videoDetailModel.items[0];
            cellVo.duration = [self p_convertVideoDuration:detailItem.contentDetails.duration];

            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
            NSString *formatted = [formatter stringFromNumber:@(detailItem.statistics.viewCount.intValue)];

            cellVo.viewCount = [NSString stringWithFormat:NSLocalizedString(@"VideoViewCountFormat", @"%@ views"), formatted];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
        });
    }                                 failure:failure];
}

-(NSString *)p_convertVideoDuration:(NSString *)duration{
    NSString *hour = nil;
    NSString *minute = nil;
    NSString *second = nil;

    NSArray *durationSpilt = [duration componentsSeparatedByString:@"PT"];
    if (durationSpilt.count != 2) {
        return nil;
    }
    NSString *hms = durationSpilt[1];
    NSString *ms = durationSpilt[1];
    NSString *s = durationSpilt[1];

    if ([hms indexOf:@"H"] >= 0) {
        NSArray *hourSpilt = [hms componentsSeparatedByString:@"H"];
        if (hourSpilt.count == 2) {
            hour = hourSpilt[0];
            ms = hourSpilt[1];
        }
    }

    if ([ms indexOf:@"M"] >= 0) {
        NSArray *minuteSpilt = [ms componentsSeparatedByString:@"M"];
        if (minuteSpilt.count == 2) {
            minute = minuteSpilt[0];
            s = minuteSpilt[1];
        }
    }

    if ([s indexOf:@"S"] >= 0) {
        NSArray *secondSpilt = [s componentsSeparatedByString:@"S"];
        if (secondSpilt.count > 1) {
            second = secondSpilt[0];
        }
    }

    int mInt = minute.intValue;
    if (mInt < 10) {
        minute = [NSString stringWithFormat:@"0%d", mInt];
    }
    int sInt = second.intValue;
    if (sInt < 10) {
        second = [NSString stringWithFormat:@"0%d", sInt];
    }

    minute = minute ? minute : @"00";
    second = second ? second : @"00";

    if (hour) {
        return [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    } else {
        return [NSString stringWithFormat:@"%@:%@", minute, second];
    }
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