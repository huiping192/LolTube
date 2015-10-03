//
//  ChannelSortOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelSortOperation: NSOperation {
    
    var videoDictionary: [String:[Video]]?
    var channelList: [Channel]?

    private let completed:([Channel] -> Void)
    
    init(completed:([Channel] -> Void)){
        self.completed = completed
    }
    
    override func main() {
        guard let videoDictionary = videoDictionary,channelList = channelList else {
            return
        }
        
        let sortedChannelList = channelList.sort {
            let videoList1 = videoDictionary[$0.id]
            let videoList2 = videoDictionary[$1.id]
            
            guard let video1 = videoList1?.first else {
                return false
            }
            
            guard let video2 = videoList2?.first else {
                return true
            }
            
            guard let video1PublishedAt = video1.publishedAt, video2PublishedAt = video2.publishedAt,video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) else {
                return false
            }
            
            return video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }
        
        let nonEmptyChannelList = sortedChannelList.filter{ videoDictionary[$0.id]?.count != 0}
        
        completed(nonEmptyChannelList)
    }
}