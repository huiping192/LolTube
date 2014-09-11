//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class RSPageInfo;

@protocol RSItem;
@class RSId;

@class RSSnippet;
@class RSThumbnails;
@class RSThumbnail;

@interface RSSearchModel : JSONModel

@property(nonatomic, strong) RSPageInfo *pageInfo;

@property(nonatomic, strong) NSArray <RSItem> *items;

@end

@interface RSPageInfo : JSONModel

@property(nonatomic, assign) int totalResults;
@property(nonatomic, assign) int resultsPerPage;

@end


@interface RSItem : JSONModel

@property(nonatomic, strong) RSId *id;
@property(nonatomic, strong) RSSnippet *snippet;

@end

@interface RSSnippet : JSONModel

@property(nonatomic, copy) NSString *publishedAt;
@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) RSThumbnails *thumbnails;
@property(nonatomic, copy) NSString *channelTitle;
@property(nonatomic, copy) NSString *liveBroadcastContent;

@end


@interface RSId : JSONModel

@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString *videoId;

@end
