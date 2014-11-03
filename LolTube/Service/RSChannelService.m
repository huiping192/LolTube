//
// Created by 郭 輝平 on 9/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelService.h"

static NSString *const kChannelIdsKey = @"channleIds";

@implementation RSChannelService {

}

- (NSArray *)channelIds {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    if (!channelIds) {
        [self saveDefaultChannelIds];
    }
    return [userDefaults arrayForKey:kChannelIdsKey];
}

- (void)saveDefaultChannelIds {
    NSArray *channelIds = @[@"UC2t5bjwHdUX4vM2g8TRDq5g", @"UCKDkGnyeib7mcU7LdD3x0jQ", @"UCvqRdlKsE5Q8mf8YXbdIJLw", @"UCUf53DHwoQw4SvETXZQ2Tmg", @"UC_ZIX-h-BIZZnim6YJSjYDA", @"UCGgbmTgF-sUJGd5B5N6VSFw", @"UClh5azhOaKzdlThQFgoq-tw", @"UC0RalGf69iYVBFteHInyJJg"];
    [self saveChannelIds:channelIds];
}

- (void)saveChannelId:(NSString *)channelId {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    if (!channelIds) {
        channelIds = [[NSArray alloc] init];
    }
    NSMutableArray *mutableChannelIds = channelIds.mutableCopy;
    [mutableChannelIds addObject:channelId];

    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];

}

- (void)deleteChannelId:(NSString *)channelId {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    NSMutableArray *mutableChannelIds = channelIds.mutableCopy;

    [mutableChannelIds removeObjectAtIndex:[mutableChannelIds indexOfObject:channelId]];
    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];
}

- (void)saveChannelIds:(NSArray *)channelIds {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *savedChannelIds = [userDefaults arrayForKey:kChannelIdsKey];
    if (!savedChannelIds) {
        savedChannelIds = [[NSArray alloc] init];
    }
    NSMutableArray *mutableChannelIds = savedChannelIds.mutableCopy;
    [mutableChannelIds addObjectsFromArray:channelIds];

    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];
}


- (void)moveChannelId:(NSString *)channelId toIndex:(NSUInteger)index {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    NSMutableArray *mutableChannelIds = channelIds.mutableCopy;

    [mutableChannelIds removeObjectAtIndex:[mutableChannelIds indexOfObject:channelId]];
    [mutableChannelIds insertObject:channelId atIndex:index];

    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];
}


@end