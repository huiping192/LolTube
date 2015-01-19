//
// Created by 郭 輝平 on 12/13/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSRelatedVideoCollectionViewCellVo;


@interface RSVideoRelatedVideosViewModel : NSObject

@property(nonatomic, copy) NSString *videoId;

@property(nonatomic, copy) NSArray *relatedVideoList;

- (instancetype)initWithVideoId:(NSString *)videoId;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)updateVideoDetailWithCellVo:(RSRelatedVideoCollectionViewCellVo *)cellVo success:(void (^)())success failure:(void (^)(NSError *))failure;
@end

@interface RSRelatedVideoCollectionViewCellVo : NSObject
@property(nonatomic, copy) NSString *videoId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *channelTitle;
@property(nonatomic, copy) NSString *thumbnailImageUrl;
@property(nonatomic, copy) NSString *viewCount;
@property(nonatomic, copy) NSString *duration;
@end