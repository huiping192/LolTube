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
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.black]
        titleTextAttributes = navbarTitleTextAttributes
        
        shadowImage = nil
        setBackgroundImage(nil, for: .default)
        isTranslucent = false
        tintColor = UIApplication.shared.keyWindow?.tintColor
        barStyle = .default;
    }
    
    fileprivate func clearStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.white]
        titleTextAttributes = navbarTitleTextAttributes
        
        let clearImage = UIImage(color:UIColor.clear)
        shadowImage = clearImage
        setBackgroundImage(clearImage, for: .default)
        isTranslucent = true
        tintColor = UIColor.white
        barStyle = .black;
    }
    
    fileprivate func clearBlackStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.black]
        titleTextAttributes = navbarTitleTextAttributes
        
        let clearImage = UIImage(color:UIColor.clear)
        shadowImage = clearImage
        setBackgroundImage(clearImage, for: .default)
        isTranslucent = true
        tintColor = UIApplication.shared.keyWindow?.tintColor
        barStyle = .default;
    }
}
