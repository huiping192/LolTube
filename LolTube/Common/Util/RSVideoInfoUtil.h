//
//  RSVideoInfoUtil.h
//  LolTube
//
//  Created by 郭 輝平 on 3/13/15.
//  Copyright (c) 2015 Huiping Guo. All rights reserved.
//



@interface RSVideoInfoUtil : NSObject

+ (NSString *)convertVideoDuration:(NSString *)duration;

+ (NSString *)convertVideoViewCount:(NSInteger)viewCount;

+ (NSString *)convertViewerCount:(NSInteger)viewerCount;

+ (NSString *)convertFollowerCount:(NSInteger)followerCount;

+ (NSString *)convertPostedTime:(NSString *)publishedAt;

+ (NSString *)convertToShortPostedTime:(NSString *)publishedAt;

@end
