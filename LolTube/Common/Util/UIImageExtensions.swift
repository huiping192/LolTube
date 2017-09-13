import Foundation
import UIKit

protocol UIImageType {
    associatedtype Selfy
    static func build(_ color: UIColor) -> Selfy
}

extension UIImageType where Selfy == Self {
    init(color:UIColor) {
        self = Self.build(color)
    }
}

extension UIImage: UIImageType {
    static func build(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIImage {
    static var defaultImage:UIImage {
        return UIImage(named:"DefaultThumbnail")!
    }
}
