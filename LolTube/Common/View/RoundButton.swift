import Foundation
import UIKit

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable  var cornerRadius: CGFloat = 3.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderColor = tintColor.CGColor
        layer.borderWidth = 1.0
    }
}
