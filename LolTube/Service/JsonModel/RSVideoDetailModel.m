//
// Created by 郭 輝平 on 12/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailModel.h"


@implementation RSVideoDetailModel {

}
@end

@implementation RSVideoDetailItem

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"id" : @"videoId"
    }];
}
@end

@implementation RSVideoContentDetails

@end

@implementation RSVideoStatistics
@end