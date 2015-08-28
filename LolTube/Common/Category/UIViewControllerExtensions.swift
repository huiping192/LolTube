import Foundation
import UIKit
import TSMessages
import Cartography

extension UIViewController {
 
    func showError(error:NSError){
        let duration:NSTimeInterval = 1.5
        TSMessage.showNotificationInViewController(navigationController, title: error.domain, subtitle: error.localizedDescription, image: nil, type: TSMessageNotificationType.Error, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: TSMessageNotificationPosition.NavBarOverlay, canBeDismissedByUser: true)
    }
    
    func add(childViewController:UIViewController,containerView:UIView){
        let childView = childViewController.view
        containerView.addSubview(childView)
        layout(childView, containerView) { childView, containerView in
            childView.edges == containerView.edges
        }
        addChildViewController(childViewController)
        childViewController.didMoveToParentViewController(self)
    }
    
    func remove(viewController:UIViewController){
        viewController.willMoveToParentViewController(self)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}