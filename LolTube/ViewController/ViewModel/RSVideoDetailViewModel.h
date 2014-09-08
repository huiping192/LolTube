//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSVideoDetailViewModel : NSObject

@property(nonatomic, copy) NSString *videoId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *postedTime;
@property(nonatomic, copy) NSString *description;

@property(nonatomic, copy) NSString *mediumThumbnailUrl;

- (instancetype)initWithVideoId:(NSString *)videoId;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;
@end