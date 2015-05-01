//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelTableViewModel.h"
#import "RSChannelModel.h"
#import "RSThumbnails.h"
#import "RSChannelService.h"
#import "LolTube-Swift.h"

@protocol RSChannelCollectionViewCellVo;

static NSArray <RSChannelTableViewCellVo> *itemsCache;

@interface RSChannelTableViewModel ()
@property(nonatomic, strong) YoutubeService *youtubeService;

@property(nonatomic, strong) RSChannelService *channelService;

@property(nonatomic, strong) NSArray *channelIds;

@end

@implementation RSChannelTableViewModel {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.youtubeService = [YoutubeService new];
        self.channelService = [[RSChannelService alloc] init];
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    if (itemsCache) {
        _items = itemsCache.copy;
        success();
        return;
    }
    self.channelIds = [self.channelService channelIds];

    [self.youtubeService channel:_channelIds success:^(RSChannelModel *channelModel) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

        RSChannelTableViewCellVo *allChannelsCellVo = [[RSChannelTableViewCellVo alloc] init];

        allChannelsCellVo.channelId = @"All Channels";
        allChannelsCellVo.title = @"All Channels";
        allChannelsCellVo.mediumThumbnailUrl = @"https://yt3.ggpht.com/-ZqOgMm5CVK0/AAAAAAAAAAI/AAAAAAAAAAA/RweX1_sFr1A/s240-c-k-no/photo.jpg";

        [items addObject:allChannelsCellVo];

        for (RSChannelItem *item in channelModel.items) {
            RSChannelTableViewCellVo *cellVo = [[RSChannelTableViewCellVo alloc] init];

            cellVo.channelId = item.channelId;
            cellVo.title = item.snippet.title;
            cellVo.mediumThumbnailUrl = item.snippet.thumbnails.medium.url;

            [items addObject:cellVo];
        }

        _items = (NSArray <RSChannelTableViewCellVo> *) items.copy;
        itemsCache = (NSArray <RSChannelTableViewCellVo> *) items.copy;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }                                  failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteChannelWithIndexPath:(NSIndexPath *)indexPath {
    RSChannelTableViewCellVo *cellVo = self.items[(NSUInteger) indexPath.row];
    [self.channelService deleteChannelId:cellVo.channelId];
    NSMutableArray *mutableItems = self.items.mutableCopy;
    [mutableItems removeObjectAtIndex:(NSUInteger) indexPath.row];

    _items = (id) mutableItems;
    itemsCache = (id) mutableItems;
}

- (void)moveChannelWithIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    RSChannelTableViewCellVo *cellVo = self.items[(NSUInteger) indexPath.row];

    [self.channelService moveChannelId:cellVo.channelId toIndex:(NSUInteger) (toIndexPath.row - 1)];

    NSMutableArray *mutableItems = self.items.mutableCopy;

    [mutableItems removeObjectAtIndex:(NSUInteger) indexPath.row];
    [mutableItems insertObject:cellVo atIndex:(NSUInteger) toIndexPath.row];

    _items = (id) mutableItems;
    itemsCache = (id) mutableItems;
}

+ (void)clearCache {
    itemsCache = nil;
}

@end

@implementation RSChannelTableViewCellVo

@end
