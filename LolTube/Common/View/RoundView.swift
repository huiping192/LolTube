//
// Created by 郭 輝平 on 3/18/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundView: UIView {
    @IBInspectable  var cornerRadius: CGFloat = 3.0
    @IBInspectable  var borderWidth: CGFloat = 0.5

    let mainColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        
        layer.borderColor = mainColor.CGColor
        layer.borderWidth = borderWidth
        
        backgroundColor = mainColor
    }
}
