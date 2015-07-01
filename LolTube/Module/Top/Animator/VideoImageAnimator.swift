//
// Created by 郭 輝平 on 3/15/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

@objc
class VideoImageAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let animationDuration: NSTimeInterval = 0.25

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)


        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let containView = transitionContext.containerView()

        containView.addSubview(toView)

        toView.alpha = 0.0
        UIView.animateWithDuration(animationDuration, animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }, completion: {
            (finished: Bool) in
            fromView.alpha = 1.0

            transitionContext.completeTransition(finished)
        })
    }

}
