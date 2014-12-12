//
// Created by 郭 輝平 on 12/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "NSString+Util.h"


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