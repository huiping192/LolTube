//
// Created by 郭 輝平 on 4/7/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircularImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = frame.size.width / 2;
    }
}
