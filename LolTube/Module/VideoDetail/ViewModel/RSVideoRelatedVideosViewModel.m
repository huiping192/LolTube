//
// Created by 郭 輝平 on 12/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoRelatedVideosViewModel.h"
#import "RSSearchModel.h"
#import "RSThumbnails.h"
#import "NSString+Util.h"
#import "LolTube-Swift.h"
#import "RSVideoDetailModel.h"
#import "RSVideoInfoUtil.h"

@interface RSVideoRelatedVideosViewModel ()

@property(nonatomic, strong) YoutubeService *service;

@end

@implementation RSVideoRelatedVideosViewModel {

}
- (instancetype)initWithVideoId:(NSString *)videoId {
    self = [super init];
    if (self) {
        self.videoId = videoId;
        self.service = [YoutubeService new];
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self.service relatedVideoList:self.videoId success:^(RSSearchModel *searchModel) {
        self.relatedVideoList = [self p_itemsFormSearchModelList:searchModel.items];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }                                 failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSArray *)p_itemsFormSearchModelList:(NSArray *)searchModelList {
    NSMutableArray *newItems = [[NSMutableArray alloc] init];
    for (RSItem *item in searchModelList) {
        RSRelatedVideoCollectionViewCellVo *cellVo = [[RSRelatedVideoCollectionViewCellVo alloc] init];
        cellVo.videoId = item.id.videoId;
        cellVo.title = item.snippet.title;
        cellVo.channelTitle = item.snippet.channelTitle;
        cellVo.thumbnailImageUrl = item.snippet.thumbnails.medium.url;

        [newItems addObject:cellVo];
    }

    return newItems;
}

- (void)updateVideoDetailWithCellVo:(RSRelatedVideoCollectionViewCellVo *)cellVo  success:(void (^)())success failure:(void (^)(NSError *))failure {
    if(!cellVo){
        return;
    }
    [self.service videoDetailList:@[cellVo.videoId] success:^(RSVideoDetailModel *videoDetailModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(videoDetailModel.items.count != 1){
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
    }                                 failure:failure];
}
@end

@implementation RSRelatedVideoCollectionViewCellVo

@end