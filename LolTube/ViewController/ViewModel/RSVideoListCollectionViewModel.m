//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoListCollectionViewModel.h"
#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "NSDate+RSFormatter.h"
#import "RSThumbnails.h"

@interface RSVideoListCollectionViewModel ()

@property(nonatomic, strong) RSYoutubeService *service;
@property(nonatomic, copy) NSArray *channelIds;

@property(nonatomic, copy) NSArray *searchModelList;

@end

@implementation RSVideoListCollectionViewModel {

}

- (instancetype)initWithChannelId:(NSString *)channelId {
    return [self initWithChannelIds:@[channelId]];
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
    }
    [self p_updateWithChannelIds:channelIds pageTokens:nextPageTokens searchText:self.searchText success:^{
        if(success){
           success(YES);
        }
    } failure:failure];
}

- (void)p_updateWithChannelIds:(NSArray *)channelIds pageTokens:(NSArray *)pageTokens searchText:(NSString *)searchText success:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service videoListWithChannelIds:channelIds searchText:searchText nextPageTokens:pageTokens success:^(NSArray *searchModelList) {
        self.searchModelList = searchModelList;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        if (self.items) {
            items = self.items.mutableCopy;
        }

        for (RSSearchModel *searchModel in searchModelList) {
            for (RSItem *item in searchModel.items) {
                RSVideoCollectionViewCellVo *cellVo = [[RSVideoCollectionViewCellVo alloc] init];
                cellVo.videoId = item.id.videoId;

                if ([items containsObject:cellVo]) {
                    continue;
                }
                cellVo.channelId = item.snippet.channelId;
                cellVo.channelTitle = item.snippet.channelTitle;
                cellVo.title = item.snippet.title;
                cellVo.highThumbnailUrl = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/maxresdefault.jpg", cellVo.videoId];
                cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url;

                cellVo.postedTime = [self p_postedTimeWithPublishedAt:item.snippet.publishedAt];
                cellVo.publishedAt = item.snippet.publishedAt;

                [items addObject:cellVo];
            }
        }

        _items = (NSArray <RSVideoCollectionViewCellVo> *) [self p_sortChannelItems:items];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }                             failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)p_postedTimeWithPublishedAt:(NSString *)publishedAt {
    NSString *publishedDateString = nil;

    NSDate *publishedDate = [NSDate dateFromISO8601String:publishedAt];
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:publishedDate];
    int timeDifferenceInHours = (int) (timeDifference / 3600);
    int timeDifferenceInMinutes = (int) ((timeDifference - timeDifferenceInHours) / 60);
    if (timeDifferenceInHours == 0) {
        publishedDateString = [NSString stringWithFormat:NSLocalizedString(@"VideoPostedTimeStringMinutesFormatter", nil), timeDifferenceInMinutes];
    } else if (timeDifferenceInHours < 24) {
        publishedDateString = [NSString stringWithFormat:NSLocalizedString(@"VideoPostedTimeStringHoursFormatter", nil), timeDifferenceInHours];
    } else {
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"EEEE,MMM d"];
        publishedDateString = [form stringFromDate:publishedDate];
    }

    return publishedDateString;
}


- (NSArray *)p_sortChannelItems:(NSArray *)items {
    NSMutableArray *mutableItems = items.mutableCopy;
    [mutableItems sortUsingComparator:^NSComparisonResult(RSVideoCollectionViewCellVo *item1, RSVideoCollectionViewCellVo *item2) {
        return [[NSDate dateFromISO8601String:item2.publishedAt] compare:[NSDate dateFromISO8601String:item1.publishedAt]];
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