//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


#import <JSONModel/JSONModel.h>

@protocol RSVideoItem;

@class RSVideoSnippet;
@class RSThumbnails;

@interface RSVideoModel : JSONModel

@property (nonatomic, strong)  NSArray<RSVideoItem> *items;

@end


@interface RSVideoItem:JSONModel

@property (nonatomic, strong)  RSVideoSnippet *snippet;

@end

@interface RSVideoSnippet :JSONModel

@property (nonatomic, copy) NSString *publishedAt;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *videoDescription;

@end