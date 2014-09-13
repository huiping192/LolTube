//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelTableViewModel.h"
#import "RSYoutubeService.h"
#import "RSChannelModel.h"
#import "RSThumbnails.h"
#import "RSChannelService.h"

@protocol RSChannelCollectionViewCellVo;

@interface RSChannelTableViewModel ()
@property(nonatomic, strong) RSYoutubeService *youtubeService;

@property(nonatomic, strong) RSChannelService *channelService;

@property(nonatomic, strong) NSArray *channelIds;

@end

@implementation RSChannelTableViewModel {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.youtubeService = [[RSYoutubeService alloc] init];
        self.channelService = [[RSChannelService alloc] init];
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    self.channelIds =  [self.channelService channelIds];

    [self.youtubeService channelWithChannelIds:_channelIds success:^(RSChannelModel *channelModel) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

        RSChannelTableViewCellVo *allChannelsCellVo = [[RSChannelTableViewCellVo alloc] init];

        //cellVo.channelId = item.id;
        allChannelsCellVo.title = @"All Channels";
        allChannelsCellVo.mediumThumbnailUrl = @"https://yt3.ggpht.com/-ZqOgMm5CVK0/AAAAAAAAAAI/AAAAAAAAAAA/RweX1_sFr1A/s240-c-k-no/photo.jpg\"";

        [items addObject:allChannelsCellVo];

        for (RSChannelItem *item in channelModel.items) {
            RSChannelTableViewCellVo *cellVo = [[RSChannelTableViewCellVo alloc] init];

            cellVo.channelId = item.id;
            cellVo.title = item.snippet.title;
            cellVo.mediumThumbnailUrl = item.snippet.thumbnails.medium.url;

            [items addObject:cellVo];
        }

        _items = (NSArray <RSChannelCollectionViewCellVo> *) items.copy;

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

@end

@implementation RSChannelTableViewCellVo

@end
