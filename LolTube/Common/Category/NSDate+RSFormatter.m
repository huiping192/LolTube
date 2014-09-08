//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "NSDate+RSFormatter.h"
#import "RSStringUtil.h"


@implementation NSDate (RSFormatter)

+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String {
    if([RSStringUtil isEmptyString:iso8601String]){
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];

    return [formatter dateFromString:iso8601String];
}

@end