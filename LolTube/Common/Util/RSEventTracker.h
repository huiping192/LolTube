//
// Created by 郭 輝平 on 2/19/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//


@interface RSEventTracker : NSObject

+ (void)configure;

+ (void)trackVideoDetailShareWithVideoId:(NSString *)videoId;

+ (void)trackVideoDetailPlayWithVideoId:(NSString *)videoId;

+ (void)trackVideoListSearchWithSearchText:(NSString *)searchText;

+ (void)trackChannelListDeleteWithChannelId:(NSString *)channelId;
@end