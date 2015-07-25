import Foundation
import UIKit

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable  var cornerRadius: CGFloat = 3.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard titleForState(.Normal) != nil else {
            return
        }
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderColor = titleColorForState(.Normal)?.CGColor
        layer.borderWidth = 1.0
    }
}
