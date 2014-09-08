//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RSFormatter)

/**
* convert ISO8601 date string to NSDate
*/
+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String;
@end