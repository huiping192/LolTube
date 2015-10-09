//
// Created by 郭 輝平 on 12/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"

@class RSVideoContentDetails;
@class RSVideoStatistics;
@protocol RSVideoDetailItem;
@class RSVideoDetailItem;

@interface RSVideoDetailModel : RSJsonModel
@property (nonatomic, strong)  NSArray<RSVideoDetailItem *><RSVideoDetailItem> *items;
@end


@interface RSVideoDetailItem:JSONModel

@property (nonatomic, copy)  NSString *videoId;
@property (nonatomic, strong)  RSVideoContentDetails *contentDetails;
@property (nonatomic, strong)  RSVideoStatistics *statistics;

@end

@interface RSVideoContentDetails :JSONModel

@property (nonatomic, copy) NSString *duration;

@end


@interface RSVideoStatistics :JSONModel

@property (nonatomic, copy) NSString<Optional> *viewCount;
@property (nonatomic, copy) NSString<Optional> *likeCount;
@property (nonatomic, copy) NSString<Optional> *dislikeCount;

@end