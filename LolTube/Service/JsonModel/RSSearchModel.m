//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSSearchModel.h"


@implementation RSSearchModel {

}
@end

@implementation RSItem

@end


@implementation RSId

@end


@implementation RSSnippet

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"description" : @"videoDescription"
    }];
}
@end