//
//  RSVideoInfoUtil.m
//  LolTube
//
//  Created by 郭 輝平 on 3/13/15.
//  Copyright (c) 2015 Huiping Guo. All rights reserved.
//

#import "RSVideoInfoUtil.h"
#import "LolTube-Swift.h"

@interface NSString (Util)
- (int)indexOf:(NSString *)text;

@end

@implementation NSString (Util)

- (int)indexOf:(NSString *)text {
    NSRange range = [self rangeOfString:text];
    if (range.length > 0) {
        return (int)range.location;
    } else {
        return -1;
    }
}
@end

@implementation RSVideoInfoUtil

+ (NSString *)convertVideoDuration:(NSString *)duration {
    NSString *hour = nil;
    NSString *minute = nil;
    NSString *second = nil;

    NSArray *durationSpilt = [duration componentsSeparatedByString:@"PT"];
    if (durationSpilt.count != 2) {
        return nil;
    }
    NSString *hms = durationSpilt[1];
    NSString *ms = durationSpilt[1];
    NSString *s = durationSpilt[1];

    if ([hms indexOf:@"H"] >= 0) {
        NSArray *hourSpilt = [hms componentsSeparatedByString:@"H"];
        if (hourSpilt.count == 2) {
            hour = hourSpilt[0];
            ms = hourSpilt[1];
        }
    }

    if ([ms indexOf:@"M"] >= 0) {
        NSArray *minuteSpilt = [ms componentsSeparatedByString:@"M"];
        if (minuteSpilt.count == 2) {
            minute = minuteSpilt[0];
            s = minuteSpilt[1];
        }
    }

    if ([s indexOf:@"S"] >= 0) {
        NSArray *secondSpilt = [s componentsSeparatedByString:@"S"];
        if (secondSpilt.count > 1) {
            second = secondSpilt[0];
        }
    }

    int mInt = minute.intValue;
    if (mInt < 10) {
        minute = [NSString stringWithFormat:@"0%d", mInt];
    }
    int sInt = second.intValue;
    if (sInt < 10) {
        second = [NSString stringWithFormat:@"0%d", sInt];
    }

    minute = minute ? minute : @"00";
    second = second ? second : @"00";

    if (hour) {
        return [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    } else {
        return [NSString stringWithFormat:@"%@:%@", minute, second];
    }
}


+ (NSString *)convertNumber:(NSInteger)number {
    NSString *formatted = @(number).stringValue;
    NSInteger tenThousandCount = number / 10000;
    NSInteger thousandCount = number / 1000;
    
    if(tenThousandCount > 0){
        NSString *tenThousandformatted = NSLocalizedString(@"VideoViewCountTenThousandFormat", nil);
        if(![tenThousandformatted isEqualToString:@"VideoViewCountTenThousandFormat"]){
            formatted = [NSString stringWithFormat:tenThousandformatted, @(tenThousandCount)];
        }else {
            formatted = [NSString stringWithFormat:NSLocalizedString(@"VideoViewCountThousandFormat", nil), @(thousandCount)];
        }
    } else if (thousandCount > 0) {
        formatted = [NSString stringWithFormat:NSLocalizedString(@"VideoViewCountThousandFormat", nil), @(thousandCount)];
    }
    return formatted;
}


+ (NSString *)convertVideoViewCount:(NSInteger)viewCount {
    return [NSString stringWithFormat:NSLocalizedString(@"VideoViewCountFormat", @"%@ views"), [self convertNumber:viewCount]];
}

+ (NSString *)convertFollowerCount:(NSInteger)followerCount{
    return [NSString stringWithFormat:NSLocalizedString(@"TwitchFollowerCountFormat", @"%@ views"), [self convertNumber:followerCount]];
}

+ (NSString *)convertViewerCount:(NSInteger)viewerCount{
    return [NSString stringWithFormat:NSLocalizedString(@"TwitchViewerCountFormat", @"%@ views"), [self convertNumber:viewerCount]]; 
}

+ (NSString *)convertPostedTime:(NSString *)publishedAt {
    NSString *publishedDateString = nil;

    NSDate *publishedDate = [NSDate dateWithIso8601String:publishedAt];
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:publishedDate];
    int timeDifferenceInHours = (int) (timeDifference / 3600);
    int timeDifferenceInMinutes = (int) ((timeDifference - timeDifferenceInHours) / 60);
    if (timeDifferenceInHours == 0) {
        publishedDateString = [NSString stringWithFormat:NSLocalizedString(@"VideoPostedTimeStringMinutesFormatter", nil), timeDifferenceInMinutes];
    } else if (timeDifferenceInHours < 24) {
        publishedDateString = [NSString stringWithFormat:NSLocalizedString(@"VideoPostedTimeStringHoursFormatter", nil), timeDifferenceInHours];
    } else {
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"EEEE,MMM d"];
        publishedDateString = [form stringFromDate:publishedDate];
    }

    return publishedDateString;
}

+ (NSString *)convertToShortPostedTime:(NSString *)publishedAt{
    
    NSDate *publishedDate = [NSDate dateWithIso8601String:publishedAt];
    NSTimeInterval diffTime = [[NSDate alloc]init].timeIntervalSince1970 - publishedDate.timeIntervalSince1970;
    
    NSTimeInterval minTime = 60;
    NSTimeInterval hourTime = 60 *  minTime;
    NSTimeInterval dayTime = 24 * hourTime;
    NSTimeInterval weekTime = 7 * dayTime;
    NSTimeInterval monthTime = 30 * dayTime;
    NSTimeInterval yearTime = 365 * dayTime;
    
    NSInteger yearCount = diffTime / yearTime;
    if (yearCount > 0) {
        if(yearCount == 1){
            return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtSingleYearFormat", @"%ld year ago"), yearCount];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtYearsFormat", @"%ld years ago"), yearCount];
    }
    
    NSInteger monthCount = diffTime / monthTime;
    if (monthCount > 0) {
        if(monthCount == 1){
            return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtSingleMonthFormat", @"%ld month ago"), monthCount];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtMonthsFormat", @"%ld months ago"), monthCount];
    }
    
    NSInteger weekCount = diffTime / weekTime;
    if (weekCount > 0) {
        if(weekCount == 1){
            return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtSingleWeekFormat", @"%ld week ago"), weekCount];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtWeeksFormat", @"%ld weeks ago"), weekCount];
    }
    
    NSInteger dayCount = diffTime / dayTime;
    if (dayCount > 0) {
        if(dayCount == 1){
            return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtSingleDayFormat", @"%ld day ago"), dayCount];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtDaysFormat", @"%ld days ago"), dayCount];
    }
    
    NSInteger hourCount = diffTime / hourTime;
    if (hourCount > 0) {
        if(hourCount == 1){
            return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtSingleHourFormat", @"%ld hour ago"), hourCount];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtHoursFormat", @"%ld hours ago"), hourCount];
    }
    
    NSInteger minCount = diffTime / minTime;
    if (minCount > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"PublishedAtMinsFormat", @"%ld min ago"), minCount];
    }
    
    return @"1 day ago";
}

@end

