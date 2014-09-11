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

        [self p_addParallaxMotionEffects];
    }

    return self;
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
        topShadowLayer.frame = CGRectMake(0, 0, self.frame.size.width, kTopShadowSizeRatio * _titleLabel.frame.size.height + _titleLabel.frame.origin.y);
        [self.contentView.layer insertSublayer:topShadowLayer below:_titleLabel.layer];
        self.topShadowLayer = topShadowLayer;
    }

    if (!self.bottomShadowLayer) {
        CALayer *bottomShadowLayer = [self p_createShadowLayerWithTopColor:[UIColor colorWithWhite:0 alpha:.0] bottomColor:[UIColor colorWithWhite:0 alpha:.8]];
        bottomShadowLayer.frame = CGRectMake(0, _channelTitleView.frame.origin.y - kBottomShadowSizeRatio * _channelTitleView.frame.size.height, self.frame.size.width, self.frame.size.height - _channelTitleView.frame.origin.y + kBottomShadowSizeRatio * _channelTitleView.frame.size.height);
        [self.contentView.layer insertSublayer:bottomShadowLayer below:_channelLabel.layer];
        [self.contentView.layer insertSublayer:bottomShadowLayer below:_postedTimeLabel.layer];
        self.bottomShadowLayer = bottomShadowLayer;
    }

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

- (void)p_addParallaxMotionEffects {
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform.rotation.y" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @(-M_PI_4 / 2);
    interpolationHorizontal.maximumRelativeValue = @(M_PI_4 / 2);


    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform.rotation.x" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @(M_PI_4 / 2);
    interpolationVertical.maximumRelativeValue = @(-M_PI_4 / 2);

    [self addMotionEffect:interpolationHorizontal];
    [self addMotionEffect:interpolationVertical];
}

@end