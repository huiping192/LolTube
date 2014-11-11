//
// Created by 郭 輝平 on 9/9/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSVideoDetailAnimator.h"
#import "RSVideoListViewController.h"
#import "RSVideoDetailViewController.h"
#import "RSVideoCollectionViewCell.h"

static NSTimeInterval kAnimationDuration = 0.5;

@interface RSVideoDetailAnimator ()
@property(nonatomic, assign) UINavigationControllerOperation operation;
@end

@implementation RSVideoDetailAnimator {

}
- (instancetype)initWithOperation:(UINavigationControllerOperation)operation {
    self = [super init];
    if (self) {
        self.operation = operation;
    }

    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    UIView *containView = transitionContext.containerView;

    [containView addSubview:toView];

    if (_operation == UINavigationControllerOperationPush) {
        RSVideoListViewController *videoListViewController = (RSVideoListViewController *) fromViewController;
        RSVideoDetailViewController *videoDetailViewController = (RSVideoDetailViewController *) toViewController;

        RSVideoCollectionViewCell *selectedCell = (RSVideoCollectionViewCell *) [videoListViewController selectedCell];

        CGRect frame = [selectedCell convertRect:selectedCell.bounds toView:fromView];
        UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:frame];
        tempImageView.image = selectedCell.thumbnailImageView.image;
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        tempImageView.clipsToBounds = YES;
        [containView addSubview:tempImageView];

        videoDetailViewController.thumbnailImageView.hidden = YES;

        toView.alpha = 0.0;
        [UIView animateWithDuration:kAnimationDuration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect thumbnailFrame = [videoDetailViewController.thumbnailImageView convertRect:videoDetailViewController.thumbnailImageView.frame toView:toView];

            tempImageView.frame = thumbnailFrame;
            toView.alpha = 1.0;
            fromView.alpha = 0.0;
        }                completion:^(BOOL finished) {

            [UIView transitionWithView:tempImageView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                tempImageView.alpha = 0.0;
            }               completion:^(BOOL finished) {
                videoDetailViewController.thumbnailImageView.hidden = NO;
                [tempImageView removeFromSuperview];

                fromView.alpha = 1.0;
                [transitionContext completeTransition:YES];
            }];
        }];


    } else {
        RSVideoListViewController *videoListViewController = (RSVideoListViewController *) toViewController;
        RSVideoDetailViewController *videoDetailViewController = (RSVideoDetailViewController *) fromViewController;

        UICollectionView *collectionView = videoListViewController.collectionView;
        [collectionView.collectionViewLayout invalidateLayout];
        [toView layoutIfNeeded];

        NSIndexPath *indexPath = [videoListViewController indexPathWithVideoId:videoDetailViewController.videoId];
        RSVideoCollectionViewCell *selectedCell = (RSVideoCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];

        CGRect selectedCellFrame = [selectedCell convertRect:selectedCell.bounds toView:fromView];
        if (!selectedCell) {
            UICollectionViewLayoutAttributes *pose = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
            selectedCellFrame = [collectionView convertRect:pose.frame toView:nil];
        }

        [UIView animateWithDuration:0.25 animations:^{
            CGRect thumbnailFrame = [videoDetailViewController.thumbnailImageView convertRect:videoDetailViewController.thumbnailImageView.bounds toView:toView];

            UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
            tempImageView.image = videoDetailViewController.thumbnailImageView.image;
            tempImageView.contentMode = UIViewContentModeScaleAspectFill;
            tempImageView.clipsToBounds = YES;
            [containView addSubview:tempImageView];

            toView.alpha = 0.0;

            [UIView animateWithDuration:0.8 * kAnimationDuration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

                tempImageView.frame = selectedCellFrame;
                toView.alpha = 1.0;
                fromView.alpha = 0.0;
            }                completion:^(BOOL finished) {

                [tempImageView removeFromSuperview];

                selectedCell.titleLabel.transform = CGAffineTransformMakeTranslation(0.0, -10);
                selectedCell.titleLabel.alpha = 0.4;

                selectedCell.channelTitleView.transform = CGAffineTransformMakeTranslation(0.0, 10);
                selectedCell.channelTitleView.alpha = 0.4;

                selectedCell.postedTimeLabel.transform = CGAffineTransformMakeTranslation(0.0, 10);
                selectedCell.postedTimeLabel.alpha = 0.4;

                [UIView animateWithDuration:0.2 * kAnimationDuration animations:^{
                    selectedCell.titleLabel.alpha = 1.0;
                    selectedCell.titleLabel.transform = CGAffineTransformIdentity;

                    selectedCell.channelTitleView.alpha = 1.0;
                    selectedCell.channelTitleView.transform = CGAffineTransformIdentity;

                    selectedCell.postedTimeLabel.alpha = 1.0;
                    selectedCell.postedTimeLabel.transform = CGAffineTransformIdentity;
                }                completion:^(BOOL finished) {
                    fromView.alpha = 1.0;
                    [transitionContext completeTransition:YES];
                }];
            }];
        }];
    }

}

@end