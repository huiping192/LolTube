//
//  NSDateSpec.m
//  LolTube
//
//  Created by 郭 輝平 on 9/6/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//


#import <Kiwi/Kiwi.h>
#import "NSDate+RSFormatter.h"

SPEC_BEGIN(NSDateSpec)

    describe(@"-dateFromISO8601String:", ^{
        __block NSDate *_date;
        context(@"when string is nil", ^{
            beforeEach(^{
                _date = [NSDate dateFromISO8601String:nil];
            });
            it(@"should return nil", ^{
                [[_date should] beNil];
            });
        });
        context(@"when string is empty string", ^{
            beforeEach(^{
                _date = [NSDate dateFromISO8601String:@""];
            });
            it(@"should return nil", ^{
                [[_date should] beNil];
            });
        });

        context(@"when string is not ISO0860 formatter string", ^{
            beforeEach(^{
                _date = [NSDate dateFromISO8601String:@"2013-08-25"];
            });
            it(@"should return nil", ^{
                [[_date should] beNil];
            });
        });

        context(@"when string is ISO0860 formatter string", ^{
            beforeEach(^{
                _date = [NSDate dateFromISO8601String:@"2013-08-25T21:38:03.000Z"];
            });
            it(@"should return expect date", ^{
                [[_date shouldNot] beNil];
            });
        });
    });

SPEC_END
