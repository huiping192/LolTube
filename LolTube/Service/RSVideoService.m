//
// Created by 郭 輝平 on 10/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoService.h"

static NSTimeInterval const kDiffPlaybackTime = 5.0;
static int const kMaxItemCount = 49;

@interface RSVideoService ()

@property(nonatomic, strong) NSMutableDictionary *videoDictionary;
@property(nonatomic, strong) NSMutableArray *videoIdList;

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
    self.videoDictionary = [[userDefaults dictionaryForKey:kPlayFinishedVideoIdsKey] mutableCopy];
    if (!self.videoDictionary) {
        NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
        self.videoDictionary = [[cloudStore dictionaryForKey:kPlayFinishedVideoIdsKey] mutableCopy];

        if(!self.videoDictionary){
            self.videoDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    
    self.videoIdList = [[userDefaults stringArrayForKey:kHistoryVideoIdsKey] mutableCopy];
    if(!self.videoIdList){
        self.videoIdList = [[NSMutableArray alloc] init];
    }
}

- (BOOL)isPlayFinishedWithVideoId:(NSString *)videoId {
    return (self.videoDictionary)[videoId] != nil;

}

-(void)saveHistoryVideoId:(NSString *)videoId{
    if([self.videoIdList containsObject:videoId]){
        [self.videoIdList removeObject:videoId];
    }
    
    if(self.videoIdList.count >= kMaxItemCount){
        [self.videoIdList removeObjectAtIndex:0];
    }
    [self.videoIdList addObject:videoId];
}

- (void)savePlayFinishedVideoId:(NSString *)videoId {
    if ((self.videoDictionary)[videoId] != nil) {
        return;
    }
    if(self.videoDictionary.count >= kMaxItemCount){
        [self.videoDictionary removeObjectForKey:self.videoDictionary.allKeys[0]];
    }
    
    (self.videoDictionary)[videoId] = @(0);
    
    [self save];
}

- (void)updateLastPlaybackTimeWithVideoId:(NSString *)videoId lastPlaybackTime:(NSTimeInterval)lastPlaybackTime {
    (self.videoDictionary)[videoId] = @(lastPlaybackTime);

    [self save];
}

- (NSTimeInterval)lastPlaybackTimeWithVideoId:(NSString *)videoId {
    NSNumber *lastPlaybackTimeNumber = (self.videoDictionary)[videoId];
    return lastPlaybackTimeNumber.floatValue - kDiffPlaybackTime > 0 ? lastPlaybackTimeNumber.floatValue - kDiffPlaybackTime : lastPlaybackTimeNumber.floatValue;
}

- (void)overrideVideoDataWithVideoDictionary:(NSDictionary *)videoDictionary {
    self.videoDictionary = [videoDictionary mutableCopy];
    if (!self.videoDictionary) {
        self.videoDictionary = [[NSMutableDictionary alloc] init];
    }
    [self save];
}


- (void)save {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:self.videoDictionary forKey:kPlayFinishedVideoIdsKey];
    [userDefaults setObject:self.videoIdList forKey:kHistoryVideoIdsKey];

    [userDefaults synchronize];

    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:self.videoDictionary forKey:kPlayFinishedVideoIdsKey];
    [cloudStore synchronize];
}

-(NSArray<NSString *> * _Nullable )historyVideoIdList{
    return [[self.videoIdList reverseObjectEnumerator] allObjects];
}

@end