import Foundation
import UIKit

extension UIView {
    
    enum NibName:String {
        case Loading = "Loading"
    }
    
    class func loadFromNibNamed(_ nibName: NibName, bundle : Bundle? = nil) -> UIView {
        return UINib(
            nibName: nibName.rawValue,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
