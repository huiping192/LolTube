//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"
#import "RSVideoDetailModel.h"

@protocol RSVideoItem;

@class RSVideoSnippet;
@class RSThumbnails;

@interface RSVideoModel : RSJsonModel
@property (nonatomic, strong)  NSArray<RSVideoItem> *items;

@end


@interface RSVideoItem:JSONModel

@property (nonatomic, copy) NSString *id;

@property (nonatomic, strong)  RSVideoSnippet *snippet;
@property (nonatomic, strong)  RSVideoContentDetails *contentDetails;
@property (nonatomic, strong)  RSVideoStatistics *statistics;
@end

@interface RSVideoSnippet :JSONModel

@property (nonatomic, copy) NSString *publishedAt;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *videoDescription;
@property (nonatomic, strong) RSThumbnails *thumbnails;

@property (nonatomic, copy) NSString *channelTitle;



@end