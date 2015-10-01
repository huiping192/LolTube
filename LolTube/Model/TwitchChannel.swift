//
//  TwitchChannel.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

struct TwitchChannel: Channel {
    var id: String{
        return "Twitch"
    }
    let title: String? = "Twitch"
    
    let thumbnailUrl: String? = "Twitch"
    let thumbnailType:ThumbnailType = .Local
    
    var selectedAction:(sourceViewController:UIViewController) -> Void {
        return { sourceViewController in
            sourceViewController.showViewController(sourceViewController.instantiateTwitchStreamListViewController(), sender: sourceViewController)
        }
    }
}
