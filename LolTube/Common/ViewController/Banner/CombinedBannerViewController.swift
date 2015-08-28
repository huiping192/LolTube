import Foundation
import UIKit
import Async

class CombinedBannerViewController:UIViewController {
    @IBOutlet private var collectionView:UICollectionView!{
        didSet{
            collectionView.scrollsToTop = false
        }
    }
    @IBOutlet private var currentVideoTitleLabel:UILabel!
    @IBOutlet private var videoImagePageControl: UIPageControl!
    
    private let imageLoadingOperationQueue = NSOperationQueue()
    private var imageLoadingOperationDictionary = [String: NSOperation]()
    
    var videoList:[Video]?{
        didSet{
            configureView()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let currentPageNumber = videoImagePageControl.currentPage
        self.collectionView.alpha = 3.0
        coordinator.animateAlongsideTransition({
            [unowned self] _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentPageNumber, inSection: 0), atScrollPosition: .None, animated: false)
            }, completion: {
                [unowned self] _ in
                self.collectionView.alpha = 1.0
            })
    }
    
    private func configureView(){
        guard let collectionView = collectionView else {
            return
        }
        collectionView.reloadData()

        currentVideoTitleLabel.text = videoList?[0].title
        videoImagePageControl.numberOfPages = videoList?.count ?? 0
        videoImagePageControl.currentPage = 0
    }

}


extension CombinedBannerViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath,type:BannerCell.self)
        guard let video = video(indexPath) else {
            return cell
        }
        
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

extension CombinedBannerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath){
        guard let video = videoList?[indexPath.item] else {
            return
        }
        videoImagePageControl.currentPage = indexPath.item
        currentVideoTitleLabel.text = video.title
    }

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let video = video(indexPath) , imageLoadingOperation = imageLoadingOperationDictionary[video.videoId] else {
            return
        }
        imageLoadingOperation.cancel()
        imageLoadingOperationDictionary.removeValueForKey(video.videoId)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        guard let video = video(indexPath) else {
            return
        }
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}
