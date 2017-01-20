import Foundation
import UIKit
import TSMessages
import Cartography

extension UIViewController {
 
    func showError(error:NSError){
        let duration:NSTimeInterval = 1.5
        TSMessage.showNotificationInViewController(navigationController, title: error.domain, subtitle: error.localizedDescription, image: nil, type: TSMessageNotificationType.Error, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: TSMessageNotificationPosition.NavBarOverlay, canBeDismissedByUser: true)
    }
    
    func add(childViewController childViewController:UIViewController,containerView:UIView){
        let childView = childViewController.view
        containerView.addSubview(childView)
        constrain(childView, containerView) { childView, containerView in
            childView.edges == containerView.edges
        }
        addChildViewController(childViewController)
        childViewController.didMoveToParentViewController(self)
    }
    
    func remove(childViewController childViewController:UIViewController){
        childViewController.willMoveToParentViewController(self)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
}
