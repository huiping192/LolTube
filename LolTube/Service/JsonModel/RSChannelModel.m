//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelModel.h"


@implementation RSChannelModel {

}
@end


@implementation RSChannelItem {

}
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"id" : @"channelId",
    }];
}

@end


@implementation RSChannelSnippet {

}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"description" : @"channelDescription"
    }];
}

@end


@implementation RSBrandingSettings 

@end

@implementation RSBrandingSettingsImage

@end

@implementation RSStatistics

@end

