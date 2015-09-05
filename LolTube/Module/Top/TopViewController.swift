import Foundation
import UIKit
import Async

class TopViewController: UIViewController {
    
    private enum SegueIdentifier:String {
        case videoDetail = "videoDetail"
        case Banner = "Banner"
    }
    
    private let cellDefaultWidth = CGFloat(145.0)
    private let cellDefaultHeight = CGFloat(140.0)
    private let cellImageHeightWidthRatio = CGFloat(9.0 / 16.0)
    private let cellMargin = CGFloat(8)
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var bannerContainerView: UIView!
    @IBOutlet private var videosCollectionView: UICollectionView!{
        didSet{
            videosCollectionView.scrollsToTop = false
        }
    }
    @IBOutlet private var collectionHeightConstraint: NSLayoutConstraint!
    
    private var bannerViewController: BannerViewController!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        return refreshControl
        }()
    
    
    private let viewModel = TopViewModel()
    private let imageLoadingOperationQueue = NSOperationQueue()
    private var channelVideoImageLoadingOperationDictionary = [String: NSOperation]()
    private var channelImageLoadingOperationDictionary = [String: NSOperation]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        loadVideosData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName:"Featured", viewType:TopViewController.self )
        
        videosCollectionView.collectionViewLayout.invalidateLayout()
        layoutCollectionViewSize()
    }
   
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        videosCollectionView.reloadData()
        layoutCollectionViewSize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        guard let segueIdString = segue.identifier , segueId = SegueIdentifier(rawValue: segueIdString)  else {
            return
        }
        
        switch segueId {
        case .videoDetail:
            guard let collectionViewCell = sender as? UICollectionViewCell,indexPath = videosCollectionView.indexPathForCell(collectionViewCell),video = video(indexPath) else {
                return
            }
            let videoDetailViewController = segue.destinationViewController(RSVideoDetailViewController.self)
            videoDetailViewController.videoId = video.videoId

        case .Banner:
            bannerViewController = segue.destinationViewController(BannerViewController.self)
        }
    }
    
    // MARK: data loading
    private func loadVideosData() {
        mainScrollView.alpha = 0.0
        startLoadingAnimation()
        
        let successBlock:(() -> Void) = {
            [weak self] in
            self?.configureTopView()
            self?.videosCollectionView.reloadData()
            self?.layoutCollectionViewSize()
            
            self?.stopLoadingAnimation()
            
            Async.main{
                UIView.animateWithDuration(0.1) {
                    [weak self] in
                    self?.mainScrollView.alpha = 1.0
                }
            }
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.showError(error)
            self?.stopLoadingAnimation()
        }
        
        viewModel.update(successBlock, failure: failureBlock)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        viewModel.update({
            [weak self] in
            self?.configureTopView()
            self?.videosCollectionView.reloadData()
            self?.layoutCollectionViewSize()
            refreshControl.endRefreshing()
            }, failure: {
                [weak self]error in
                self?.showError(error)
                refreshControl.endRefreshing()
            })
    }
    
    private func video(indexPath: NSIndexPath) -> Video? {
        guard let channel = channel(indexPath.section) where indexPath.row < viewModel.videoDictionary?[channel]?.count else {
            return nil
        }
        return viewModel.videoDictionary?[channel]?[indexPath.row]
    }
    
    private func channel(section: Int) -> Channel? {
        guard section < viewModel.channelList?.count else {
            return nil
        }
        return viewModel.channelList?[section]
    }
    
    // MARK: view cconfiguration
    private func layoutCollectionViewSize() {
        Async.main{               
            [unowned self] in
            self.collectionHeightConstraint.constant = self.videosCollectionView.contentSize.height
            self.videosCollectionView.layoutIfNeeded()
        }
    }
    
    private func configureView() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        videosCollectionView.scrollsToTop = false
        
        mainScrollView.addSubview(refreshControl)
    }
    
    private func configureTopView() {
        guard let topVideoList = viewModel.topVideoList else {
            return
        }
        bannerViewController.videoList = topVideoList
    }
    
}

// MARK: image loading
private extension TopViewController {
    
