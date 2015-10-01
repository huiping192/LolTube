import Foundation
import UIKit

class SplitBannerViewController: UIViewController {
    @IBOutlet private var collectionView:UICollectionView!{
        didSet{
            collectionView.scrollsToTop = false
        }
    }
    
    private let imageLoadingOperationQueue = NSOperationQueue()
    
    var bannerItemList:[TopItem]?
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .None, animated: false)
    }
}


extension SplitBannerViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerItemList?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath,type:BannerCell.self)
        guard let bannerItem = bannerItem(indexPath) else {
            return cell
        }
        
        cell.titleLabel?.text = bannerItem.title
        cell.thunmbnailImageView.image = nil
        let firstImageUrlString = bannerItem.highThumbnailUrl ?? bannerItem.thumbnailUrl
        let secondImageUrlString = bannerItem.thumbnailUrl
        loadImage(firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: BannerCell.self)
            cell?.thunmbnailImageView.image = image
        }
        
        return cell
    }
    
    private func loadImage(imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        guard let imageUrlString = imageUrlString else {
            return
        }

        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: secondImageUrlString, completed: success)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
    }
    
    private func bannerItem(indexPath:NSIndexPath) -> TopItem? {
        return bannerItemList?[indexPath.row]
    }
}

extension SplitBannerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height * 16/9,height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let bannerItem = bannerItem(indexPath) else {
            return
        }
        bannerItem.selectedAction(sourceViewController: self)
    }
    
}
