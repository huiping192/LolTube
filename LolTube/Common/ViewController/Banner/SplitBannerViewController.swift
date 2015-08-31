import Foundation
import UIKit

class SplitBannerViewController: UIViewController {
    @IBOutlet private var collectionView:UICollectionView!{
        didSet{
            collectionView.scrollsToTop = false
        }
    }
    
    private let imageLoadingOperationQueue = NSOperationQueue()
    private var imageLoadingOperationDictionary = [String: NSOperation]()
    
    var videoList:[Video]?
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .None, animated: false)
    }
}


extension SplitBannerViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath,type:BannerCell.self)
        guard let video = video(indexPath) else {
            return cell
        }
        
        cell.titleLabel?.text = video.title
        cell.thunmbnailImageView.image = nil
        let firstImageUrlString = video.highThumbnailUrl ?? video.thumbnailUrl
        let secondImageUrlString = video.thumbnailUrl
        loadVideoImage(video.videoId, imageUrlString: firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: BannerCell.self)
            cell?.thunmbnailImageView.image = image
        }
        
        return cell
    }
    
    private func loadVideoImage(videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        guard let imageUrlString = imageUrlString else {
            return
        }

        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: secondImageUrlString, completed: success)
        
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
        imageLoadingOperationDictionary[videoId] = imageLoadOperation
    }
    
    private func video(indexPath:NSIndexPath) -> Video? {
        return videoList?[indexPath.row]
    }
}

extension SplitBannerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let video = video(indexPath) , imageLoadingOperation = imageLoadingOperationDictionary[video.videoId] else {
            return
        }
        imageLoadingOperation.cancel()
        imageLoadingOperationDictionary.removeValueForKey(video.videoId)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height * 16/9,height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let video = video(indexPath) else {
            return
        }
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
    
}
