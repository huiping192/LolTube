//
//  ChannelVideoListMergeOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation


class ChannelVideoListMergeOperation: Operation {
    
    var channelList: [Channel]?
    var videoDictionary: [String:[Video]]?
    var twtichStreamList: [TwitchStream]?
    var suggestionVideoList:[Video]?
    
    fileprivate let completed:([Channel]?,[String:[TopItem]]?) -> Void
    
    init(completed:@escaping ([Channel]?,[String:[TopItem]]?) -> Void){
        self.completed = completed
    }
    
    override func main() {
        var topItemDictionary:[String:[TopItem]] = [:]
        if let videoDictionary = videoDictionary {
            for (key,value) in videoDictionary {
                topItemDictionary[key] = value.map{$0 as TopItem}
            }
        }
        
        guard let _ = videoDictionary ,let channelList = channelList else {
            completed(nil,nil)            
            return
        }
        
        var allChannelList = channelList
        var allVideoDictionary = topItemDictionary
        
        if let suggestionVideoList = suggestionVideoList, suggestionVideoList.count != 0 {
            let suggestionVideoListChannel = SuggestionVideoListChannel()
            allChannelList.insert(suggestionVideoListChannel, at: 0)
            allVideoDictionary[suggestionVideoListChannel.id] = suggestionVideoList.map{ $0 as TopItem }
        }
        
        if let twitchStreamList = twtichStreamList {
            let twitchChannel = TwitchChannel()
            allChannelList.insert(twitchChannel, at: 0)
            allVideoDictionary[twitchChannel.id] = twitchStreamList.map{ $0 as TopItem }
        }        
        
        completed(allChannelList,allVideoDictionary)            
    }
    
    
    
}
