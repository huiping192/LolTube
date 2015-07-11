//
// Created by 郭 輝平 on 10/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kPlayFinishedVideoIdsKey = @"playFinishedVideoIds";
static NSString *const kHistoryVideoIdsKey = @"historyVideoIds";

@interface RSVideoService : NSObject

+ (RSVideoService *)sharedInstance;

- (void)configure;

- (BOOL)isPlayFinishedWithVideoId:(NSString *)videoId;

- (void)savePlayFinishedVideoId:(NSString *)videoId;

- (void)updateLastPlaybackTimeWithVideoId:(NSString *)videoId lastPlaybackTime:(NSTimeInterval)lastPlaybackTime;

- (NSTimeInterval)lastPlaybackTimeWithVideoId:(NSString *)videoId;

-(void)overrideVideoDataWithVideoDictionary:(NSDictionary *)videoDictionary;

- (void)save;

-(void)saveHistoryVideoId:(NSString *)videoId;

-(NSArray *)historyVideoIdList;
@end