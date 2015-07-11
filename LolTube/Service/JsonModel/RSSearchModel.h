//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"
#import "RSPageInfo.h"

@protocol RSItem;
@class RSId;

@class RSSnippet;
@class RSThumbnails;
@class RSThumbnail;

@interface RSSearchModel : RSJsonModel
@property(nonatomic, copy) NSString<Optional> *nextPageToken;

@property(nonatomic, strong) RSPageInfo *pageInfo;

@property(nonatomic, strong) NSArray <RSItem> *items;

@end

@interface RSItem : JSONModel

@property(nonatomic, strong) RSId *id;
@property(nonatomic, strong) RSSnippet *snippet;

@end

@interface RSSnippet : JSONModel

@property(nonatomic, copy) NSString *publishedAt;
@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) RSThumbnails *thumbnails;
@property(nonatomic, copy) NSString *channelTitle;

@end


@interface RSId : JSONModel

@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString<Optional> *videoId;
@property(nonatomic, copy) NSString<Optional> *channelId;

@end
