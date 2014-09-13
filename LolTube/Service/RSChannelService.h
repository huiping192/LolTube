//
// Created by 郭 輝平 on 9/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


@interface RSChannelService : NSObject

- (NSArray *)channelIds;

- (void)saveChannelId:(NSString *)channelId;
- (void)saveChannelIds:(NSArray *)channelIds;

- (void)moveChannelId:(NSString *)channelId toIndex:(NSUInteger)index;
@end