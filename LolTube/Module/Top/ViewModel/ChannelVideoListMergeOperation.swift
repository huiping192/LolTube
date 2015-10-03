//
//  ChannelVideoListMergeOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation


class ChannelVideoListMergeOperation: NSOperation {
    
    var channelList: [Channel]?
    var videoDictionary: [String:[Video]]?
    var twtichStreamList: [TwitchStream]?

    private let completed:([Channel]?,[String:[TopItem]]?) -> Void
    
    init(completed:([Channel]?,[String:[TopItem]]?) -> Void){
        self.completed = completed
    }
    
    override func main() {
        var topItemDictionary:[String:[TopItem]] = [:]
        if let videoDictionary = videoDictionary {
            for (key,value) in videoDictionary {
                topItemDictionary[key] = value.map{$0 as TopItem}
            }
        }
        
        guard let twitchStreamList = twtichStreamList else {
            completed(channelList,topItemDictionary)            
            return
        }
        
        
        guard let _ = videoDictionary ,channelList = channelList else {
            completed(nil,nil)            
            return
        }
        
        let twitchChannel = TwitchChannel()
        var allChannelList = channelList
        allChannelList.insert(twitchChannel, atIndex: 0)
        var allVideoDictionary = topItemDictionary
        allVideoDictionary[twitchChannel.id] = twitchStreamList.map{ $0 as TopItem }
        completed(allChannelList,allVideoDictionary)            
    }
    
    
    
}