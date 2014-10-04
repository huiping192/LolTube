//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RSVideoCollectionViewCellVo;

@interface RSVideoListCollectionViewModel : NSObject

@property(nonatomic, strong, readonly) NSArray <RSVideoCollectionViewCellVo> *items;

@property(nonatomic, copy) NSString *searchText;

- (instancetype)initWithChannelIds:(NSArray *)channelIds;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)updateNextPageDataWithSuccess:(void (^)(BOOL hasNewData))success failure:(void (^)(NSError *))failure;
@end

@interface RSVideoCollectionViewCellVo : NSObject

@property(nonatomic, copy) NSString *videoId;
@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *channelTitle;
@property(nonatomic, copy) NSString *postedTime;
@property(nonatomic, copy) NSString *publishedAt;

@property(nonatomic, copy) NSString *highThumbnailUrl;
@property(nonatomic, copy) NSString *defaultThumbnailUrl;

@end