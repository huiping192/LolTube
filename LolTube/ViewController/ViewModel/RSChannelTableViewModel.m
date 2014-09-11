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

        self.data = @[ @"UC2t5bjwHdUX4vM2g8TRDq5g",@"UCKDkGnyeib7mcU7LdD3x0jQ", @"UCvqRdlKsE5Q8mf8YXbdIJLw"];

    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service channelWithChannelIds:_data success:^(RSChannelModel *channelModel) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

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
