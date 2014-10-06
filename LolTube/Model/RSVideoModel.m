//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoModel.h"


@implementation RSVideoModel {

}
@end

@implementation RSVideoSnippet

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"description" : @"videoDescription"
    }];
}

@end

@implementation RSVideoItem

@end