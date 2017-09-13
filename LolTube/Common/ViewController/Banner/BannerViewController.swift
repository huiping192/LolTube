import Foundation
import UIKit

class BannerViewController:UIViewController {
    
    @IBOutlet fileprivate var containView:UIView!
    
    fileprivate weak var combinedBannerViewController: CombinedBannerViewController?
    fileprivate weak var splitBannerViewController: SplitBannerViewController?

    fileprivate var currentViewController: UIViewController?

    var bannerItemList:[TopItem]!{
        didSet{
            if currentViewController == nil {
                configureViewController(traitCollection, transitionCoordinator: nil)
            }
            combinedBannerViewController?.bannerItemList = bannerItemList
            splitBannerViewController?.bannerItemList = bannerItemList
        }
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator){
        configureViewController(newCollection, transitionCoordinator: coordinator)
    }
    
    
    fileprivate func configureViewController(_ newCollection: UITraitCollection, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator?) {
        guard bannerItemList != nil else {
            return
        }
        switch (newCollection.horizontalSizeClass, newCollection.verticalSizeClass) {
        case (.compact, .regular) :
            combinedBannerViewController = configureChildViewController(combinedBannerViewController){
                [unowned self] in
                return ViewControllerFactory.instantiateCombinedBannerViewController(self.bannerItemList)
            }
        default:
            splitBannerViewController = configureChildViewController(splitBannerViewController){
                [unowned self] in
                return ViewControllerFactory.instantiateSplitBannerViewController(self.bannerItemList)
            }
        }

    }

    fileprivate func configureChildViewController<T:UIViewController>(_ childViewController:T?,initBlock:(() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
    }
    
    func swapToChildViewController(_ childViewController:UIViewController){
        if let currentViewController = currentViewController {
            remove(childViewController:currentViewController)
        }
        add(childViewController:childViewController,containerView:containView)
        currentViewController = childViewController
    }
}
