//
// Created by 郭 輝平 on 2/19/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

#import "RSEventTracker.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

static NSString *const kReleaseTrackingId = @"UA-56633617-1";
static NSString *const kDevelopmentTrackingId = @"UA-56633617-2";

@implementation RSEventTracker {

}

+ (void)configure {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
#if DEBUG
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:kDevelopmentTrackingId];
#else
    [[GAI sharedInstance] trackerWithTrackingId:kReleaseTrackingId];
#endif
}

+ (void)trackVideoDetailShareWithVideoId:(NSString *)videoId {
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail" action:@"video_share" label:videoId value:nil] build]];
}

+ (void)trackVideoDetailPlayWithVideoId:(NSString *)videoId {
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"video_detail" action:@"video_play" label:videoId value:nil] build]];
}

+ (void)trackVideoListSearchWithSearchText:(NSString *)searchText {
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"video_list" action:@"video_search" label:searchText value:nil] build]];
}

+ (void)trackChannelListDeleteWithChannelId:(NSString *)channelId {
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"channel_list" action:@"channel_delete" label:channelId value:nil] build]];
}

@end