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


class TopViewController: UIViewController {
    
    fileprivate enum SegueIdentifier:String {
        case Banner = "Banner"
    }
    
    fileprivate let cellDefaultWidth = CGFloat(145.0)
    fileprivate let cellDefaultHeight = CGFloat(140.0)
    fileprivate let cellImageHeightWidthRatio = CGFloat(9.0 / 16.0)
    fileprivate let cellMargin = CGFloat(8)
    
    @IBOutlet fileprivate var mainScrollView: UIScrollView!
    @IBOutlet fileprivate var bannerContainerView: UIView!
    @IBOutlet fileprivate var videosCollectionView: UICollectionView!{
        didSet{
            videosCollectionView.scrollsToTop = false
        }
    }
    @IBOutlet fileprivate var collectionHeightConstraint: NSLayoutConstraint!
    
    fileprivate var bannerViewController: BannerViewController!
    
    fileprivate var backgroundFetchOperation: Operation?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopViewController.refresh(_:)), for: .valueChanged)
        return refreshControl
        }()
    
    
    fileprivate let viewModel = TopViewModel()
    fileprivate let imageLoadingOperationQueue = OperationQueue()
    fileprivate var channelVideoImageLoadingOperationDictionary = [String: Operation]()
    
    fileprivate var prevFrame:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventTracker.trackViewContentView(viewName:"Featured", viewType:TopViewController.self )
        
        videosCollectionView.addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)
        
        configureView()
        loadVideosData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let collectionView = object as? UICollectionView, keyPath == "contentSize" && collectionView  === videosCollectionView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.videosCollectionView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdString = segue.identifier , let segueId = SegueIdentifier(rawValue: segueIdString)  else {
            return
        }
        
        switch segueId {
        case .Banner:
            bannerViewController = segue.destinationViewController(BannerViewController.self)
        }
    }
    
    // MARK: data loading
    fileprivate func loadVideosData() {
        mainScrollView.alpha = 0.0
        startLoadingAnimation()
        
        let successBlock:(() -> Void) = {
            [weak self] in
            
            self?.configureTopView()
            self?.videosCollectionView.reloadData()
            
            self?.stopLoadingAnimation()
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.mainScrollView.alpha = 1.0
            }) 
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.showError(error)
            self?.stopLoadingAnimation()
            self?.mainScrollView.alpha = 1.0
        }
        
        viewModel.update(successBlock, failure: failureBlock)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
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
    
    fileprivate func topItem(_ indexPath: IndexPath) -> TopItem? {
        guard let channel = channel(indexPath.section), indexPath.row < viewModel.videoDictionary?[channel.id]?.count else {
            return nil
        }
        return viewModel.videoDictionary?[channel.id]?[indexPath.row]
    }
    
    fileprivate func channel(_ section: Int) -> Channel? {
        guard section < viewModel.channelList?.count else {
            return nil
        }
        return viewModel.channelList?[section]
    }
    
    fileprivate func configureView() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        videosCollectionView.scrollsToTop = false
        
        mainScrollView.addSubview(refreshControl)
    }
    
    fileprivate func configureTopView() {
        guard let topVideoList = viewModel.bannerItemList else { return }
        
        bannerViewController.bannerItemList = topVideoList.map{$0 as TopItem}
    }
    
}

// MARK: image loading
private extension TopViewController {
    
    func loadImage(_ url: String?, replaceImageUrl: String? = nil, success: @escaping (UIImage) -> Void) -> Operation? {
        guard let  imageUrlString = url  else { return nil }
        
        let imageLoadOperation = ImageLoadOperation(url: imageUrlString, replaceImageUrl: replaceImageUrl,completed:success)
        backgroundFetchOperation?.addDependency(imageLoadOperation)
        imageLoadingOperationQueue.addOperation(imageLoadOperation)
        return imageLoadOperation
    }
    
    func loadChannelVideoImage(_ videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: @escaping (UIImage) -> Void) {
        channelVideoImageLoadingOperationDictionary[videoId] = loadImage(imageUrlString, replaceImageUrl: secondImageUrlString, success: success)
    }
    
