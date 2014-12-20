//
// Created by 郭 輝平 on 9/8/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


#import <JSONModel/JSONModel.h>

@class RSThumbnail;

@interface RSThumbnails : JSONModel

//@property (nonatomic, copy) NSString *default;
@property(nonatomic, strong) RSThumbnail *medium;

@end

@interface RSThumbnail : JSONModel

@property(nonatomic, copy) NSString *url;

@end