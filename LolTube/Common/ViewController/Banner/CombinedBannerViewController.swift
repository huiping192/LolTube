import Foundation
import UIKit
import Async
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CombinedBannerViewController:UIViewController {
    @IBOutlet fileprivate var collectionView:UICollectionView!{
        didSet{
            collectionView.scrollsToTop = false
        }
    }
    @IBOutlet fileprivate var currentVideoTitleLabel:UILabel!
    @IBOutlet fileprivate var videoImagePageControl: UIPageControl!
    
    fileprivate let imageLoadingOperationQueue = OperationQueue()
    
    fileprivate var scrollToNextVideoTimer:Timer?
    
    var bannerItemList:[TopItem]?{
        didSet{
            var realVideoList = bannerItemList
            if let firstItem = bannerItemList?.first, let lastItem = bannerItemList?.last {
                realVideoList?.insert(lastItem, at: 0)
                realVideoList?.append(firstItem)
                self.realVideoList = realVideoList
            }
        }
    }
    
    var realVideoList:[TopItem]?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (scrollToNextVideoTimer == nil) {
            startScrollToNextVideoTimer()
        }
        configureView()
    }
    
    fileprivate func configureView(){
        collectionView.reloadData()

        currentVideoTitleLabel.text = realVideoList?[1].title
        videoImagePageControl.numberOfPages = bannerItemList?.count ?? 0
        videoImagePageControl.currentPage = 0
        if realVideoList?.count > 0 {
           collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false) 
        }
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
        let indexPath = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        videoImagePageControl.currentPage = nextPage - 1
        currentVideoTitleLabel.text = video.title
    }
    
    fileprivate func startScrollToNextVideoTimer(){
        if let scrollToNextVideoTimer = scrollToNextVideoTimer {
            scrollToNextVideoTimer.invalidate()
        }
        scrollToNextVideoTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(CombinedBannerViewController.scrollToNextVideo), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopScrollToNextVideoTimer(){
        scrollToNextVideoTimer?.invalidate()
        scrollToNextVideoTimer = nil
    }
}


extension CombinedBannerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        return realVideoList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath,type:BannerCell.self)
        guard let banner = bannerItem(indexPath) else {
            return cell
        }
        
        let firstImageUrlString = banner.highThumbnailUrl ?? banner.thumbnailUrl
        let secondImageUrlString = banner.thumbnailUrl
        loadImage(firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: BannerCell.self)
            cell?.thunmbnailImageView.image = image
        }
        
        return cell
    }
    
    fileprivate func loadImage(_ imageUrlString: String?, secondImageUrlString: String?, success: @escaping (UIImage) -> Void) {
        guard let imageUrlString = imageUrlString else {
            return
        }
        
        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: secondImageUrlString, completed: success)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
    }
    
    fileprivate func bannerItem(_ indexPath:IndexPath) -> TopItem? {
        return realVideoList?[indexPath.row]
    }
}

extension CombinedBannerViewController: UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        guard let bannerItem = bannerItem(indexPath) else {
            return
        }

        bannerItem.selectedAction(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let realVideoList = realVideoList else {
            return 
        }
        let indexPath:IndexPath
        let rightWidth = scrollView.frame.width * CGFloat(realVideoList.count - 1)
        if scrollView.contentOffset.x == rightWidth {
            indexPath = IndexPath(item: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        } else if scrollView.contentOffset.x == 0 {
            indexPath = IndexPath(item: realVideoList.count - 2, section: 0)
            collectionView.scrollToItem(at: IndexPath(item: realVideoList.count - 2, section: 0), at: .left, animated: false)
        } else {            
            indexPath = IndexPath(item: Int(scrollView.contentOffset.x / scrollView.frame.width), section: 0)
        }
        
        let currentPage = indexPath.item
        let video = realVideoList[currentPage] 
        videoImagePageControl.currentPage = currentPage - 1
        currentVideoTitleLabel.text = video.title
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        stopScrollToNextVideoTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        startScrollToNextVideoTimer()
    }
    
}
