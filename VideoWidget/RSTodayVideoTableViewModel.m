//
// Created by 郭 輝平 on 11/1/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSTodayVideoTableViewModel.h"
#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "RSThumbnails.h"


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
- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service todayVideoListWithChannelIds:self.channelIds success:^(NSArray *searchModelList) {
        NSMutableArray *items = [[NSMutableArray alloc] init];

        for (RSSearchModel *searchModel in searchModelList) {
            for (RSItem *item in searchModel.items) {
                RSVideoListTableViewCellVo *cellVo = [[RSVideoListTableViewCellVo alloc] init];
                cellVo.videoId = item.id.videoId;
                cellVo.title = item.snippet.title;
                cellVo.highThumbnailUrl = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/maxresdefault.jpg", cellVo.videoId];
                cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url;

                [items addObject:cellVo];
            }
        }

        if(items.count == 0){
            RSVideoListTableViewCellVo *cellVo = [[RSVideoListTableViewCellVo alloc] init];
            cellVo.title = NSLocalizedString(@"VideoWidgetNoVideos", @"no videos");
            [items addObject:cellVo];
        }

        _items = (NSArray <RSVideoListTableViewCellVo> *) items;

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

@end

@implementation RSVideoListTableViewCellVo

@end