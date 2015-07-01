//
// Created by 郭 輝平 on 3/7/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit

class TopViewController: UIViewController {

    private let cellDefaultWidth = CGFloat(145.0);
    private let cellDefaultHeight = CGFloat(125.0);
    private let cellImageHeightWidthRatio = CGFloat(9.0 / 16.0);
    private let cellMargin = CGFloat(8);

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


    private let viewModel: TopViewModel = TopViewModel()
    private let imageLoadingOperationQueue: NSOperationQueue = NSOperationQueue()
    private var imageLoadingOperationDictionary: [String:NSOperation] = [String: NSOperation]()

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

        if let segueId = segue.identifier {
            switch segueId {
            case "videoDetail":
                var videoDetailViewController = segue.destinationViewController as! RSVideoDetailViewController;
                let collectionViewCell = sender as! UICollectionViewCell

                if let indexPath = videosCollectionView.indexPathForCell(collectionViewCell) {
                    if let video = video(indexPath) {
                        videoDetailViewController.videoId = video.videoId
                    }
                }
            case "topImageToVideoDetail":
                var videoDetailViewController = segue.destinationViewController as! RSVideoDetailViewController;
                topImagePageControl?.currentPage = currentTopImageNumber()

                if let video = viewModel.topVideoList?[currentTopImageNumber()] {
                    videoDetailViewController.videoId = video.videoId
                }
            default:
                return
            }
        }
    }

// MARK: data loading
    private func loadVideosData() {
        mainScrollView.alpha = 0.0
        animateLoadingView()

        viewModel.update({
            [unowned self] in
            self.configureTopView()
            self.videosCollectionView.reloadData()
            self.layoutCollectionViewSize()

            self.stopAnimateLoadingView();
            UIView.animateWithDuration(0.25) {
                [unowned self] in
                self.mainScrollView.alpha = 1.0
            }

        }, failure: {
            (error: NSError) in
            self.showError(error)
        })
    }

    func refresh(refreshControl: UIRefreshControl) {
        viewModel.update({
            [unowned self] in

            self.configureTopView()
            self.videosCollectionView.reloadData()
            refreshControl.endRefreshing()
        }, failure: {
            (error: NSError) in
            self.showError(error)
            refreshControl.endRefreshing()
        })
    }

    private func video(indexPath: NSIndexPath) -> Video? {
        if let channel = channel(indexPath.section) {
            return viewModel.videoDictionary?[channel]?[indexPath.row]
        }
        return nil
    }

    private func channel(section: Int) -> Channel? {
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
        navigationController!.interactivePopGestureRecognizer.delegate = self
        topImageScrollView.scrollsToTop = false
        videosCollectionView.scrollsToTop = false

        mainScrollView.addSubview(refreshControl)
    }

    private func configureTopView() {
        if let topVideoList = viewModel.topVideoList {
            for (index, video: Video) in enumerate(topVideoList) {
                loadVideoImage(video.videoId, imageUrlString: video.highThumbnailUrl!, secondImageUrlString: video.thumbnailUrl!) {
                    (image: UIImage!) in
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
    }

    private func currentTopImageNumber() -> Int {
        return Int(topImageScrollView.contentOffset.x / topImageScrollView.frame.size.width)
    }

// MARK: image loading
    private func loadVideoImage(videoId: String, imageUrlString: String?, secondImageUrlString: String?, success: (UIImage) -> Void) {
        if imageUrlString == nil && secondImageUrlString == nil {
            return
        }

        let imageLoadingOperation = UIImageView.asynLoadingImageWithUrlString(imageUrlString, secondImageUrlString: secondImageUrlString, needBlackWhiteEffect: false) {
            (image: UIImage!) in
            success(image)
        }

        imageLoadingOperationQueue.addOperation(imageLoadingOperation)
        imageLoadingOperationDictionary[videoId] = imageLoadingOperation
    }

    private func loadChannelImage(channelId: NSString, imageUrlString: String?, success: (UIImage) -> Void) {
        if imageUrlString == nil {
            return
        }

        let imageLoadingOperation = UIImageView.asynLoadingImageWithUrlString(imageUrlString, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            (image: UIImage!) in
            success(image)
        }

        imageLoadingOperationQueue.addOperation(imageLoadingOperation)
    }

}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular) where section == 0:
            return 4
        case (.Compact, .Compact):
            return 3
        case (.Regular, .Compact):
            return 4
        case (.Regular, .Regular):
            return 4
        default:
            if let channel = viewModel.channelList?[section] {
                if let videoList = viewModel.videoDictionary?[channel] {
                    return videoList.count
                }
            }
        }

        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! TopVideoCell

        if let video = video(indexPath) {
            cell.titleLabel.text = video.title
            cell.durationLabel.text = video.duration
            cell.viewCountLabel.text = video.viewCountString

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
                (image: UIImage!) in
                UIView.transitionWithView(cell.thunmbnailImageView, duration: 0.25, options: .TransitionCrossDissolve, animations: {
                    cell.thunmbnailImageView.image = image
                }, completion: nil)
            }
        }

        return cell
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.channelList?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath) as! TopVideoCollectionHeaderView
            if let channel = channel(indexPath.section) {
                headerView.titleLabel.text = channel.title
                loadChannelImage(channel.channelId, imageUrlString: channel.thumbnailUrl) {
                    (image: UIImage!) in
                    headerView.thumbnailImageView.image = image;
                }
            }
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "footerView", forIndexPath: indexPath) as! UICollectionReusableView
            footerView.hidden = indexPath.section == collectionView.numberOfSections() - 1

            return footerView
        default:
            let collectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "footerView", forIndexPath: indexPath) as! UICollectionReusableView
            collectionReusableView.hidden = true
            return collectionReusableView
        }

    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let video = video(indexPath) {
            if let imageLoadingOperation = imageLoadingOperationDictionary[video.videoId] {
                imageLoadingOperation.cancel()
                imageLoadingOperationDictionary.removeValueForKey(video.videoId)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        var cellCount: Int;

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
        return UIEdgeInsets(top: 0, left: cellMargin, bottom: cellMargin, right: cellMargin);
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == topImageScrollView) {
            if let video = viewModel.topVideoList?[currentTopImageNumber()] {
                topImagePageControl?.currentPage = currentTopImageNumber();
                topImageTitleLabel?.text = video.title
            }
        }
    }
}

extension TopViewController: UIGestureRecognizerDelegate {

}
