import Foundation
import UIKit

protocol UIImageType {
    typealias Selfy
    static func build(color: UIColor) -> Selfy
}

extension UIImageType where Selfy == Self {
    init(color:UIColor) {
        self = Self.build(color)
    }
}

extension UIImage: UIImageType {
    static func build(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
