//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"

@class RSChannelSnippet;
@class RSThumbnails;


@protocol RSChannelItem;

@interface RSChannelModel : RSJsonModel
@property (nonatomic, strong)  NSArray<RSChannelItem> *items;

@end


@interface RSChannelItem:JSONModel

@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, strong)  RSChannelSnippet *snippet;

@end

@interface RSChannelSnippet :JSONModel

@property (nonatomic, copy) NSString *publishedAt;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) RSThumbnails *thumbnails;

@end