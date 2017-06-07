import Foundation
import UIKit

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable  var cornerRadius: CGFloat = 3.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard title(for: UIControlState()) != nil else {
            return
        }
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderColor = titleColor(for: UIControlState())?.cgColor
        layer.borderWidth = 1.0
    }
}
