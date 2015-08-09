import Foundation
import UIKit

extension UIView {
    
    enum NibName:String {
        case Loading = "Loading"
    }
    
    class func loadFromNibNamed(nibName: NibName, bundle : NSBundle? = nil) -> UIView {
        return UINib(
            nibName: nibName.rawValue,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
}