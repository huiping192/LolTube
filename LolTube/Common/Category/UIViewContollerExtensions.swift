import Foundation
import UIKit
import Cartography

private var loadingViewKey: UInt8 = 0

extension UIViewController {
    private var loadingView: UIView? {
        get {
            return objc_getAssociatedObject(self, &loadingViewKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &loadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func startLoadingAnimation(){
        let loadingView = UIView.loadFromNibNamed(.Loading)
        view.addSubview(loadingView)

        layout(loadingView){
            $0.center == $0.superview!.center
        }
        
        self.loadingView = loadingView
    }
    
    func stopLoadingAnimation(){
        guard let loadingView = loadingView else {
            return
        }
        
        loadingView.removeFromSuperview()
        self.loadingView = nil
    }
}