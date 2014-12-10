//
// Created by 郭 輝平 on 9/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelService.h"

static NSString *const kChannelIdsKey = @"channleIds";

static NSString *const kAppVersionKey = @"appVersion";

@implementation RSChannelService {

}

- (NSArray *)channelIds {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    NSArray *channelIds = [userDefaults arrayForKey:kChannelIdsKey];
    NSString *appVersion = [self p_appVersion];
    if (!channelIds || !appVersion) {
        [self saveDefaultChannelIds];
        [self p_saveAppVersion];
    }
    return [userDefaults arrayForKey:kChannelIdsKey];
}

- (void)saveDefaultChannelIds {
    NSArray *channelIds = @[@"UC2t5bjwHdUX4vM2g8TRDq5g", @"UCvqRdlKsE5Q8mf8YXbdIJLw", @"UClh5azhOaKzdlThQFgoq-tw", @"UC0RalGf69iYVBFteHInyJJg", @"UCUf53DHwoQw4SvETXZQ2Tmg", @"UCPOm2V7Ccdlkm2J1TqNptEw", @"UCrZT1akje889ZcVXDf9QkGg", @"UCGgbmTgF-sUJGd5B5N6VSFw", @"UC0t-xbEmmcJBQ6-fTZV2FNA",@"UCN078UFNwPgwWlU_V5WCTNw",@"UCc_7XbnN1bTFMhquCKt3ngA",@"UC6Y5ISL5xuPuV2--cEKbt6A",@"UCK4LHLRdoHlYL6unEAuTyqA",@"UCVEbcFWM43PS-d5vaSKUMng",@"UCGeHk-_K6Lee4CcVN2SKI2A",@"UCKDkGnyeib7mcU7LdD3x0jQ",@"UCBJLvzKYBCQJc1buauA3msw",@"UCdOWyp25T0HDtjpnV2LpIyw",@"UChBb5BEX36y-DXK7uISYbzg",@"UCQvdvLBve3JLBTkISSHOpEA",@"UC9YLd0REiXxLqQQH_CpJKZQ",@"UC0NwzCHb8Fg89eTB5eYX17Q",@"UCARZJejxRnmQ0m_tU7MgRiA",@"UCrrSA2uXHnFom2HQgNmUivw",@"UCCANEvHoWMJGpMNkxpM3KLg",@"UCuSrv3qgQA7SSi6R9bWag5A",@"UCtHosYGpdBx-X7uEkhJX7yg",@"UCudNGAQXzpE1sMfoqPs67mQ",@"UCYX9IB_lU43EenSWKDlheUg",];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    [userDefaults setObject:channelIds forKey:kChannelIdsKey];
    [userDefaults synchronize];
}

-(NSString *)p_appVersion{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    return [userDefaults stringForKey:kAppVersionKey];
}

-(void)p_saveAppVersion{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
    [userDefaults setObject:@"1.1.0" forKey:kAppVersionKey];
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