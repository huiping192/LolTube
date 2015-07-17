import Foundation
import UIKit

extension UIStoryboardSegue {
    func destinationViewController<T:UIViewController>(type:T.Type) -> T {
        return destinationViewController as! T
    }
}