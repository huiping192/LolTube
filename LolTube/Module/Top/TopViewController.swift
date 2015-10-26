import Foundation
import UIKit
import AsyncSwift

class TopViewController: UIViewController {
    
    private enum SegueIdentifier:String {
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
    
    private var backgroundFetchOperation: NSOperation?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        return refreshControl
        }()
    
    
    private let viewModel = TopViewModel()
    private let imageLoadingOperationQueue = NSOperationQueue()
    private var channelVideoImageLoadingOperationDictionary = [String: NSOperation]()
    
    private var prevFrame:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventTracker.trackViewContentView(viewName:"Featured", viewType:TopViewController.self )
        
        videosCollectionView.addObserver(self, forKeyPath: "contentSize", options: .Old, context: nil)
        
        configureView()
        loadVideosData()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath == "contentSize" && object === videosCollectionView else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        Async.main{
            self.collectionHeightConstraint.constant = self.videosCollectionView.contentSize.height
            self.mainScrollView.layoutIfNeeded()
        }
    }
    
    deinit{
        videosCollectionView.removeObserver(self, forKeyPath: "contentSize")
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.videosCollectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        guard let segueIdString = segue.identifier , segueId = SegueIdentifier(rawValue: segueIdString)  else {
            return
        }
        
        switch segueId {
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
            
            self?.stopLoadingAnimation()
            
            UIView.animateWithDuration(0.1) {
                self?.mainScrollView.alpha = 1.0
            }
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.showError(error)
            self?.stopLoadingAnimation()
            self?.mainScrollView.alpha = 1.0
        }
        
        viewModel.update(successBlock, failure: failureBlock)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        let successBlock:(() -> Void) = {
            [weak self] in
            self?.configureTopView()
            self?.videosCollectionView.reloadData()
            refreshControl.endRefreshing()
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.showError(error)
            refreshControl.endRefreshing()
        }
        
        viewModel.update(successBlock, failure: failureBlock)
    }
    
    private func topItem(indexPath: NSIndexPath) -> TopItem? {
        guard let channel = channel(indexPath.section) where indexPath.row < viewModel.videoDictionary?[channel.id]?.count else {
            return nil
        }
        return viewModel.videoDictionary?[channel.id]?[indexPath.row]
    }
    
    private func channel(section: Int) -> Channel? {
        guard section < viewModel.channelList?.count else {
            return nil
        }
        return viewModel.channelList?[section]
    }
    
    private func configureView() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        videosCollectionView.scrollsToTop = false
        
        mainScrollView.addSubview(refreshControl)
    }
    
    private func configureTopView() {
        guard let topVideoList = viewModel.bannerItemList else { return }
        
        bannerViewController.bannerItemList = topVideoList.map{$0 as TopItem}
    }
    
}

// MARK: image loading
private extension TopViewController {
    
