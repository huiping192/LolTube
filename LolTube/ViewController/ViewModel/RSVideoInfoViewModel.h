//
// Created by 郭 輝平 on 12/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSVideoInfoViewModel : NSObject

@property(nonatomic, copy) NSString *videoId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *postedTime;
@property(nonatomic, copy) NSString *rate;
@property(nonatomic, copy) NSString *viewCount;
@property(nonatomic, copy) NSString *videoDescription;

- (instancetype)initWithVideoId:(NSString *)videoId;
- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)updateVideoDetailWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;
@end