    func loadImage(url: String?, replaceImageUrl: String? = nil, success: (UIImage) -> Void) -> NSOperation? {
        guard let  imageUrlString = url  else {
            return nil
        }
        
        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: replaceImageUrl,completed:success)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
        return imageLoadOperation
    }
    
    func loadChannelVideoImage(videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        channelVideoImageLoadingOperationDictionary[videoId] = loadImage(imageUrlString, replaceImageUrl: secondImageUrlString, success: success)
    }
    
    func loadChannelImage(channelId: String, imageUrlString: String?, success: (UIImage) -> Void) {
        channelImageLoadingOperationDictionary[channelId] = loadImage(imageUrlString, success: success)
    }

}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var videoCount = 0
        if let channel = viewModel.channelList?[section],videoList = viewModel.videoDictionary?[channel] {
            videoCount = videoList.count
        }
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular) where section == 0:
            return min(videoCount,4)
        case (.Compact, .Compact):
            return min(videoCount,3)
        case (.Regular, .Compact):
            return min(videoCount,3)
        case (.Regular, .Regular):
            if view.frame.width > 768.0 {
                return min(videoCount,4)
            }
            return min(videoCount,3)
        default:
            return videoCount
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(indexPath,type:TopVideoCell.self)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.channelList?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(kind, indexPath: indexPath, type: TopVideoCollectionHeaderView.self)
            guard let channel = channel(indexPath.section) else {
                return headerView
            }
            
            headerView.titleLabel.text = channel.title
            
            headerView.moreButton.tag = indexPath.section
            headerView.moreButton.addTarget(self, action:"moreButtonTapped:", forControlEvents: .TouchUpInside)
            
            headerView.thumbnailImageView.image = nil
            loadChannelImage(channel.channelId, imageUrlString: channel.thumbnailUrl) {
                [weak headerView]image in
                headerView?.thumbnailImageView.image = image
            }
            
            headerView.tag = indexPath.section
            headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headerViewTapped:"))
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(kind, indexPath: indexPath, type: TopVideoCollectionFooterView.self)
            
            footerView.hidden = indexPath.section == collectionView.numberOfSections() - 1
            
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func headerViewTapped(gestureRecognizer: UITapGestureRecognizer){
        guard let view = gestureRecognizer.view , channel = channel(view.tag) else {
            return
        }
        
        navigationController?.pushViewController(instantiateChannelDetailViewController(id:channel.channelId,title:channel.title), animated: true)
    }
    
    func moreButtonTapped(button: UIButton){
        guard let channel = channel(button.tag) else {
            return
        }
        
        navigationController?.pushViewController(instantiateChannelDetailViewController(id:channel.channelId,title:channel.title), animated: true)
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath){
        guard let video = video(indexPath),cell = cell as? TopVideoCell else {
            return
        }
        
        cell.titleLabel.text = video.title
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        if (indexPath.row == 0 && indexPath.section != 0) {
            firstImageUrlString = video.highThumbnailUrl ?? video.thumbnailUrl
            secondImageUrlString = video.thumbnailUrl
        } else {
            firstImageUrlString = video.thumbnailUrl
            secondImageUrlString = nil
        }
        
        cell.thunmbnailImageView.image = nil
        loadChannelVideoImage(video.videoId, imageUrlString: firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: TopVideoCell.self)
            cell?.thunmbnailImageView.image = image
        }
        
        viewModel.updateVideoDetail(video, success: {
            [weak collectionView] in
            let cell = collectionView?.cell(indexPath, type: TopVideoCell.self)
            cell?.durationLabel.text = video.durationString
            cell?.viewCountLabel.text =  video.viewCountPublishedAt
            })
    }

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let video = video(indexPath),imageLoadingOperation = channelVideoImageLoadingOperationDictionary[video.videoId] else {
            return
        }
        imageLoadingOperation.cancel()
        channelVideoImageLoadingOperationDictionary.removeValueForKey(video.videoId)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        let cellCount: Int
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Regular, _ ):
            if view.frame.width > 768.0 {
                cellCount = 4
            } else {
                cellCount = 3
            }
        case (.Compact, .Regular) where indexPath.section > 0 && indexPath.row == 0:
            cellCount = 1
        case (.Compact, .Regular):
            cellCount = 2
        case (.Compact, .Compact):
            cellCount = 3
        default:
            cellCount = 3
        }
        
        let cellWidth = (collectionWidth - cellMargin * CGFloat(cellCount + 1)) / CGFloat(cellCount)
        let cellHeight = ((cellWidth - cellDefaultWidth) * cellImageHeightWidthRatio) + cellDefaultHeight
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellMargin, bottom: cellMargin, right: cellMargin)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        return section == collectionView.numberOfSections() - 1 ? CGSizeZero : CGSize(width: collectionView.frame.width, height: 12)
    }

}

extension TopViewController: UIGestureRecognizerDelegate {
    
}
