import Foundation
import UIKit
import AVFoundation
import XCDYouTubeKit

class VideoDetailViewController:UIViewController {
    
    /** related video width **/
    let compactPadWidth:CGFloat = 768
    let relatedVideosViewWidthRegularWidth:CGFloat = 320
    let relatedVideosViewWidthCompactWidth:CGFloat = 0
    
    enum SegueId:String {
        case videoDetailSegmentEmbed
        case relatedVideosEmbed
    }
    
    
    var videoId:String!
    var initialPlaybackTime:TimeInterval = 0
    
    @IBOutlet fileprivate var thumbnailImageView:UIImageView!
    @IBOutlet fileprivate weak var videoPlayerView:UIView!
    
    @IBOutlet fileprivate weak var relatedVideosViewWidthConstraint:NSLayoutConstraint!
    
    var viewModel:VideoDetailViewModel!
    
    var videoPlayerViewController:XCDYouTubeVideoPlayerViewController?
    
    var videoQualitySwitchButton:UIBarButtonItem!
    var shareButton:UIBarButtonItem!
    
    var currentVideoQuality:XCDYouTubeVideoQuality = .medium360
    
    var videoDetailSegmentViewController: VideoDetailSegmentViewController!
    var relatedVideosViewController: VideoRelatedVideosViewController!
    
    let imageLoadingOperationQueue:OperationQueue =  OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = VideoDetailViewModel(videoId: videoId)
        
