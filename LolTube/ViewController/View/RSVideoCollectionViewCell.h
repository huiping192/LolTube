//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//


@interface RSVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *postedTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *channelTitleView;
@property (nonatomic, weak) IBOutlet UILabel *channelLabel;

@end