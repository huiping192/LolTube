//
// Created by 郭 輝平 on 9/6/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSStringUtil.h"


@implementation RSStringUtil {

}

+ (BOOL)isEmptyString:(NSString *)string {
    return !string || [string isEqualToString:@""];
}

@end