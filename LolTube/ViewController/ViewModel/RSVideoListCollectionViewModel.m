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

@property(nonatomic, copy) NSArray *nextPageTokens;

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
        _nextPageTokens = nil;
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    _items = nil;
    [self p_updateWithPageTokens:nil success:success failure:failure];
}

- (void)updateNextPageDataWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self p_updateWithPageTokens:self.nextPageTokens success:success failure:failure];
}

- (void)p_updateWithPageTokens:(NSArray *)pageTokens success:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service videoListWithChannelIds:_channelIds nextPageTokens:pageTokens success:^(RSSearchModel *searchModel) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        if (self.items) {
            items = self.items.mutableCopy;
        }

        self.nextPageTokens = [searchModel.nextPageToken componentsSeparatedByString:@","];
        for (RSItem *item in searchModel.items) {
            RSVideoCollectionViewCellVo *cellVo = [[RSVideoCollectionViewCellVo alloc] init];

            cellVo.videoId = item.id.videoId;
            cellVo.channelId = item.snippet.channelId;
            cellVo.channelTitle = item.snippet.channelTitle;
            cellVo.title = item.snippet.title;
            cellVo.highThumbnailUrl = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/maxresdefault.jpg", cellVo.videoId];
            cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url;

            cellVo.postedTime = [self p_postedTimeWithPublishedAt:item.snippet.publishedAt];

            [items addObject:cellVo];
        }

        _items = (NSArray <RSVideoCollectionViewCellVo> *) items.copy;

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
@end

@implementation RSVideoCollectionViewCellVo

@end