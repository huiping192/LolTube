import Foundation
import UIKit

class BannerViewController:UIViewController {
    
    @IBOutlet private var containView:UIView!
    
    private weak var combinedBannerViewController: CombinedBannerViewController?
    private weak var splitBannerViewController: SplitBannerViewController?

    private var currentViewController: UIViewController?

    var bannerItemList:[BannerItem]!{
        didSet{
            if currentViewController == nil {
                configureViewController(traitCollection, transitionCoordinator: nil)
            }
            combinedBannerViewController?.bannerItemList = bannerItemList
            splitBannerViewController?.bannerItemList = bannerItemList
        }
    }
    
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        configureViewController(newCollection, transitionCoordinator: coordinator)
    }
    
    
    private func configureViewController(newCollection: UITraitCollection, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator?) {
        guard bannerItemList != nil else {
            return
        }
        switch (newCollection.horizontalSizeClass, newCollection.verticalSizeClass) {
        case (.Compact, .Regular) :
            combinedBannerViewController = configureChildViewController(combinedBannerViewController){
                [unowned self] in
                return self.instantiateCombinedBannerViewController(self.bannerItemList)
            }
        default:
            splitBannerViewController = configureChildViewController(splitBannerViewController){
                [unowned self] in
                return self.instantiateSplitBannerViewController(self.bannerItemList)
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
