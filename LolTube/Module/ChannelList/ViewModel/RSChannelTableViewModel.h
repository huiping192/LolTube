//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RSChannelTableViewCellVo;

@interface RSChannelTableViewModel : NSObject

@property(nonatomic, strong, readonly) NSArray <RSChannelTableViewCellVo> *items;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)deleteChannelWithIndexPath:(NSIndexPath *)indexPath;

- (void)moveChannelWithIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

+(void)clearCache;
@end


@interface RSChannelTableViewCellVo : NSObject

@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *mediumThumbnailUrl;

@end