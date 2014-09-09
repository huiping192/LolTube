//
// Created by 郭 輝平 on 9/7/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSVideoDetailViewController : UIViewController

@property(nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, weak) IBOutlet UIImageView *playImageView;
@property(nonatomic, strong)  UIImage *thumbnailImage;

@property (nonatomic, copy) NSString *videoId;
@end