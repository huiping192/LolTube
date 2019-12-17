import Foundation
import UIKit

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable  var cornerRadius: CGFloat = 3.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard title(for: UIControl.State()) != nil else {
            return
        }
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderColor = titleColor(for: UIControl.State())?.cgColor
        layer.borderWidth = 1.0
    }
}
