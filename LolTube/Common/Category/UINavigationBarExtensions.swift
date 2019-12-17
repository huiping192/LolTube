import Foundation
import UIKit

enum NavigationBarStyle {
    case `default`
    case clear
    case clearBlack
}

extension UINavigationBar {
    func configureNavigationBar(_ style:NavigationBarStyle){
        switch style {
        case .default:
            defalutStyle()
        case .clear:
            clearStyle()
        case .clearBlack:
            clearBlackStyle()
        }
    }
    
    fileprivate func defalutStyle(){
        titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        shadowImage = nil
        setBackgroundImage(nil, for: .default)
        isTranslucent = false
        tintColor = UIApplication.shared.keyWindow?.tintColor
        barStyle = .default;
    }
    
    fileprivate func clearStyle(){
        titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let clearImage = UIImage(color:UIColor.clear)
        shadowImage = clearImage
        setBackgroundImage(clearImage, for: .default)
        isTranslucent = true
        tintColor = UIColor.white
        barStyle = .black;
    }
    
    fileprivate func clearBlackStyle(){
        titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        let clearImage = UIImage(color:UIColor.clear)
        shadowImage = clearImage
        setBackgroundImage(clearImage, for: .default)
        isTranslucent = true
        tintColor = UIApplication.shared.keyWindow?.tintColor
        barStyle = .default;
    }
}
