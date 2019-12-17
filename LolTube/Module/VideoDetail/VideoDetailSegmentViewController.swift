//
//  RSVideoDetailSegmentViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation


class VideoDetailSegmentViewController: UIViewController {
    
    var videoId: String!

    @IBOutlet weak var videoSegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedContainerView: UIView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelRegisterButton: UIButton!
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var channelThumbnailImageView: UIImageView!
    
    var infoViewController: VideoInfoViewController?
    var relatedVideosViewController: VideoRelatedVideosViewController?
    
    var viewModel: VideoDetailSegmentViewModel!
    
    let imageLoadingOperationQueue: OperationQueue = OperationQueue()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.p_configureViews()
    }
    
    func updateWithChannelId(_ channelId: String, channelTitle: String) {
        self.channelTitleLabel.text = channelTitle
        self.viewModel = VideoDetailSegmentViewModel(channelId: channelId)
        self.viewModel.updateWithSuccess({[weak self]() -> Void in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.subscriberCountLabel.text = weakSelf.viewModel.subscriberCount
            let imageOperation: Operation = UIImageView.asynLoadingImage(withUrlString: weakSelf.viewModel.channelThumbnailImageUrl, secondImageUrlString: nil, needBlackWhiteEffect: false, success: {(image: UIImage!) -> Void in
                weakSelf.channelThumbnailImageView.image = image
            })
            weakSelf.imageLoadingOperationQueue.addOperation(imageOperation)
            let title: String = weakSelf.viewModel.isSubscribed ? NSLocalizedString("ChannelSubscribed",comment: "") : NSLocalizedString("ChannelUnsubscribe", comment: "")
            weakSelf.channelRegisterButton.setTitle(title, for: UIControl.State())
            let buttonColor: UIColor = weakSelf.viewModel.isSubscribed ? UIColor.lightGray : weakSelf.view.tintColor
            weakSelf.channelRegisterButton.setTitleColor(buttonColor, for: UIControl.State())
            }, failure: {[weak self](error: NSError) -> Void in
                self?.showError(error)
        })
    }
    
    @IBAction func channelRegisterButtonTapped(_ button: UIButton) {
        self.viewModel.subscribeChannelWithSuccess({[weak self]() -> Void in
            guard let weakSelf = self else {
                return
            }
            
            let title: String = weakSelf.viewModel.isSubscribed ? NSLocalizedString("ChannelSubscribed",comment: "") : NSLocalizedString("ChannelUnsubscribe",comment: "")
            weakSelf.channelRegisterButton.setTitle(title, for: UIControl.State())
            let buttonColor: UIColor = weakSelf.viewModel.isSubscribed ? UIColor.lightGray : weakSelf.view.tintColor
            weakSelf.channelRegisterButton.setTitleColor(buttonColor, for: UIControl.State())
            }, failure: {[weak self](error: NSError) -> Void in
                self?.showError(error)
        })
    }
    
    @IBAction func channelViewTapped(_ recognizer: UIGestureRecognizer) {
        let channelDetailStoryboard: UIStoryboard = UIStoryboard(name: "ChannelDetail", bundle: nil)
        let channelDetailViewController: ChannelDetailViewController = channelDetailStoryboard.instantiateInitialViewController() as! ChannelDetailViewController
        channelDetailViewController.channelId = self.viewModel.channelId
        channelDetailViewController.channelTitle = self.channelTitleLabel.text!
        self.navigationController?.pushViewController(channelDetailViewController, animated: true)
    }
    
    func p_configureViews() {
        self.channelThumbnailImageView.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        
        self.videoSegmentedControl.setTitle(NSLocalizedString("VideoDetailInfo",comment: "Info"), forSegmentAt: 0)
        self.videoSegmentedControl.setTitle(NSLocalizedString("VideoDietalSuggestions",comment: "Suggestions"), forSegmentAt: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "infoEmbed") {
            let infoViewController: VideoInfoViewController = segue.destination as! VideoInfoViewController
            infoViewController.videoId = self.videoId
            self.infoViewController = infoViewController
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let currentTraitCollection: UITraitCollection = self.traitCollection
        if currentTraitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass:.regular)) {
            if self.videoSegmentedControl.selectedSegmentIndex == 1 {
                self.videoSegmentedControl.selectedSegmentIndex = 0
                self.swapFromViewController(self.relatedVideosViewController, toViewController: self.infoViewController)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.infoViewController = nil
        self.relatedVideosViewController = nil
    }
    
    @IBAction func videoDetailSegmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if self.infoViewController == nil {
                self.infoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoInfo") as? VideoInfoViewController
                self.infoViewController?.videoId = self.videoId
            }
            self.swapFromViewController(self.relatedVideosViewController, toViewController: self.infoViewController)
            
        case 1:
            if self.relatedVideosViewController == nil {
                self.relatedVideosViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "relatedVideos") as? VideoRelatedVideosViewController
                self.relatedVideosViewController?.videoId = self.videoId 
            }
            self.swapFromViewController(self.infoViewController, toViewController: self.relatedVideosViewController)
        default:
            break
        }
        
    }
    
    func swapFromViewController(_ fromViewController: UIViewController?, toViewController: UIViewController?) {
        guard let fromViewController = fromViewController, let toViewController = toViewController else {
            return
        }
        
        fromViewController.willMove(toParent: nil)
        self.addChild(toViewController)
        fromViewController.view!.removeFromSuperview()
        self.addConstraintsForViewController(toViewController)
        fromViewController.removeFromParent()
        toViewController.didMove(toParent: self)
    }
    
    func addConstraintsForViewController(_ viewController: UIViewController) {
        let containerView: UIView = self.segmentedContainerView
        let childView: UIView = viewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(childView)
        
        let views = ["childView": childView]

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|", options: [], metrics: nil, views: views))
    }
}
