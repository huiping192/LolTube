//
// Created by 郭 輝平 on 3/18/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundView: UIView {
    @IBInspectable  var cornerRadius: CGFloat = 3.0

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}