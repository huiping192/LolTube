//
//  RSVideoInfoViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import AsyncSwift

class VideoInfoViewController: UIViewController {
    
    var videoId: String!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postedAtLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var viewModel: VideoInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.preferredContentSizeChanged), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        self.p_loadData()
    }
    
    func p_loadData() {
        self.viewModel = VideoInfoViewModel(videoId: self.videoId)
        self.startLoadingAnimation()
        
        self.viewModel.updateWithSuccess({[weak self]() -> Void in
            guard let weakSelf = self else {
                return
            }
            weakSelf.view.alpha = 0.0
            weakSelf.stopLoadingAnimation()
            weakSelf.titleLabel.text = weakSelf.viewModel.title
            weakSelf.postedAtLabel.text = weakSelf.viewModel.postedTime
            weakSelf.descriptionTextView.text = weakSelf.viewModel.videoDescription
            UIView.animateWithDuration(0.25){
                weakSelf.view.alpha = 1.0
            }
            }, failure: {[weak self]error in
                self?.showError(error)
                self?.stopLoadingAnimation()
            })
        self.viewModel.updateVideoDetailWithSuccess({[weak self] in
            self?.rateLabel.text = self?.viewModel.rate
            self?.viewCountLabel.text = self?.viewModel.viewCount
            }, failure: {_ in })
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        self.postedAtLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        self.rateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        self.viewCountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        self.descriptionTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    }
}