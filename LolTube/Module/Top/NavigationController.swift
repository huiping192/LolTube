//
//  RSNavigationController.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation


class NavigationControllerSwift: UINavigationController {
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        super.restoreUserActivityState(activity)

        guard let userInfo = activity.userInfo, handOffVersion = userInfo[kHandOffVersionKey as NSObject] as? String, videoId = userInfo[kUserActivityVideoDetailUserInfoKeyVideoId ], initialPlaybackTime = userInfo[kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime] where activity.activityType ==  kUserActivityTypeVideoDetail && handOffVersion == kHandOffVersion else {
            
            return
        }
        
        let videoDetailViewController: VideoDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(kViewControllerIdVideoDetail) as! VideoDetailViewController
        videoDetailViewController.videoId = videoId as! String
        
        videoDetailViewController.initialPlaybackTime = NSTimeInterval((Int(initialPlaybackTime as! NSNumber)))
        self.pushViewController(videoDetailViewController, animated: true) 

    }
}
