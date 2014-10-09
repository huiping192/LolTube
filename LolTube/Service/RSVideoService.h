//
// Created by 郭 輝平 on 10/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSVideoService : NSObject

+ (RSVideoService *)sharedInstance;

- (void)configure;

-(BOOL)isPlayFinishedWithVideoId:(NSString *)videoId;

-(void)savePlayFinishedVideoId:(NSString *)videoId;

- (void)save;
@end