//
// Created by 郭 輝平 on 11/1/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RSVideoListTableViewCellVo;

@interface RSTodayVideoTableViewModel : NSObject

@property(nonatomic, strong) NSArray <RSVideoListTableViewCellVo> *items;

- (instancetype)initWithChannelIds:(NSArray *)channelIds;

- (void)updateCacheDataWithSuccess:(void (^)(BOOL hasCacheData))success;

- (void)updateWithSuccess:(void (^)(BOOL hasNewData))success failure:(void (^)(NSError *))failure;

@end


@interface RSVideoListTableViewCellVo : NSObject<NSCoding>

@property(nonatomic, copy) NSString *videoId;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *defaultThumbnailUrl;
@property(nonatomic, copy) NSString *publishedAt;

@end