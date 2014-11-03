//
// Created by 郭 輝平 on 11/1/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSTodayVideoTableViewModel.h"
#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "RSThumbnails.h"
#import "RSChannelService.h"

static NSString *const kVideoWidgetCacheKey = @"videoWidgetCache";

@interface RSTodayVideoTableViewModel ()

@property(nonatomic, strong) RSYoutubeService *service;
@property(nonatomic, copy) NSArray *channelIds;

@end

@implementation RSTodayVideoTableViewModel {

}
- (instancetype)initWithChannelIds:(NSArray *)channelIds {
    self = [super init];
    if (self) {
        _channelIds = channelIds;
        _service = [[RSYoutubeService alloc] init];
    }

    return self;
}

- (void)updateCacheDataWithSuccess:(void (^)(BOOL hasCacheData))success {
    NSArray <RSVideoListTableViewCellVo> *cacheData = [self p_videoCache];
    _items = cacheData;
    success(cacheData != nil);
}

- (NSArray <RSVideoListTableViewCellVo> *)p_videoCache {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSData *archivedServerModules = [userDefaults objectForKey:kVideoWidgetCacheKey];
    NSArray *videoCache = [NSKeyedUnarchiver unarchiveObjectWithData:archivedServerModules];

    return (NSArray <RSVideoListTableViewCellVo> *) videoCache;
}

- (void)p_saveVideoCache:(NSArray *)videoData {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSData *archivedServerModules = [NSKeyedArchiver archivedDataWithRootObject:videoData];
    [userDefaults setObject:archivedServerModules forKey:kVideoWidgetCacheKey];
    [userDefaults synchronize];
}

- (void)updateWithSuccess:(void (^)(BOOL hasNewData))success failure:(void (^)(NSError *))failure {
    [self.service todayVideoListWithChannelIds:self.channelIds success:^(NSArray *searchModelList) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

        for (RSSearchModel *searchModel in searchModelList) {
            for (RSItem *item in searchModel.items) {
                RSVideoListTableViewCellVo *cellVo = [[RSVideoListTableViewCellVo alloc] init];
                cellVo.videoId = item.id.videoId;
                cellVo.title = item.snippet.title;
                cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url;

                [items addObject:cellVo];
            }
        }

        if (items.count == 0) {
            RSVideoListTableViewCellVo *cellVo = [[RSVideoListTableViewCellVo alloc] init];
            cellVo.title = NSLocalizedString(@"VideoWidgetNoVideos", @"no videos");
            [items addObject:cellVo];
        }

        NSArray *newItems = items;
        if (newItems.count > 5) {
            newItems = [newItems objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
        }
        BOOL hasNewData = YES;
        if (_items.count == newItems.count) {
            hasNewData = NO;
        }
        _items = (NSArray <RSVideoListTableViewCellVo> *) newItems;
        [self p_saveVideoCache:newItems];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(hasNewData);
            }
        });
    }                                  failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end

@implementation RSVideoListTableViewCellVo
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.videoId forKey:@"videoId"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.defaultThumbnailUrl forKey:@"defaultThumbnailUrl"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.videoId = [decoder decodeObjectForKey:@"videoId"];
    self.title = [decoder decodeObjectForKey:@"title"];
    self.defaultThumbnailUrl = [decoder decodeObjectForKey:@"defaultThumbnailUrl"];
    return self;
}
@end