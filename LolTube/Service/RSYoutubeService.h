//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


@class RSSearchModel;
@class RSVideoModel;
@class RSChannelModel;

@interface RSYoutubeService : NSObject

- (void)videoListWithChannelId:(NSString *)channelId searchText:(NSString *)searchText nextPageToken:(NSString *)nextPageToken success:(void (^)(RSSearchModel *))success failure:(void (^)(NSError *))failure;

- (void)videoListWithChannelIds:(NSArray *)channelIds searchText:(NSString *)searchText nextPageTokens:(NSArray *)nextPageTokens success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

- (void)videoWithVideoId:(NSString *)videoId success:(void (^)(RSVideoModel *))success failure:(void (^)(NSError *))failure;

- (void)channelWithChannelIds:(NSArray *)channelIds success:(void (^)(RSChannelModel *))success failure:(void (^)(NSError *))failure;

- (void)channelWithSearchText:(NSString *)searchText nextPageToken:(NSString *)nextPageToken success:(void (^)(RSSearchModel *))success failure:(void (^)(NSError *))failure;

@end