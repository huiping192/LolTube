//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewModel.h"
#import "RSYoutubeService.h"
#import "RSVideoModel.h"
#import "RSThumbnails.h"
#import "NSDate+RSFormatter.h"


@interface RSVideoDetailViewModel ()

@property(nonatomic, strong) RSYoutubeService *service;

@end

@implementation RSVideoDetailViewModel {

}

- (instancetype)initWithVideoId:(NSString *)videoId {
    self = [super init];
    if (self) {
        self.videoId = videoId;
        self.service = [[RSYoutubeService alloc] init];
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {

    [self.service videoWithVideoId:self.videoId success:^(RSVideoModel *videoModel) {
        if (!videoModel.items || videoModel.items.count == 0) {
            return;
        }

        RSVideoItem *videoItem = videoModel.items[0];

        self.description = videoItem.snippet.description;
        self.mediumThumbnailUrl = videoItem.snippet.thumbnails.medium.url;
        self.title = videoItem.snippet.title;
        self.postedTime = [self p_postedTimeWithPublishedAt:videoItem.snippet.publishedAt];

        self.shareTitle = [NSString stringWithFormat:@"%@ #LolTube",self.title];
        self.shareUrlString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",self.videoId];
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

- (NSString *)p_postedTimeWithPublishedAt:(NSString *)publishedAt {
    NSDate *publishedDate = [NSDate dateFromISO8601String:publishedAt];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy/MM/dd HH:mm"];
    form.locale = [NSLocale currentLocale];

    return [NSString stringWithFormat:NSLocalizedString(@"VideoDetailPostedAtFormatter", nil) , [form stringFromDate:publishedDate]];
}

@end