    func loadChannelImage(_ channel: Channel, success: @escaping (UIImage) -> Void) {
        switch channel.thumbnailType {
        case .local:
            guard let thumbnailUrl = channel.thumbnailUrl , let image = UIImage(named: thumbnailUrl) else {
                success(UIImage.defaultImage)
                return
            }
            success(image)
        case .remote:
            loadImage(channel.thumbnailUrl, success: success)
        }
    }
    
}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        var videoCount = 0
        if let channel = viewModel.channelList?[section],let videoList = viewModel.videoDictionary?[channel.id] {
            videoCount = videoList.count
        }
        
        return min(preferItemCount(section),videoCount)
        
    }
    
    fileprivate func preferItemCount(_ section:Int) -> Int{
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular) where section == 0:
            return 6
        case (.compact, .regular):
            return 5
        case (.compact, .compact):
            return 3
        case (.regular, .compact):
            return 3
        case (.regular, .regular):
            if view.frame.width > 768.0 {
                return 4
            }
            return 3
        default:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell( indexPath,type:TopVideoCell.self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.channelList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(kind, indexPath: indexPath, type: TopVideoCollectionHeaderView.self)
            
            guard let channel = channel(indexPath.section) else {
                return headerView
            }
            
            headerView.titleLabel.text = channel.title
            
            headerView.thumbnailImageView.image = nil
            loadChannelImage(channel) {
                image in
                headerView.thumbnailImageView.image = image
            }
            
            headerView.moreButton.isHidden = !channel.selectable
            headerView.gestureRecognizers?.filter{$0 is UITapGestureRecognizer}.forEach{ headerView.removeGestureRecognizer($0) }
            
            if channel.selectable {
                headerView.moreButton.tag = indexPath.section
                headerView.moreButton.addTarget(self, action:#selector(TopViewController.moreButtonTapped(_:)), for: .touchUpInside)
                
                headerView.tag = indexPath.section
                headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TopViewController.headerViewTapped(_:))))
            }
            
            return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView( kind, indexPath: indexPath, type: TopVideoCollectionFooterView.self)
            
            footerView.isHidden = indexPath.section == collectionView.numberOfSections - 1
            
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
    
    @objc func headerViewTapped(_ gestureRecognizer: UITapGestureRecognizer){  
        guard let view = gestureRecognizer.view , let channel = channel(view.tag) else { return }
        
        channel.selectedAction?(self)
    }
    
    @objc func moreButtonTapped(_ button: UIButton){
        guard let channel = channel(button.tag) else { return }
        
        channel.selectedAction?(self)
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        guard let topItem = topItem(indexPath) else { return }
        topItem.selectedAction(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        guard let topItem = topItem(indexPath),let cell = cell as? TopVideoCell else { return }
        
        cell.titleLabel.text = topItem.title
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        
        if (indexPath.row == 0 && indexPath.section != 0) && (traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular) {
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let topItem = topItem(indexPath),let imageLoadingOperation = channelVideoImageLoadingOperationDictionary[topItem.id] else {
            return
        }
        imageLoadingOperation.cancel()
        channelVideoImageLoadingOperationDictionary.removeValue(forKey: topItem.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        let cellCount = cellCountPreLine(indexPath)
        
        let cellWidth = (collectionWidth - cellMargin * CGFloat(cellCount + 1)) / CGFloat(cellCount)
        let cellHeight = ((cellWidth - cellDefaultWidth) * cellImageHeightWidthRatio) + cellDefaultHeight
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    fileprivate func cellCountPreLine(_ indexPath: IndexPath) -> Int {
        let cellCount: Int
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, _ ):
            if view.frame.width > 768.0 {
                cellCount = 4
            } else {
                cellCount = 3
            }
        case (.compact, .regular) where indexPath.section > 0 && indexPath.row == 0:
            cellCount = 1
        case (.compact, .regular):
            cellCount = 2
        case (.compact, .compact):
            cellCount = 3
        default:
            cellCount = 3
        }
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellMargin, bottom: cellMargin, right: cellMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        return section == collectionView.numberOfSections - 1 ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 8)
    }
    
}

extension TopViewController: UIGestureRecognizerDelegate {
    
}

extension TopViewController {
    override func fetchNewData(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let backgroundFetchOperation = backgroundFetchOperation, backgroundFetchOperation.isFinished == false {
            completionHandler(.noData)
            return
        }
        
        backgroundFetchOperation = BlockOperation(block: {
            [weak self] in
            completionHandler(.newData)
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
                completionHandler(.failed)
            })
    }
}
