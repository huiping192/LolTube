import Foundation
import UIKit

enum NavigationBarStyle {
    case Default
    case Clear
    case ClearBlack
}

extension UINavigationBar {
    func configureNavigationBar(style:NavigationBarStyle){
        switch style {
        case .Default:
            defalutStyle()
        case .Clear:
            clearStyle()
        case .ClearBlack:
            clearBlackStyle()
        }
    }
    
    private func defalutStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.blackColor()]
        titleTextAttributes = navbarTitleTextAttributes
        barStyle = .Default;
    }
    
    private func clearStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        titleTextAttributes = navbarTitleTextAttributes
        barStyle = .Black;
    }
    
    private func clearBlackStyle(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.blackColor()]
        titleTextAttributes = navbarTitleTextAttributes
        barStyle = .Default;
    }
}
