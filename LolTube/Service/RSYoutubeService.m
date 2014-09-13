//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "AFNetworking/AFNetworking.h"
#import "RSVideoModel.h"
#import "RSChannelModel.h"

static NSString *const kYoutubeApiKey = @"AIzaSyBb1ZDTeUmzba4Kk4wsYtmi70tr7UBo3HA";

// api url
static NSString *const kYoutubeSearchUrlString = @"https://www.googleapis.com/youtube/v3/search";
static NSString *const kYoutubeVideoUrlString = @"https://www.googleapis.com/youtube/v3/videos";
static NSString *const kYoutubChannelUrlString = @"https://www.googleapis.com/youtube/v3/channels";


@implementation RSYoutubeService {

}
- (void)videoListWithChannelId:(NSString *)channelId success:(void (^)(RSSearchModel *))success failure:(void (^)(NSError *))failure {
    if (!channelId || [channelId isEqualToString:@""]) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"key" : kYoutubeApiKey, @"part" : @"snippet", @"channelId" : channelId, @"type" : @"video", @"maxResults" : @(50), @"order" : @"date"};

    // fields value (,% などのchatがlibに変換されるため、NSStringでそのまま設定する
    NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@", kYoutubeSearchUrlString, @"fields", @"items(id%2Csnippet)%2CpageInfo"];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONModelError *error = nil;
        RSSearchModel *searchModel = [[RSSearchModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        if (success) {
            success(searchModel);
        }
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)videoWithVideoId:(NSString *)videoId success:(void (^)(RSVideoModel *))success failure:(void (^)(NSError *))failure {
    if (!videoId || [videoId isEqualToString:@""]) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"key" : kYoutubeApiKey, @"part" : @"snippet", @"id" : videoId};

    NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@", kYoutubeVideoUrlString, @"fields", @"items(fileDetails%2Cplayer%2CprocessingDetails%2CprojectDetails%2CrecordingDetails%2Csnippet%2Cstatistics%2Cstatus)"];

    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONModelError *error = nil;
        RSVideoModel *videoModel = [[RSVideoModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        if (success) {
            success(videoModel);
        }
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)channelWithChannelIds:(NSArray *)channelIds success:(void (^)(RSChannelModel *))success failure:(void (^)(NSError *))failure {
    if (!channelIds || channelIds.count == 0) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *channelIdsString = [channelIds componentsJoinedByString:@","];
    NSDictionary *parameters = @{@"key" : kYoutubeApiKey, @"part" : @"snippet", @"id" : channelIdsString};

    NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@", kYoutubChannelUrlString, @"fields", @"items(auditDetails,brandingSettings,contentDetails,contentOwnerDetails,id,snippet,statistics,status,topicDetails)"];

    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONModelError *error = nil;
        RSChannelModel *channelModel = [[RSChannelModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        if (success) {
            success(channelModel);
        }
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end