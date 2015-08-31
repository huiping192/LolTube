import Foundation
import UIKit

class BannerViewController:UIViewController {
    
    @IBOutlet private var containView:UIView!
    
    private weak var combinedBannerViewController: CombinedBannerViewController?
    private weak var splitBannerViewController: SplitBannerViewController?

    private var currentViewController: UIViewController?

    var videoList:[Video]!{
        didSet{
            if currentViewController == nil {
                configureViewController(traitCollection, transitionCoordinator: nil)
            }
            combinedBannerViewController?.videoList = videoList
            splitBannerViewController?.videoList = videoList
        }
    }
    
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        configureViewController(newCollection, transitionCoordinator: coordinator)
    }
    
    
    private func configureViewController(newCollection: UITraitCollection, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator?) {
        guard videoList != nil else {
            return
        }
        switch (newCollection.horizontalSizeClass, newCollection.verticalSizeClass) {
        case (.Compact, .Regular) :
            combinedBannerViewController = configureChildViewController(combinedBannerViewController){
                [unowned self] in
                return self.instantiateCombinedBannerViewController(self.videoList)
            }
        default:
            splitBannerViewController = configureChildViewController(splitBannerViewController){
                [unowned self] in
                return self.instantiateSplitBannerViewController(self.videoList)
            }
        }

    }

    private func configureChildViewController<T:UIViewController>(childViewController:T?,initBlock:(() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
    }
    
    func swapToChildViewController(childViewController:UIViewController){
        if let currentViewController = currentViewController {
            remove(childViewController:currentViewController)
        }
        add(childViewController:childViewController,containerView:containView)
        currentViewController = childViewController
    }
}
