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

@interface RSBrandingSettingsImage :JSONModel

@property (nonatomic, strong) NSString<Optional> *bannerMobileImageUrl;

@end

@interface RSBrandingSettings :JSONModel

@property (nonatomic, strong) RSBrandingSettingsImage *image;

@end

@interface RSStatistics :JSONModel

@property (nonatomic, copy) NSString *viewCount;
@property (nonatomic, copy) NSString *subscriberCount;
@property (nonatomic, copy) NSString *videoCount;

@end

@interface RSChannelItem:JSONModel

@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, strong)  RSChannelSnippet *snippet;
@property (nonatomic, strong)  RSBrandingSettings<Optional> *brandingSettings;
@property (nonatomic, strong)  RSStatistics<Optional> *statistics;

@end

@interface RSChannelSnippet :JSONModel

@property (nonatomic, copy) NSString<Optional> *publishedAt;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *channelDescription;

@property (nonatomic, strong) RSThumbnails *thumbnails;

@end



