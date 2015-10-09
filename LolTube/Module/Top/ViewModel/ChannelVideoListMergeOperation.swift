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
    var suggestionVideoList:[Video]?
    
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
        
        guard let _ = videoDictionary ,channelList = channelList else {
            completed(nil,nil)            
            return
        }
        
        var allChannelList = channelList
        var allVideoDictionary = topItemDictionary
        
        if let suggestionVideoList = suggestionVideoList where suggestionVideoList.count != 0 {
            let suggestionVideoListChannel = SuggestionVideoListChannel()
            allChannelList.insert(suggestionVideoListChannel, atIndex: 0)
            allVideoDictionary[suggestionVideoListChannel.id] = suggestionVideoList.map{ $0 as TopItem }
        }
        
        if let twitchStreamList = twtichStreamList {
            let twitchChannel = TwitchChannel()
            allChannelList.insert(twitchChannel, atIndex: 0)
            allVideoDictionary[twitchChannel.id] = twitchStreamList.map{ $0 as TopItem }
        }        
        
        completed(allChannelList,allVideoDictionary)            
    }
    
    
    
}