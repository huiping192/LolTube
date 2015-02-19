//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailViewModel.h"
#import "RSYoutubeService.h"
#import "RSVideoModel.h"
#import "RSThumbnails.h"
#import "NSDate+RSFormatter.h"
#import "RSSearchModel.h"


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

        self.shareUrlString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoId];
        self.handoffUrlStringFormat = @"https://www.youtube.com/watch?v=%@&t=%ds";
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    __weak typeof(self) weakSelf = self;
    [self.service videoWithVideoId:self.videoId success:^(RSVideoModel *videoModel) {
        if (!videoModel.items || videoModel.items.count == 0) {
            return;
        }

        RSVideoItem *videoItem = videoModel.items[0];

        weakSelf.shareTitle = [NSString stringWithFormat:@"%@ #LolTube", videoItem.snippet.title];
        weakSelf.highThumbnailImageUrl = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/maxresdefault.jpg", weakSelf.videoId];
        weakSelf.defaultThumbnailImageUrl = videoItem.snippet.thumbnails.medium.url;

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

@end
