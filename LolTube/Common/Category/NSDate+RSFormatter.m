//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "NSDate+RSFormatter.h"
#import "RSStringUtil.h"

@implementation NSDate (RSFormatter)

+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String {
    static NSDateFormatter *formatterCache = nil;
    if([RSStringUtil isEmptyString:iso8601String]){
        return nil;
    }
    if(!formatterCache){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:posix];
        formatterCache = formatter;
    }

    return [formatterCache dateFromString:iso8601String];
}


+ (NSDate *)dateFromISO8601TimeString:(NSString *)iso8601String {
    if([RSStringUtil isEmptyString:iso8601String]){
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mMsS"];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];

    return [formatter dateFromString:iso8601String];
}

+(NSString *)todayRFC3339DateTime{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *morningStart = [calendar dateFromComponents:components];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [formatter stringFromDate:morningStart];
}

@end