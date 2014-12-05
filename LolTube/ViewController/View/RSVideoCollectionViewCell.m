//
// Created by 郭 輝平 on 9/5/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

static CGFloat const kCellCornerRadius = 5.0f;

// channel title view
static CGFloat const kChannelTitleViewBorderWidth = 0.5f;
static CGFloat const kChannelTitleViewCornerRadius = 5.0f;

// top shadow
static CGFloat const kTopShadowSizeRatio = 1.5f;

// bottom shadow
static CGFloat const kBottomShadowSizeRatio = 0.5f;

#import "RSVideoCollectionViewCell.h"

@interface RSVideoCollectionViewCell ()

@property(nonatomic, weak) CALayer *topShadowLayer;
@property(nonatomic, weak) CALayer *bottomShadowLayer;

@end

@implementation RSVideoCollectionViewCell {

}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = kCellCornerRadius;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.5;
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.thumbnailImageView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_titleLabel setShadowColor:[UIColor blackColor]];
    [_titleLabel setShadowOffset:CGSizeMake(1, 1)];

    _channelTitleView.layer.borderColor = [self.tintColor CGColor];
    _channelTitleView.layer.borderWidth = kChannelTitleViewBorderWidth;
    _channelTitleView.layer.cornerRadius = kChannelTitleViewCornerRadius;

    _channelLabel.textColor = [self tintColor];

    if (!self.topShadowLayer) {
        CALayer *topShadowLayer = [self p_createShadowLayerWithTopColor:[UIColor colorWithWhite:0 alpha:.5] bottomColor:[UIColor colorWithWhite:0 alpha:.0]];
        [self.contentView.layer insertSublayer:topShadowLayer below:_titleLabel.layer];
        self.topShadowLayer = topShadowLayer;
    }
    self.topShadowLayer.frame = CGRectMake(0, 0, self.frame.size.width, kTopShadowSizeRatio * _titleLabel.frame.size.height + _titleLabel.frame.origin.y);

    if (!self.bottomShadowLayer) {
        CALayer *bottomShadowLayer = [self p_createShadowLayerWithTopColor:[UIColor colorWithWhite:0 alpha:.0] bottomColor:[UIColor colorWithWhite:0 alpha:.8]];
        [self.contentView.layer insertSublayer:bottomShadowLayer below:_channelLabel.layer];
        [self.contentView.layer insertSublayer:bottomShadowLayer below:_postedTimeLabel.layer];
        self.bottomShadowLayer = bottomShadowLayer;
    }
    self.bottomShadowLayer.frame = CGRectMake(0, _channelTitleView.frame.origin.y - kBottomShadowSizeRatio * _channelTitleView.frame.size.height, self.frame.size.width, self.frame.size.height - _channelTitleView.frame.origin.y + kBottomShadowSizeRatio * _channelTitleView.frame.size.height);
}

- (CALayer *)p_createShadowLayerWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor {
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.anchorPoint = CGPointZero;
    maskLayer.startPoint = CGPointMake(0.5f, 0.0f);
    maskLayer.endPoint = CGPointMake(0.5f, 1.0f);

    maskLayer.colors = @[(id) topColor.CGColor, (id) bottomColor.CGColor];
    maskLayer.locations = @[@0.0, @1.0f];

    return maskLayer;
}

@end