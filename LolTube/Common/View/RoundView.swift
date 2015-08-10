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

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = borderWidth
    }
}
