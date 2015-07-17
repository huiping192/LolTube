import Foundation
import UIKit

enum NavigationBarStyle {
    case Default
    case Clear
}

extension UINavigationBar {
    func configureNavigationBar(style:NavigationBarStyle){
        switch style {
        case .Default:
            defalutStyle()
        case .Clear:
            clearStyle()
        }
    }
    
    private func defalutStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.blackColor()]
        titleTextAttributes = navbarTitleTextAttributes
        
        shadowImage = nil
        setBackgroundImage(nil, forBarMetrics: .Default)
        translucent = false
        tintColor = UIApplication.sharedApplication().keyWindow?.tintColor
        barStyle = .Default;
    }
    
    private func clearStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        titleTextAttributes = navbarTitleTextAttributes
        
        let clearImage = UIImage(color:UIColor.clearColor())
        shadowImage = clearImage
        setBackgroundImage(clearImage, forBarMetrics: .Default)
        translucent = true
        tintColor = UIColor.whiteColor()
        barStyle = .Black;
    }
}
