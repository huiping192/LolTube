//
//  RSStringUtilSpec.m
//  LolTube
//
//  Created by 郭 輝平 on 9/6/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "RSStringUtil.h"

SPEC_BEGIN(RSStringUtilSpec)

    describe(@"-isEmptyString:", ^{
        __block BOOL _isEmpty;
        context(@"when string is nil", ^{
            beforeEach(^{
                _isEmpty = [RSStringUtil isEmptyString:nil];
            });
            it(@"should return yes", ^{
                [[theValue(_isEmpty) should] beYes];
            });
        });

        context(@"when string is empty string", ^{
            beforeEach(^{
                _isEmpty = [RSStringUtil isEmptyString:@""];
            });
            it(@"should return yes", ^{
                [[theValue(_isEmpty) should] beYes];
            });
        });

        context(@"when string is not empty", ^{
            beforeEach(^{
                _isEmpty = [RSStringUtil isEmptyString:@"i`m not empty"];
            });
            it(@"should return no", ^{
                [[theValue(_isEmpty) should] beNo];
            });
        });
    });

SPEC_END