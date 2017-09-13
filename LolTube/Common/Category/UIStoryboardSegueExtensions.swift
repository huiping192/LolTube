import Foundation
import UIKit

extension UIStoryboardSegue {
    func destinationViewController<T:UIViewController>(_ type:T.Type) -> T {
        return destination as! T
    }
}
