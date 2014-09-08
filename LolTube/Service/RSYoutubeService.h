//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


@class RSSearchModel;

@interface RSYoutubeService : NSObject

- (void)videoListWithChannelId:(NSString *)channelId success:(void (^)(RSSearchModel *))success failure:(void (^)(NSError *))failure;
@end