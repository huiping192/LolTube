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
    
    private var scrollToNextVideoTimer:NSTimer?
    
    var videoList:[Video]?{
        didSet{
            var realVideoList = videoList
            if let firstItem = videoList?.first, lastItem = videoList?.last {
                realVideoList?.insert(lastItem, atIndex: 0)
                realVideoList?.append(firstItem)
                self.realVideoList = realVideoList
            }
        }
    }
    
    var realVideoList:[Video]?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (scrollToNextVideoTimer == nil) {
            startScrollToNextVideoTimer()
        }
        configureView()
    }
    
    private func configureView(){
        collectionView.reloadData()

        currentVideoTitleLabel.text = realVideoList?[1].title
        videoImagePageControl.numberOfPages = videoList?.count ?? 0
        videoImagePageControl.currentPage = 0
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .Left, animated: false)
    }

    func scrollToNextVideo(){
        guard let videoCount = realVideoList?.count else {
            return
        }
        let currentPage = Int(collectionView.contentOffset.x / collectionView.frame.width)
        let nextPage = currentPage + 1 >= videoCount - 1 ? 1 : currentPage + 1

        guard let video = realVideoList?[nextPage] else {
            return
        }
        let indexPath = NSIndexPath(forItem: nextPage, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)
        videoImagePageControl.currentPage = nextPage - 1
        currentVideoTitleLabel.text = video.title
    }
    
    private func startScrollToNextVideoTimer(){
        if let scrollToNextVideoTimer = scrollToNextVideoTimer {
            scrollToNextVideoTimer.invalidate()
        }
        scrollToNextVideoTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "scrollToNextVideo", userInfo: nil, repeats: true)
    }
    
    private func stopScrollToNextVideoTimer(){
        scrollToNextVideoTimer?.invalidate()
        scrollToNextVideoTimer = nil
    }
}


extension CombinedBannerViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        return realVideoList?.count ?? 0
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
        return realVideoList?[indexPath.row]
    }
}

extension CombinedBannerViewController: UICollectionViewDelegateFlowLayout {
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let realVideoList = realVideoList else {
            return 
        }
        let indexPath:NSIndexPath
        let rightWidth = scrollView.frame.width * CGFloat(realVideoList.count - 1)
        if scrollView.contentOffset.x == rightWidth {
            indexPath = NSIndexPath(forItem: 1, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
        } else if scrollView.contentOffset.x == 0 {
            indexPath = NSIndexPath(forItem: realVideoList.count - 2, inSection: 0)
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: realVideoList.count - 2, inSection: 0), atScrollPosition: .Left, animated: false)
        } else {            
            indexPath = NSIndexPath(forItem: Int(scrollView.contentOffset.x / scrollView.frame.width), inSection: 0)
        }
        
        let currentPage = indexPath.item
        let video = realVideoList[currentPage] 
        videoImagePageControl.currentPage = currentPage - 1
        currentVideoTitleLabel.text = video.title
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        stopScrollToNextVideoTimer()
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        startScrollToNextVideoTimer()
    }
    
}
