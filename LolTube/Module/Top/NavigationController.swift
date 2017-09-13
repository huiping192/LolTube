//
//  RSNavigationController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation


class NavigationControllerSwift: UINavigationController {
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)

        guard let userInfo = activity.userInfo, let handOffVersion = userInfo[kHandOffVersionKey as NSObject] as? String, let videoId = userInfo[kUserActivityVideoDetailUserInfoKeyVideoId ], let initialPlaybackTime = userInfo[kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime], activity.activityType ==  kUserActivityTypeVideoDetail && handOffVersion == kHandOffVersion else {
            
            return
        }
        
        let videoDetailViewController: VideoDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kViewControllerIdVideoDetail) as! VideoDetailViewController
        videoDetailViewController.videoId = videoId as! String
        
        videoDetailViewController.initialPlaybackTime = TimeInterval((Int(initialPlaybackTime as! NSNumber)))
        self.pushViewController(videoDetailViewController, animated: true) 

    }
}
