//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelTableViewModel.h"
#import "RSYoutubeService.h"
#import "RSChannelModel.h"
#import "RSThumbnails.h"

@protocol RSChannelCollectionViewCellVo;

@interface RSChannelTableViewModel ()
@property(nonatomic, strong) RSYoutubeService *service;

@property(nonatomic, strong) NSArray *data;

@end

@implementation RSChannelTableViewModel {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.service = [[RSYoutubeService alloc] init];

        self.data = @[ @"UC2t5bjwHdUX4vM2g8TRDq5g",@"UCKDkGnyeib7mcU7LdD3x0jQ", @"UCvqRdlKsE5Q8mf8YXbdIJLw",@"UC_ZIX-h-BIZZnim6YJSjYDA",@"UCRFvOeB8L5bXeIUVFlHuItA",@"UCa7ycmkvToNPa1hpmLfvkyA",@"UCGgbmTgF-sUJGd5B5N6VSFw",@"UClh5azhOaKzdlThQFgoq-tw",@"UC0RalGf69iYVBFteHInyJJg"];

    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service channelWithChannelIds:_data success:^(RSChannelModel *channelModel) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

        RSChannelTableViewCellVo *allChannelsCellVo = [[RSChannelTableViewCellVo alloc] init];

        //cellVo.channelId = item.id;
        allChannelsCellVo.title = @"All Channels";
        allChannelsCellVo.mediumThumbnailUrl =@"https://yt3.ggpht.com/-ZqOgMm5CVK0/AAAAAAAAAAI/AAAAAAAAAAA/RweX1_sFr1A/s240-c-k-no/photo.jpg\"";

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
    }                            failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end

@implementation RSChannelTableViewCellVo

@end
