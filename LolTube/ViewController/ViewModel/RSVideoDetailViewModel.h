//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSVideoDetailViewModel : NSObject

@property(nonatomic, copy) NSString *videoId;

@property(nonatomic, copy) NSString *shareTitle;
@property(nonatomic, copy) NSString *shareUrlString;
@property(nonatomic, copy) NSString *handoffUrlStringFormat;

@property(nonatomic, copy) NSString *highThumbnailImageUrl;
@property(nonatomic, copy) NSString *defaultThumbnailImageUrl;

- (instancetype)initWithVideoId:(NSString *)videoId;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;
@end
