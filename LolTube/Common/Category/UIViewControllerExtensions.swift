import Foundation
import UIKit
import TSMessages

extension UIViewController {
 
    func showError(error:NSError){
        let duration:NSTimeInterval = 1.5
        TSMessage.showNotificationInViewController(navigationController, title: error.domain, subtitle: error.localizedDescription, image: nil, type: TSMessageNotificationType.Error, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: TSMessageNotificationPosition.NavBarOverlay, canBeDismissedByUser: true)
    }
}