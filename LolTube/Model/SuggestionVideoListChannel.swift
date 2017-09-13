//
//  RelatedVideoChannel.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/8/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

struct SuggestionVideoListChannel: Channel {
    var id: String{
        return "RelatedVideo"
    }
    var title: String? {
        return Localization.SuggestionVideos.localizedString
    }
    
    let thumbnailUrl: String? = "SuggestionVideos"
    let thumbnailType:ThumbnailType = .local
    
    let selectable: Bool = false

    var selectedAction:((_ sourceViewController:UIViewController) -> Void)? {
        return nil
    }
}
