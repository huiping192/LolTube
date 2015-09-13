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
    var initialPlaybackTime:NSTimeInterval = 0
    
    @IBOutlet private var thumbnailImageView:UIImageView!
    @IBOutlet private weak var videoPlayerView:UIView!
    
    @IBOutlet private weak var relatedVideosViewWidthConstraint:NSLayoutConstraint!
    
    var viewModel:VideoDetailViewModel!
    
    var videoPlayerViewController:XCDYouTubeVideoPlayerViewController?
    
    var videoQualitySwitchButton:UIBarButtonItem!
    var shareButton:UIBarButtonItem!
    
    var currentVideoQuality:XCDYouTubeVideoQuality = .Medium360
    
    var videoDetailSegmentViewController:RSVideoDetailSegmentViewController!
    var relatedVideosViewController:RSVideoRelatedVideosViewController!
    
    let imageLoadingOperationQueue:NSOperationQueue =  NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = VideoDetailViewModel(videoId: videoId)
        
        configureViews()
        addNotifications()
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        overrideChildViewControllerTraitCollection(size:self.view.frame.size,transitionCoordinator:nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        RSVideoService.sharedInstance().saveHistoryVideoId(videoId)
        
        if videoPlayerViewController == nil || videoPlayerViewController?.moviePlayer.fullscreen == false {
            playVideo()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoPlayerViewController = videoPlayerViewController where videoPlayerViewController.moviePlayer.fullscreen == false {
            videoPlayerViewController.moviePlayer.pause()
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if let videoPlayerViewController = videoPlayerViewController {
            RSVideoService.sharedInstance().updateLastPlaybackTimeWithVideoId(videoId,lastPlaybackTime:videoPlayerViewController.moviePlayer.currentPlaybackTime)
            videoPlayerViewController.moviePlayer.stop()
        }
        
        userActivity?.invalidate()
    }
    
    private func loadData(){
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
            strongSelf.shareButton?.enabled = true
            strongSelf.videoDetailSegmentViewController.updateWithChannelId(strongSelf.viewModel.channelId ,channelTitle:strongSelf.viewModel.channelTitle)
        }
        
        let failureBlock: NSError -> Void = {
            [weak self]error in
            self?.showError(error)
        }
        
        viewModel.update(success:successBlock,failure:failureBlock)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let segueIdentifier = segue.identifier, segueId = SegueId(rawValue:segueIdentifier) else {
            return
        }
        
        switch segueId {
        case .videoDetailSegmentEmbed:
            let videoDetailSegmentViewController = segue.destinationViewController(RSVideoDetailSegmentViewController.self)
            videoDetailSegmentViewController.videoId = videoId
            self.videoDetailSegmentViewController = videoDetailSegmentViewController
        case .relatedVideosEmbed:
            let relatedVideosViewController = segue.destinationViewController(RSVideoRelatedVideosViewController.self)
            relatedVideosViewController.videoId = videoId
            self.relatedVideosViewController = relatedVideosViewController
        }
    }
    
    private func startActivity() {
        let activity = NSUserActivity(activityType: kUserActivityTypeVideoDetail)
        
        let videoCurrentPlayTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0.0
        
        activity.userInfo = activityUserInfo(videoCurrentPlayTime)
        activity.webpageURL = viewModel.handoffUrl(videoCurrentPlayTime)
        userActivity = activity
        activity.becomeCurrent()
    }
    
    override func updateUserActivityState(activity: NSUserActivity) {
        super.updateUserActivityState(activity)

        let videoCurrentPlayTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0.0
       
        activity.addUserInfoEntriesFromDictionary(activityUserInfo(videoCurrentPlayTime))
        activity.webpageURL = viewModel.handoffUrl(videoCurrentPlayTime)
        activity.needsSave = true
    }
    
    private func activityUserInfo(videoCurrentPlayTime:NSTimeInterval) -> [NSObject:AnyObject] {
        return [
            kUserActivityVideoDetailUserInfoKeyVideoId: videoId,
            kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime: videoCurrentPlayTime,
            kHandOffVersionKey:kHandOffVersion
        ]

    }
    
    private func configureViews() {
        let videoQualitySwitchButton =  UIBarButtonItem(title: Localization.VideoQualityMedium.localizedString , style: .Plain, target: self, action: "switchVideoQualityButtonTapped:")
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareButtonTapped:")
        
        shareButton.enabled = false
        
        navigationItem.rightBarButtonItems = [shareButton, videoQualitySwitchButton]
        self.videoQualitySwitchButton = videoQualitySwitchButton
        self.shareButton = shareButton
    }
    
    private  func addNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePreloadDidFinish:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
    }
    
    func shareButtonTapped(sender:AnyObject) {
        var items:[AnyObject] = []
        
        if let shareTitle = viewModel.shareTitle {
            items.append(shareTitle)
        }
        
        if let image = thumbnailImageView.image {
            items.append(image)
        }
        
        if let shareUrl = viewModel.shareUrl {
            items.append(shareUrl)
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        activityController.completionWithItemsHandler = {
            [weak self](activityType, _, _ , _) in
            guard let strongSelf = self, activityType = activityType else {
                return
            }
            EventTracker.trackViewDetailShare(activityType: activityType, videoId: strongSelf.videoId)
        }
        
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func moviePlayBackDidFinish(moviePlayerPlaybackDidFinishNotification:AnyObject){
        videoPlayerViewController?.moviePlayer.currentPlaybackTime = 3.0
    }
    
    func moviePreloadDidFinish(moviePlayerLoadStateDidChangeNotification:AnyObject) {
        if videoPlayerViewController?.moviePlayer.loadState == .Playable {
            RSVideoService.sharedInstance().savePlayFinishedVideoId(videoId)
            startActivity()
            
            //TODO: fun animation
            UIView.animateWithDuration(0.25){
                self.thumbnailImageView.alpha = 0.0;
            }
        }
    }
    
    private func playVideo() {
        EventTracker.trackVideoDetailPlay(videoId)
        
        let initialPlaybackTime = self.initialPlaybackTime == 0.0 ? RSVideoService.sharedInstance().lastPlaybackTimeWithVideoId(videoId) : self.initialPlaybackTime
        
        playVideoWithInitialPlaybackTime(initialPlaybackTime,videoQualities:[.Medium360, .Small240])
        
        currentVideoQuality = .Medium360
    }
    
    @IBAction private func switchVideoQualityButtonTapped(sender:AnyObject) {
        let videoQualityActionSheet = UIActionSheet()
        videoQualityActionSheet.delegate = self
        
        videoQualityActionSheet.title =  Localization.SwitchVideoQuality.localizedString
        videoQualityActionSheet.addButtonWithTitle(Localization.VideoQualityHigh.localizedString)
        videoQualityActionSheet.addButtonWithTitle(Localization.VideoQualityMedium.localizedString)
        videoQualityActionSheet.addButtonWithTitle(Localization.VideoQualityLow.localizedString)
        videoQualityActionSheet.addButtonWithTitle(Localization.Cancel.localizedString)
        
        videoQualityActionSheet.cancelButtonIndex = 3
        
        switch currentVideoQuality {
        case .HD720:
            videoQualityActionSheet.destructiveButtonIndex = 0
        case .Medium360:
            videoQualityActionSheet.destructiveButtonIndex = 1
        case .Small240:
            videoQualityActionSheet.destructiveButtonIndex = 2
        default:
            break
        }
        
        videoQualityActionSheet.showInView(view)
    }
    
    
    private func playVideoWithInitialPlaybackTime(initialPlaybackTime:NSTimeInterval,videoQualities:[XCDYouTubeVideoQuality]) {
        if let videoPlayerViewController = self.videoPlayerViewController {
            videoPlayerViewController.moviePlayer.stop()
            videoPlayerViewController.moviePlayer.view.removeFromSuperview()
        }
        
        let videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
        
        videoPlayerViewController.preferredVideoQualities = videoQualities.map{$0.rawValue}
        
        videoPlayerViewController.presentInView(videoPlayerView)
        videoPlayerViewController.moviePlayer.initialPlaybackTime = initialPlaybackTime
        videoPlayerViewController.moviePlayer.prepareToPlay()
        
        self.videoPlayerViewController = videoPlayerViewController
    }
    
    private func overrideChildViewControllerTraitCollection(size size:CGSize, transitionCoordinator:UIViewControllerTransitionCoordinator?){
        guard traitCollection.userInterfaceIdiom == .Pad else {
            return
        }
        let childTraitCollection = UITraitCollection(horizontalSizeClass: size.width <= compactPadWidth ? .Compact : .Regular)
        setOverrideTraitCollection(childTraitCollection, forChildViewController: relatedVideosViewController)
        setOverrideTraitCollection(childTraitCollection, forChildViewController: videoDetailSegmentViewController)
        
        if let transitionCoordinator = transitionCoordinator {
            transitionCoordinator.animateAlongsideTransition({
                _ in
                self.resizeRelatedVideosView(childTraitCollection)
                },completion:nil)
        }else {
            resizeRelatedVideosView(childTraitCollection)
        }
    }
    
    private func resizeRelatedVideosView(traitCollection:UITraitCollection) {
        relatedVideosViewWidthConstraint.constant = traitCollection.horizontalSizeClass == .Regular ? relatedVideosViewWidthRegularWidth : relatedVideosViewWidthCompactWidth
        view.layoutIfNeeded()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        overrideChildViewControllerTraitCollection(size:size,transitionCoordinator:coordinator)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        if traitCollection.horizontalSizeClass != .Regular {
            videoPlayerViewController?.moviePlayer.setFullscreen(toInterfaceOrientation == .LandscapeLeft || toInterfaceOrientation == .LandscapeRight, animated: true)
        }
    }
}

extension VideoDetailViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        let initialPlaybackTime = videoPlayerViewController?.moviePlayer.currentPlaybackTime ?? 0
        switch buttonIndex {
        case 0:
            guard currentVideoQuality != .HD720 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities: [.HD720, .Medium360, .Small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityHigh", comment: "")
            currentVideoQuality = .HD720
        case 1:
            guard currentVideoQuality != .Medium360 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities:[.Medium360, .Small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityMedium", comment: "")
            currentVideoQuality = .Medium360
            
        case 2:
            guard currentVideoQuality != .Small240 else {
                return
            }
            playVideoWithInitialPlaybackTime(initialPlaybackTime , videoQualities:[.Small240])
            videoQualitySwitchButton.title = NSLocalizedString("VideoQualityLow", comment: "")
            currentVideoQuality = .Small240
        default:
            return
        }
    }
    
    
}