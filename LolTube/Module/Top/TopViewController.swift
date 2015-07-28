import Foundation
import UIKit

class TopViewController: UIViewController {

    private enum SegueIdentifier:String {
        case videoDetail = "videoDetail"
        case topImageToVideoDetail = "topImageToVideoDetail"
    }
    
    private let cellDefaultWidth = CGFloat(145.0)
    private let cellDefaultHeight = CGFloat(140.0)
    private let cellImageHeightWidthRatio = CGFloat(9.0 / 16.0)
    private let cellMargin = CGFloat(8)

    // MARK: top view
    @IBOutlet private var topImageView01: UIImageView!
    @IBOutlet private var topImageView02: UIImageView!
    @IBOutlet private var topImageView03: UIImageView!
    @IBOutlet private var topImageView04: UIImageView!

    @IBOutlet private var topImageTitleLabel: UILabel?
    @IBOutlet private var topImagePageControl: UIPageControl?

    @IBOutlet private var topImageTitleLabel01: UILabel?
    @IBOutlet private var topImageTitleLabel02: UILabel?
    @IBOutlet private var topImageTitleLabel03: UILabel?
    @IBOutlet private var topImageTitleLabel04: UILabel?

    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var topImageScrollView: UIScrollView!
    @IBOutlet private var videosCollectionView: UICollectionView!

    @IBOutlet private var collectionHeightConstraint: NSLayoutConstraint!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        return refreshControl
    }()


    private let viewModel = TopViewModel()
    private let imageLoadingOperationQueue = NSOperationQueue()
    private var imageLoadingOperationDictionary = [String: NSOperation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        loadVideosData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        videosCollectionView.collectionViewLayout.invalidateLayout()
        layoutCollectionViewSize()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

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
            
        case .topImageToVideoDetail:
            guard let video = viewModel.topVideoList?[currentTopImageNumber()] else {
               return
            }
            let videoDetailViewController = segue.destinationViewController(RSVideoDetailViewController.self)
            topImagePageControl?.currentPage = currentTopImageNumber()
            videoDetailViewController.videoId = video.videoId
        }
    }
    
    

    // MARK: data loading
    private func loadVideosData() {
        mainScrollView.alpha = 0.0
        animateLoadingView()

        let successBlock:(() -> Void) = {
            [unowned self] in
            self.configureTopView()
            self.videosCollectionView.reloadData()
            self.layoutCollectionViewSize()
            
            self.stopAnimateLoadingView()
            
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.25) {
                    [unowned self] in
                    self.mainScrollView.alpha = 1.0
                }
            }
        }
        
        let failureBlock:((NSError) -> Void) = {
            [unowned self]error in
            self.showError(error)
            self.stopAnimateLoadingView()
        }
        
        viewModel.update(successBlock, failure: failureBlock)
    }

    func refresh(refreshControl: UIRefreshControl) {
        viewModel.update({
            [unowned self] in
            self.configureTopView()
            self.videosCollectionView.reloadData()
            self.layoutCollectionViewSize()
            refreshControl.endRefreshing()
        }, failure: {
            [unowned self]error in
            self.showError(error)
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
        dispatch_async(dispatch_get_main_queue(), {
            [unowned self] in
            self.collectionHeightConstraint.constant = self.videosCollectionView.contentSize.height
            self.videosCollectionView.layoutIfNeeded()
        })
    }

    private func configureView() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        topImageScrollView.scrollsToTop = false
        videosCollectionView.scrollsToTop = false

        mainScrollView.addSubview(refreshControl)
    }

    private func configureTopView() {
        guard let topVideoList = viewModel.topVideoList else {
            return
        }
        for (index, video) in topVideoList.enumerate() {
            loadVideoImage(video.videoId, imageUrlString: video.highThumbnailUrl, secondImageUrlString: video.thumbnailUrl) {
                image in
                switch index {
                case 0:
                    self.topImageView01.image = image
                    self.topImageTitleLabel01?.text = video.title
                    self.topImageTitleLabel?.text = video.title
                case 1:
                    self.topImageView02.image = image
                    self.topImageTitleLabel02?.text = video.title
                case 2:
                    self.topImageView03.image = image
                    self.topImageTitleLabel03?.text = video.title
                case 3:
                    self.topImageView04.image = image
                    self.topImageTitleLabel04?.text = video.title
                default:
                    break
                }
            }
        }
    }

    private func currentTopImageNumber() -> Int {
        return Int(topImageScrollView.contentOffset.x / topImageScrollView.frame.size.width)
    }

    // MARK: image loading
    private func loadVideoImage(videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        guard imageUrlString != nil || secondImageUrlString != nil else {
            return
        }

        let imageLoadingOperation = UIImageView.asynLoadingImageWithUrlString(imageUrlString, secondImageUrlString: secondImageUrlString, needBlackWhiteEffect: false) {
            image in
            success(image)
        }

        imageLoadingOperationQueue.addOperation(imageLoadingOperation)
        imageLoadingOperationDictionary[videoId] = imageLoadingOperation
    }

    private func loadChannelImage(channelId: NSString, imageUrlString: String?, success: (UIImage) -> Void) {
        guard imageUrlString != nil else {
            return
        }

        let imageLoadingOperation = UIImageView.asynLoadingImageWithUrlString(imageUrlString, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            image in
            success(image)
        }

        imageLoadingOperationQueue.addOperation(imageLoadingOperation)
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
            return min(videoCount,4)
        case (.Regular, .Regular):
            return min(videoCount,4)
        default:
           return videoCount
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath,type:TopVideoCell.self)
        guard let video = video(indexPath) else {
            return cell
        }
        
        cell.titleLabel.text = video.title
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text =  video.viewCountPublishedAt
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        if (indexPath.row == 0 && indexPath.section != 0) {
            firstImageUrlString = video.highThumbnailUrl ?? video.thumbnailUrl
            secondImageUrlString = video.thumbnailUrl
        } else {
            firstImageUrlString = video.thumbnailUrl
            secondImageUrlString = nil
        }
        
        loadVideoImage(video.videoId, imageUrlString: firstImageUrlString, secondImageUrlString: secondImageUrlString) {
            [weak collectionView] image in
            let cell = collectionView?.cell(indexPath, type: TopVideoCell.self)
            cell?.thunmbnailImageView.image = image
        }

        return cell
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
        
        navigationController?.pushViewController(instantiateChannelDetailViewController(channel.channelId), animated: true)
    }
    
    func moreButtonTapped(button: UIButton){
        guard let channel = channel(button.tag) else {
            return
        }
        
        navigationController?.pushViewController(instantiateChannelDetailViewController(channel.channelId), animated: true)
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let video = video(indexPath),imageLoadingOperation = imageLoadingOperationDictionary[video.videoId] else {
            return
        }
        imageLoadingOperation.cancel()
        imageLoadingOperationDictionary.removeValueForKey(video.videoId)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        let cellCount: Int

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Regular, _ ):
            cellCount = 4
        case (.Compact, .Regular) where indexPath.section > 0 && indexPath.row == 0:
            cellCount = 1
        case (.Compact, .Regular):
            cellCount = 2
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

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let video = viewModel.topVideoList?[currentTopImageNumber()] where scrollView == topImageScrollView else {
            return
        }
        topImagePageControl?.currentPage = currentTopImageNumber()
        topImageTitleLabel?.text = video.title
    }
}

extension TopViewController: UIGestureRecognizerDelegate {

}
