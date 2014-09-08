//
// Created by 郭 輝平 on 9/2/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSYoutubeService.h"
#import "RSSearchModel.h"
#import "AFNetworking/AFNetworking.h"


static NSString *const kYoutubeSearchUrlString = @"https://www.googleapis.com/youtube/v3/search";
static NSString *const kYoutubeApiKey = @"AIzaSyBb1ZDTeUmzba4Kk4wsYtmi70tr7UBo3HA";

@implementation RSYoutubeService {

}
- (void)videoListWithChannelId:(NSString *)channelId success:(void (^)(RSSearchModel *))success failure:(void (^)(NSError *))failure {
    if (!channelId || [channelId isEqualToString:@""]) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"key":kYoutubeApiKey,@"part" : @"snippet", @"channelId" : channelId, @"type":@"video",@"maxResults":@(50),@"order":@"date"};

    [manager GET:kYoutubeSearchUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONModelError *error = nil;
        RSSearchModel *searchModel = [[RSSearchModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            if(failure){
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

@end