        configureViews()
        addNotifications()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        overrideChildViewControllerTraitCollection(size:self.view.frame.size,transitionCoordinator:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        VideoService.sharedInstance.saveHistoryVideoId(videoId)
        
        if videoPlayerViewController == nil || videoPlayerViewController?.moviePlayer.isFullscreen == false {
            playVideo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoPlayerViewController = videoPlayerViewController, videoPlayerViewController.moviePlayer.isFullscreen == false {
            videoPlayerViewController.moviePlayer.pause()
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        
        if let videoPlayerViewController = videoPlayerViewController {
            VideoService.sharedInstance.updateLastPlaybackTimeWithVideoId(videoId,lastPlaybackTime:videoPlayerViewController.moviePlayer.currentPlaybackTime)
            videoPlayerViewController.moviePlayer.stop()
        }
        
        userActivity?.invalidate()
    }
    
    fileprivate func loadData(){
        let successBlock = {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            let imageOperation = ImageLoadOperation(url:strongSelf.viewModel.thumbnailImageUrl){
                image in
                strongSelf.thumbnailImageView.image = image
            }
            strongSelf.imageLoadingOperationQueue.addOperation(imageOperation)
            strongSelf.shareButton?.isEnabled = true
            strongSelf.videoDetailSegmentViewController.updateWithChannelId(strongSelf.viewModel.channelId! ,channelTitle:strongSelf.viewModel.channelTitle!)
        }
        
        let failureBlock: (NSError) -> Void = {
            [weak self]error in
            self?.showError(error)
        }
        
        viewModel.update(success:successBlock,failure:failureBlock)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let segueIdentifier = segue.identifier, let segueId = SegueId(rawValue:segueIdentifier) else {
            return
        }
        
        switch segueId {
        case .videoDetailSegmentEmbed:
            let videoDetailSegmentViewController = segue.destinationViewController(VideoDetailSegmentViewController.self)
            videoDetailSegmentViewController.videoId = videoId
            self.videoDetailSegmentViewController = videoDetailSegmentViewController
        case .relatedVideosEmbed:
            let relatedVideosViewController = segue.destinationViewController(VideoRelatedVideosViewController.self)
            relatedVideosViewController.videoId = videoId
            self.relatedVideosViewController = relatedVideosViewController
        }
    }
    
    fileprivate func startActivity() {
        let activity = NSUserActivity(activityType: kUserActivityTypeVideoDetail)
        
        let videoCurrentPlayTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0.0
        
        activity.userInfo = activityUserInfo(videoCurrentPlayTime)
        activity.webpageURL = viewModel.handoffUrl(videoCurrentPlayTime)
        userActivity = activity
        activity.becomeCurrent()
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)

        let videoCurrentPlayTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0.0
       
        activity.addUserInfoEntries(from: activityUserInfo(videoCurrentPlayTime))
        activity.webpageURL = viewModel.handoffUrl(videoCurrentPlayTime)
        activity.needsSave = true
    }
    
    fileprivate func activityUserInfo(_ videoCurrentPlayTime:TimeInterval) -> [AnyHashable: Any] {
        return [
            kUserActivityVideoDetailUserInfoKeyVideoId: videoId,
            kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime: videoCurrentPlayTime,
            kHandOffVersionKey:kHandOffVersion
        ]

    }
    
    fileprivate func configureViews() {
        let videoQualitySwitchButton =  UIBarButtonItem(title: Localization.VideoQualityMedium.localizedString , style: .plain, target: self, action: #selector(VideoDetailViewController.switchVideoQualityButtonTapped(_:)))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(VideoDetailViewController.shareButtonTapped(_:)))
        
        shareButton.isEnabled = false
        
        navigationItem.rightBarButtonItems = [shareButton, videoQualitySwitchButton]
        self.videoQualitySwitchButton = videoQualitySwitchButton
        self.shareButton = shareButton
    }
    
    fileprivate  func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(VideoDetailViewController.moviePreloadDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerLoadStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoDetailViewController.moviePlayBackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
    }
    
    func shareButtonTapped(_ sender:AnyObject) {
        var items:[AnyObject] = []
        
        if let shareTitle = viewModel.shareTitle {
            items.append(shareTitle as AnyObject)
        }
        
        if let image = thumbnailImageView.image {
            items.append(image)
        }
        
        if let shareUrl = viewModel.shareUrl {
            items.append(shareUrl as AnyObject)
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        activityController.completionWithItemsHandler = {
            [weak self](activityType, _, _ , _) in
            guard let strongSelf = self, let activityType = activityType else {
                return
            }
            EventTracker.trackViewDetailShare(activityType: activityType.rawValue, videoId: strongSelf.videoId)
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    func moviePlayBackDidFinish(_ moviePlayerPlaybackDidFinishNotification:AnyObject){
        videoPlayerViewController?.moviePlayer.currentPlaybackTime = 3.0
    }
    
    func moviePreloadDidFinish(_ moviePlayerLoadStateDidChangeNotification:AnyObject) {
        if videoPlayerViewController?.moviePlayer.loadState == .playable {
            VideoService.sharedInstance.savePlayFinishedVideoId(videoId)
            startActivity()
            
            //TODO: fun animation
            UIView.animate(withDuration: 0.25, animations: {
                self.thumbnailImageView.alpha = 0.0;
            })
        }
    }
    
    fileprivate func playVideo() {
        EventTracker.trackVideoDetailPlay(videoId)
        
        let initialPlaybackTime = self.initialPlaybackTime == 0.0 ? VideoService.sharedInstance.lastPlaybackTimeWithVideoId(videoId) : self.initialPlaybackTime
        
        playVideoWithInitialPlaybackTime(initialPlaybackTime,videoQualities:[.medium360, .small240])
        
        currentVideoQuality = .medium360
    }
    
    @IBAction fileprivate func switchVideoQualityButtonTapped(_ sender:AnyObject) {
        let videoQualityActionSheet = UIActionSheet()
        videoQualityActionSheet.delegate = self
        
        videoQualityActionSheet.title =  Localization.SwitchVideoQuality.localizedString
        videoQualityActionSheet.addButton(withTitle: Localization.VideoQualityHigh.localizedString)
        videoQualityActionSheet.addButton(withTitle: Localization.VideoQualityMedium.localizedString)
        videoQualityActionSheet.addButton(withTitle: Localization.VideoQualityLow.localizedString)
        videoQualityActionSheet.addButton(withTitle: Localization.Cancel.localizedString)
        
        videoQualityActionSheet.cancelButtonIndex = 3
        
        switch currentVideoQuality {
        case .HD720:
            videoQualityActionSheet.destructiveButtonIndex = 0
        case .medium360:
            videoQualityActionSheet.destructiveButtonIndex = 1
        case .small240:
            videoQualityActionSheet.destructiveButtonIndex = 2
        default:
            break
        }
        
        videoQualityActionSheet.show(in: view)
    }
    
    
    fileprivate func playVideoWithInitialPlaybackTime(_ initialPlaybackTime:TimeInterval,videoQualities:[XCDYouTubeVideoQuality]) {
        if let videoPlayerViewController = self.videoPlayerViewController {
            videoPlayerViewController.moviePlayer.stop()
            videoPlayerViewController.moviePlayer.view.removeFromSuperview()
        }
        
        let videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
        
        videoPlayerViewController.preferredVideoQualities = videoQualities.map{$0.rawValue}
        
        videoPlayerViewController.present(in: videoPlayerView)
        videoPlayerViewController.moviePlayer.initialPlaybackTime = initialPlaybackTime
        videoPlayerViewController.moviePlayer.prepareToPlay()
        
        self.videoPlayerViewController = videoPlayerViewController
    }
    
    fileprivate func overrideChildViewControllerTraitCollection(size:CGSize, transitionCoordinator:UIViewControllerTransitionCoordinator?){
        guard traitCollection.userInterfaceIdiom == .pad else {
            return
        }
        let childTraitCollection = UITraitCollection(horizontalSizeClass: size.width <= compactPadWidth ? .compact : .regular)
        setOverrideTraitCollection(childTraitCollection, forChildViewController: relatedVideosViewController)
        setOverrideTraitCollection(childTraitCollection, forChildViewController: videoDetailSegmentViewController)
        
        if let transitionCoordinator = transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {
                _ in
                self.resizeRelatedVideosView(childTraitCollection)
                },completion:{
                    _ in
                    self.relatedVideosViewController.collectionView.collectionViewLayout.invalidateLayout()
            })
        }else {
            resizeRelatedVideosView(childTraitCollection)
        }
    }
    
    fileprivate func resizeRelatedVideosView(_ traitCollection:UITraitCollection) {
        relatedVideosViewWidthConstraint.constant = traitCollection.horizontalSizeClass == .regular ? relatedVideosViewWidthRegularWidth : relatedVideosViewWidthCompactWidth
        view.layoutIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        overrideChildViewControllerTraitCollection(size:size,transitionCoordinator:coordinator)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        
        if traitCollection.horizontalSizeClass != .regular {
            videoPlayerViewController?.moviePlayer.setFullscreen(toInterfaceOrientation == .landscapeLeft || toInterfaceOrientation == .landscapeRight, animated: true)
        }
    }
}

extension VideoDetailViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int){
        let initialPlaybackTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0
        switch buttonIndex {
        case 0:
            guard currentVideoQuality != .HD720 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities: [.HD720, .medium360, .small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityHigh", comment: "")
            currentVideoQuality = .HD720
        case 1:
            guard currentVideoQuality != .medium360 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities:[.medium360, .small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityMedium", comment: "")
            currentVideoQuality = .medium360
            
        case 2:
            guard currentVideoQuality != .small240 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities:[.small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityLow", comment: "")
            currentVideoQuality = .small240
        default:
            return
        }
    }
    
    
}
