import Foundation
import UIKit
import TSMessages
import Cartography

extension UIViewController {
 
    func showError(_ error:NSError){
        let duration:TimeInterval = 1.5
        TSMessage.showNotification(in: navigationController, title: error.domain, subtitle: error.localizedDescription, image: nil, type: TSMessageNotificationType.error, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, at: TSMessageNotificationPosition.navBarOverlay, canBeDismissedByUser: true)
    }
    
    func add(childViewController:UIViewController,containerView:UIView){
        let childView = childViewController.view
        containerView.addSubview(childView!)
        constrain(childView!, containerView) { childView, containerView in
            childView.edges == containerView.edges
        }
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
    }
    
    func remove(childViewController:UIViewController){
        childViewController.willMove(toParentViewController: self)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
}
