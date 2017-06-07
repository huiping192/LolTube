//
//  VideoDetailSegmentViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import Async

class VideoDetailSegmentViewModel {
    
    var channelId: String
    var isSubscribed: Bool = false
    var channelThumbnailImageUrl: String?
    var subscriberCount: String?
    
    var channelService: ChannelService = ChannelService()
    var youtubeService: YoutubeService = YoutubeService()
    
    init(channelId: String) {
        self.channelId = channelId
    }
    
    func updateWithSuccess(_ success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        self.youtubeService.channelDetail([self.channelId], success: {[weak self]channelModel in
            guard let weakSelf = self else {
                return
            }
            
            if channelModel.items.count == 0 {
                Async.main {
                    success()
                }
                return
            }
            let channelItem: RSChannelItem = channelModel.items[0]
            weakSelf.channelThumbnailImageUrl = channelItem.snippet.thumbnails.medium.url
            let numberFormatter: NumberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let subscriberCount: String = numberFormatter.string(from: NSNumber(integerLiteral:Int(channelItem.statistics.subscriberCount)!))!
            weakSelf.subscriberCount = String(format: NSLocalizedString("ChannelSubscriberCountFormat",comment: ""), subscriberCount)
            weakSelf.isSubscribed = weakSelf.channelService.channelIds().contains(weakSelf.channelId) ?? false
            Async.main {
                    success()
            }
            }, failure: {error in
                    failure(error)
        })
    }
    
    func subscribeChannelWithSuccess(_ success: () -> Void, failure: (NSError) -> Void) {
        if self.isSubscribed {
            self.channelService.deleteChannelId(self.channelId)
            self.isSubscribed = false
        }
        else {
            self.channelService.saveChannelId(self.channelId)
            self.isSubscribed = true
        }
        success()
    }
}
