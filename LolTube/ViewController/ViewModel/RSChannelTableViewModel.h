//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RSChannelCollectionViewCellVo;

@interface RSChannelTableViewModel : NSObject

@property(nonatomic, strong, readonly) NSArray <RSChannelCollectionViewCellVo> *items;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;
@end


@interface RSChannelTableViewCellVo : NSObject

@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *mediumThumbnailUrl;

@end