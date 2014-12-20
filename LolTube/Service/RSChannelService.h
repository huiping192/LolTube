//
// Created by 郭 輝平 on 9/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kChannelIdsKey = @"channleIds";

static NSString *const kSharedUserDefaultsSuitName = @"group.com.huiping192.LolTube.channels";

@interface RSChannelService : NSObject

- (NSArray *)channelIds;

- (void)saveChannelId:(NSString *)channelId;
- (void)deleteChannelId:(NSString *)channelId;
- (void)saveChannelIds:(NSArray *)channelIds;

- (void)moveChannelId:(NSString *)channelId toIndex:(NSUInteger)index;
@end