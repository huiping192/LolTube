//
//  RSYoutubeServiceSpec.m
//  LolTube
//
//  Created by 郭 輝平 on 9/2/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <objc/runtime.h>
#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "RSVideoModel.h"

SPEC_BEGIN(RSYoutubeServiceSpec)

    __block RSYoutubeService *_youtubeService;

    beforeEach(^{
        _youtubeService = [[RSYoutubeService alloc] init];
    });
    describe(@"videoListWithChannelId", ^{
        __block RSSearchModel *_searchModel;
        __block NSError *_error;
        __block BOOL _successBlockExecuteFlag;
        __block BOOL _failureBlockExecuteFlag;


        __block void (^_success)(RSSearchModel *);
        __block void (^_failure)(NSError *);

        beforeEach(^{
            _searchModel = nil;
            _error = nil;
            _successBlockExecuteFlag = NO;
            _failureBlockExecuteFlag = NO;

            _success = ^(RSSearchModel *searchModel) {
                _successBlockExecuteFlag = YES;
                _searchModel = searchModel;
            };

            _failure = ^(NSError *error) {
                _failureBlockExecuteFlag = YES;
                _error = error;
            };
        });

        context(@"when channelId is nil", ^{
            beforeEach(^{
                [_youtubeService videoListWithChannelId:nil success:_success failure:_failure];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_searchModel) shouldEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when channelId is empty string", ^{
            beforeEach(^{
                [_youtubeService videoListWithChannelId:nil success:_success failure:_failure];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_searchModel) shouldEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when channel exits", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    NSString *filePath = OHPathForFileInBundle(@"RayWenderlichChannel.json", nil);
                    return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                            statusCode:200 headers:@{@"Content-Type" : @"text/json"}];
                }];

                [_youtubeService videoListWithChannelId:@"UCz3cM4qLljXcQ8oWjMPgKZA" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should return expect data", ^{
                [[expectFutureValue(_searchModel) shouldNotEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when server return 503 status code", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithData:nil statusCode:503 headers:nil];
                }];

                [_youtubeService videoListWithChannelId:@"UCz3cM4qLljXcQ8oWjMPgKZA" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_searchModel) shouldEventually] beNil];
            });

            it(@"should contain http error", ^{
                [[expectFutureValue(_error) shouldNotEventually] beNil];
            });
        });

        context(@"when server return unformatter json data", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    NSString *filePath = OHPathForFileInBundle(@"Channel_unformatter_data.json", nil);

                    return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                            statusCode:200 headers:@{@"Content-Type" : @"text/json"}];
                }];

                [_youtubeService videoListWithChannelId:@"UCz3cM4qLljXcQ8oWjMPgKZA" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_searchModel) shouldEventually] beNil];
            });

            it(@"should contain http error", ^{
                [[expectFutureValue(_error) shouldNotEventually] beNil];
            });
        });
    });

    describe(@"-videoWithVideoId:", ^{
        __block RSVideoModel *_videoModel;
        __block NSError *_error;
        __block BOOL _successBlockExecuteFlag;
        __block BOOL _failureBlockExecuteFlag;


        __block void (^_success)(RSVideoModel *);
        __block void (^_failure)(NSError *);

        beforeEach(^{
            _videoModel = nil;
            _error = nil;
            _successBlockExecuteFlag = NO;
            _failureBlockExecuteFlag = NO;

            _success = ^(RSVideoModel *videoModel) {
                _successBlockExecuteFlag = YES;
                _videoModel = videoModel;
            };

            _failure = ^(NSError *error) {
                _failureBlockExecuteFlag = YES;
                _error = error;
            };
        });

        context(@"when channelId is nil", ^{
            beforeEach(^{
                [_youtubeService videoWithVideoId:nil success:_success failure:_failure];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_videoModel) shouldEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when channelId is empty string", ^{
            beforeEach(^{
                [_youtubeService videoWithVideoId:@"" success:_success failure:_failure];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_videoModel) shouldEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when channel exits", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    NSString *filePath = OHPathForFileInBundle(@"CLG_vs_DIG_Video_Deital.json", nil);
                    return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                            statusCode:200 headers:@{@"Content-Type" : @"text/json"}];
                }];

                [_youtubeService videoWithVideoId:@"b-BBlJm8bHI" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should return expect data", ^{
                [[expectFutureValue(_videoModel) shouldNotEventually] beNil];
            });

            it(@"should not contain any error", ^{
                [[expectFutureValue(_error) shouldEventually] beNil];
            });
        });

        context(@"when server return 503 status code", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithData:nil statusCode:503 headers:nil];
                }];

                [_youtubeService videoWithVideoId:@"b-BBlJm8bHI" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_videoModel) shouldEventually] beNil];
            });

            it(@"should contain http error", ^{
                [[expectFutureValue(_error) shouldNotEventually] beNil];
            });
        });

        context(@"when server return unformatter json data", ^{
            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
                    return YES;
                }                   withStubResponse:^(NSURLRequest *request) {
                    NSString *filePath = OHPathForFileInBundle(@"Video_unformatter_data.json", nil);

                    return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                            statusCode:200 headers:@{@"Content-Type" : @"text/json"}];
                }];

                [_youtubeService videoWithVideoId:@"UCz3cM4qLljXcQ8oWjMPgKZA" success:_success failure:_failure];

            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"should not execute success block", ^{
                [[expectFutureValue(theValue(_successBlockExecuteFlag)) shouldEventually] beNo];
            });

            it(@"should execute failure block", ^{
                [[expectFutureValue(theValue(_failureBlockExecuteFlag)) shouldEventually] beYes];
            });

            it(@"should not return any data", ^{
                [[expectFutureValue(_videoModel) shouldEventually] beNil];
            });

            it(@"should contain http error", ^{
                [[expectFutureValue(_error) shouldNotEventually] beNil];
            });
        });
    });

SPEC_END