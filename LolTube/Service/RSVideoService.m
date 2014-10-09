//
// Created by 郭 輝平 on 10/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoService.h"

static NSString *const kPlayFinishedVideoIds = @"playFinishedVideoIds";

@interface RSVideoService ()

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
    self.videoIdList = [[userDefaults arrayForKey:kPlayFinishedVideoIds] mutableCopy];
    if (!self.videoIdList) {
        self.videoIdList = [[NSMutableArray alloc] init];
    }
}

- (BOOL)isPlayFinishedWithVideoId:(NSString *)videoId {
    return [self.videoIdList containsObject:videoId];

}

- (void)savePlayFinishedVideoId:(NSString *)videoId {
    if ([self.videoIdList containsObject:videoId]) {
        return;
    }
    [self.videoIdList addObject:videoId];
}

- (void)save {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:self.videoIdList forKey:kPlayFinishedVideoIds];
    [userDefaults synchronize];
}

@end