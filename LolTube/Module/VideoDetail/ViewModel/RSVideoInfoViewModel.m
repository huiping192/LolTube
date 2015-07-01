//
// Created by 郭 輝平 on 12/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoInfoViewModel.h"
#import "RSVideoModel.h"
#import "NSDate+RSFormatter.h"
#import "LolTube-Swift.h"
#import "RSVideoDetailModel.h"

@interface RSVideoInfoViewModel ()

@property(nonatomic, strong) YoutubeService *service;

@end

@implementation RSVideoInfoViewModel {

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
    __weak typeof(self) weakSelf = self;
    [self.service video:self.videoId success:^(RSVideoModel *videoModel) {
        if (!videoModel.items || videoModel.items.count == 0) {
            return;
        }

        RSVideoItem *videoItem = videoModel.items[0];

        weakSelf.videoDescription = videoItem.snippet.videoDescription;
        weakSelf.title = videoItem.snippet.title;
        weakSelf.postedTime = [weakSelf p_postedTimeWithPublishedAt:videoItem.snippet.publishedAt];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }                      failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)updateVideoDetailWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    __weak typeof(self) weakSelf = self;
    [self.service videoDetailList:@[self.videoId] success:^(RSVideoDetailModel *videoDetailModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(videoDetailModel.items.count != 1){
                return;
            }
            RSVideoDetailItem *detailItem = videoDetailModel.items[0];

            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSString *formatted = [formatter stringFromNumber:@(detailItem.statistics.viewCount.intValue)];
            weakSelf.viewCount = [NSString stringWithFormat:NSLocalizedString(@"VideoViewCountFormat", @"%@ views"), formatted];

            NSString *likeCount = [formatter stringFromNumber:@(detailItem.statistics.likeCount.intValue)];
            NSString *dislikeCount = [formatter stringFromNumber:@(detailItem.statistics.dislikeCount.intValue)];
            weakSelf.rate = [NSString stringWithFormat:NSLocalizedString(@"VideoLikeDislikeFormat", @"%@ likes, %@ dislikes"), likeCount, dislikeCount];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
        });
    }                                 failure:failure];
}


- (NSString *)p_postedTimeWithPublishedAt:(NSString *)publishedAt {
    NSDate *publishedDate = [NSDate dateFromISO8601String:publishedAt];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy/MM/dd HH:mm"];
    form.locale = [NSLocale currentLocale];

    return [NSString stringWithFormat:NSLocalizedString(@"VideoDetailPostedAtFormatter", nil), [form stringFromDate:publishedDate]];
}


@end