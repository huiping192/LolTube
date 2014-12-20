//
// Created by 郭 輝平 on 10/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoService.h"

static NSTimeInterval const kDiffPlaybackTime = 5.0;

@interface RSVideoService ()

@property(nonatomic, strong) NSMutableDictionary *videoList;

@end

@implementation RSVideoService {

}

static RSVideoService *sharedInstance = nil;

+ (RSVideoService *)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}


- (void)configure {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.videoList = [[userDefaults dictionaryForKey:kPlayFinishedVideoIdsKey] mutableCopy];
    if (!self.videoList) {
        NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
        self.videoList = [[cloudStore dictionaryForKey:kPlayFinishedVideoIdsKey] mutableCopy];

        if(!self.videoList){
            self.videoList = [[NSMutableDictionary alloc] init];
        }
    }
}

- (BOOL)isPlayFinishedWithVideoId:(NSString *)videoId {
    return (self.videoList)[videoId] != nil;

}

- (void)savePlayFinishedVideoId:(NSString *)videoId {
    if ((self.videoList)[videoId] != nil) {
        return;
    }
    (self.videoList)[videoId] = @(0);

    [self save];
}

- (void)updateLastPlaybackTimeWithVideoId:(NSString *)videoId lastPlaybackTime:(NSTimeInterval)lastPlaybackTime {
    (self.videoList)[videoId] = @(lastPlaybackTime);

    [self save];
}

- (NSTimeInterval)lastPlaybackTimeWithVideoId:(NSString *)videoId {
    NSNumber *lastPlaybackTimeNumber = (self.videoList)[videoId];
    return lastPlaybackTimeNumber.floatValue - kDiffPlaybackTime > 0 ? lastPlaybackTimeNumber.floatValue - kDiffPlaybackTime : lastPlaybackTimeNumber.floatValue;
}

- (void)overrideVideoDataWithVideoDictionary:(NSDictionary *)videoDictionary {
    self.videoList = [videoDictionary mutableCopy];
    if (!self.videoList) {
        self.videoList = [[NSMutableDictionary alloc] init];
    }
    [self save];
}


- (void)save {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:self.videoList forKey:kPlayFinishedVideoIdsKey];
    [userDefaults synchronize];

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:self.videoList forKey:kPlayFinishedVideoIdsKey];
    [cloudStore synchronize];
}

@end