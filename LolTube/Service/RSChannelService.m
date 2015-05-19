//
// Created by 郭 輝平 on 9/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelService.h"


static NSString *const kAppVersionKey = @"appVersion";

@implementation RSChannelService {

}

- (NSArray *)channelIds {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    if (!channelIds) {
        NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
        channelIds = [cloudStore arrayForKey:kChannelIdsKey];
        if(channelIds){
            [self saveChannelIds:channelIds];
        } else{
            [self saveDefaultChannelIds];
        }
        [self p_saveAppVersion];
    }
    return [userDefaults arrayForKey:kChannelIdsKey];
}

- (void)saveDefaultChannelIds {
    NSArray *channelIds = @[@"UC2t5bjwHdUX4vM2g8TRDq5g", @"UCvqRdlKsE5Q8mf8YXbdIJLw", @"UClh5azhOaKzdlThQFgoq-tw", @"UC0RalGf69iYVBFteHInyJJg", @"UCUf53DHwoQw4SvETXZQ2Tmg", @"UCPOm2V7Ccdlkm2J1TqNptEw", @"UCrZT1akje889ZcVXDf9QkGg", @"UCGgbmTgF-sUJGd5B5N6VSFw",@"UCN078UFNwPgwWlU_V5WCTNw",@"UCc_7XbnN1bTFMhquCKt3ngA",@"UCVEbcFWM43PS-d5vaSKUMng",@"UCBJLvzKYBCQJc1buauA3msw",@"UCdOWyp25T0HDtjpnV2LpIyw",@"UChBb5BEX36y-DXK7uISYbzg",@"UC0NwzCHb8Fg89eTB5eYX17Q",@"UCARZJejxRnmQ0m_tU7MgRiA",@"UCuSrv3qgQA7SSi6R9bWag5A",@"UCtHosYGpdBx-X7uEkhJX7yg",@"UCudNGAQXzpE1sMfoqPs67mQ",@"UCYX9IB_lU43EenSWKDlheUg"];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    [userDefaults setObject:channelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:channelIds forKey:kChannelIdsKey];
    [cloudStore synchronize];
}

-(NSString *)p_appVersion{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    return [userDefaults stringForKey:kAppVersionKey];
}

-(void)p_saveAppVersion{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    [userDefaults setObject:@"1.2.0" forKey:kAppVersionKey];
    [userDefaults synchronize];
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

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:mutableChannelIds forKey:kChannelIdsKey];
    [cloudStore synchronize];
}

- (void)deleteChannelId:(NSString *)channelId {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    NSMutableArray *mutableChannelIds = channelIds.mutableCopy;

    [mutableChannelIds removeObjectAtIndex:[mutableChannelIds indexOfObject:channelId]];
    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:mutableChannelIds forKey:kChannelIdsKey];
    [cloudStore synchronize];
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

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:mutableChannelIds forKey:kChannelIdsKey];
    [cloudStore synchronize];
}


- (void)moveChannelId:(NSString *)channelId toIndex:(NSUInteger)index {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    NSMutableArray *mutableChannelIds = channelIds.mutableCopy;

    [mutableChannelIds removeObjectAtIndex:[mutableChannelIds indexOfObject:channelId]];
    [mutableChannelIds insertObject:channelId atIndex:index];

    [userDefaults setObject:mutableChannelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:mutableChannelIds forKey:kChannelIdsKey];
    [cloudStore synchronize];
}


@end