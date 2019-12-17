//
//  RSVideoInfoViewController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import Async

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
        NotificationCenter.default.addObserver(self, selector: #selector(self.preferredContentSizeChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
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
            UIView.animate(withDuration: 0.25, animations: {
                weakSelf.view.alpha = 1.0
            })
            }, failure: {[weak self]error in
                self?.showError(error)
                self?.stopLoadingAnimation()
            })
        self.viewModel.updateVideoDetailWithSuccess({[weak self] in
            self?.rateLabel.text = self?.viewModel.rate
            self?.viewCountLabel.text = self?.viewModel.viewCount
            }, failure: {_ in })
    }
    
    @objc func preferredContentSizeChanged(_ notification: Notification) {
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        self.postedAtLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        self.rateLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        self.viewCountLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        self.descriptionTextView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
    }
}
