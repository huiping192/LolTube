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
            cellVo.duration = [self p_convertVideoDuration:detailItem.contentDetails.duration];

            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
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

@end

@implementation RSRelatedVideoCollectionViewCellVo

@end