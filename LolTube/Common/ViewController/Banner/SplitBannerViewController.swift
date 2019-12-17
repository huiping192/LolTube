import Foundation
import UIKit

class SplitBannerViewController: UIViewController {
    @IBOutlet fileprivate var collectionView:UICollectionView!{
        didSet{
            collectionView.scrollsToTop = false
        }
    }
    
    fileprivate let imageLoadingOperationQueue = OperationQueue()
    
    var bannerItemList:[TopItem]?
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
    }
}


extension SplitBannerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerItemList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    fileprivate func loadImage(_ imageUrlString: String?, secondImageUrlString: String?, success:  @escaping (UIImage) -> Void) {
        guard let imageUrlString = imageUrlString else {
            return
        }

        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: secondImageUrlString, completed: success)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
    }
    
    fileprivate func bannerItem(_ indexPath:IndexPath) -> TopItem? {
        return bannerItemList?[indexPath.row]
    }
}

extension SplitBannerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height * 16/9,height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let bannerItem = bannerItem(indexPath) else {
            return
        }
        bannerItem.selectedAction(self)
    }
    
}