    func loadImage(url: String?, replaceImageUrl: String? = nil, success: (UIImage) -> Void) -> NSOperation? {
        guard let  imageUrlString = url  else { return nil }
        
        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: replaceImageUrl,completed:success)
        backgroundFetchOperation?.addDependency(imageLoadOperation)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
        return imageLoadOperation
    }
    
    func loadChannelVideoImage(videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        channelVideoImageLoadingOperationDictionary[videoId] = loadImage(imageUrlString, replaceImageUrl: secondImageUrlString, success: success)
    }
    
    func loadChannelImage(channel: Channel, success: (UIImage) -> Void) {
        switch channel.thumbnailType {
        case .Local:
            guard let thumbnailUrl = channel.thumbnailUrl , image = UIImage(named: thumbnailUrl) else {
                success(UIImage.defaultImage)
                return
            }
            success(image)
        case .Remote:
            loadImage(channel.thumbnailUrl, success: success)
        }
    }
    
}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        var videoCount = 0
        if let channel = viewModel.channelList?[section],videoList = viewModel.videoDictionary?[channel.id] {
            videoCount = videoList.count
        }
        
        return min(preferItemCount(section),videoCount)
        
    }
    
    private func preferItemCount(section:Int) -> Int{
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular) where section == 0:
            return 6
        case (.Compact, .Regular):
            return 5
        case (.Compact, .Compact):
            return 3
        case (.Regular, .Compact):
            return 3
        case (.Regular, .Regular):
            if view.frame.width > 768.0 {
                return 4
            }
            return 3
        default:
            return 5
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
            
            headerView.thumbnailImageView.image = nil
            loadChannelImage(channel) {
                [weak headerView]image in
                headerView?.thumbnailImageView.image = image
            }
            
            headerView.moreButton.hidden = !channel.selectable
            headerView.gestureRecognizers?.filter{$0 is UITapGestureRecognizer}.forEach{ headerView.removeGestureRecognizer($0) }
            
            if channel.selectable {
                headerView.moreButton.tag = indexPath.section
                headerView.moreButton.addTarget(self, action:"moreButtonTapped:", forControlEvents: .TouchUpInside)
                
                headerView.tag = indexPath.section
                headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headerViewTapped:"))
            }
            
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
        guard let view = gestureRecognizer.view , channel = channel(view.tag) else { return }
        
        channel.selectedAction?(sourceViewController: self)
    }
    
    func moreButtonTapped(button: UIButton){
        guard let channel = channel(button.tag) else { return }
        
        channel.selectedAction?(sourceViewController: self)
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {        
        guard let topItem = topItem(indexPath) else { return }
        topItem.selectedAction(sourceViewController: self)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath){
        guard let topItem = topItem(indexPath),cell = cell as? TopVideoCell else { return }
        
        cell.titleLabel.text = topItem.title
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        
        if (indexPath.row == 0 && indexPath.section != 0) && (traitCollection.horizontalSizeClass == .Compact && traitCollection.verticalSizeClass == .Regular) {
            firstImageUrlString = topItem.highThumbnailUrl ?? topItem.thumbnailUrl
            secondImageUrlString = topItem.thumbnailUrl
        } else {
            firstImageUrlString = topItem.thumbnailUrl
            secondImageUrlString = nil
        }
        
        cell.thunmbnailImageView.image = nil
        loadChannelVideoImage(topItem.id, imageUrlString: firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: TopVideoCell.self)
            cell?.thunmbnailImageView.image = image
        }
        
        if let video = topItem as? Video {
            viewModel.updateVideoDetail(video){
                [weak collectionView] in
                let cell = collectionView?.cell(indexPath, type: TopVideoCell.self)
                cell?.durationLabel.text = video.durationString
                cell?.viewCountLabel.text =  video.subTitle
            }
        } else {
            cell.viewCountLabel.text =  topItem.subTitle
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let topItem = topItem(indexPath),imageLoadingOperation = channelVideoImageLoadingOperationDictionary[topItem.id] else {
            return
        }
        imageLoadingOperation.cancel()
        channelVideoImageLoadingOperationDictionary.removeValueForKey(topItem.id)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        let cellCount = cellCountPreLine(indexPath)
        
        let cellWidth = (collectionWidth - cellMargin * CGFloat(cellCount + 1)) / CGFloat(cellCount)
        let cellHeight = ((cellWidth - cellDefaultWidth) * cellImageHeightWidthRatio) + cellDefaultHeight
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    private func cellCountPreLine(indexPath: NSIndexPath) -> Int {
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
        return cellCount
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellMargin, bottom: cellMargin, right: cellMargin)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        return section == collectionView.numberOfSections() - 1 ? CGSizeZero : CGSize(width: collectionView.frame.width, height: 8)
    }
    
}

extension TopViewController: UIGestureRecognizerDelegate {
    
}

extension TopViewController {
    override func fetchNewData(completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let backgroundFetchOperation = backgroundFetchOperation where backgroundFetchOperation.finished == false {
            completionHandler(.NoData)
            return
        }
        
        backgroundFetchOperation = NSBlockOperation(block: {
            [weak self] in
            completionHandler(.NewData)
            self?.backgroundFetchOperation = nil
            })
        viewModel.update({
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureTopView()
            strongSelf.videosCollectionView.reloadData(){
                if let backgroundFetchOperation = strongSelf.backgroundFetchOperation {
                    strongSelf.imageLoadingOperationQueue.addOperation(backgroundFetchOperation)
                }
            }
            }, failure: {
                [weak self]_ in
                self?.backgroundFetchOperation = nil
                completionHandler(.Failed)
            })
    }
}
