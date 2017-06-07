//
//  ChannelSortOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelSortOperation: Operation {
    
    var videoDictionary: [String:[Video]]?
    var channelList: [Channel]?

    fileprivate let completed:(([Channel]) -> Void)
    
    init(completed:@escaping (([Channel]) -> Void)){
        self.completed = completed
    }
    
    override func main() {
        guard let videoDictionary = videoDictionary,let channelList = channelList else {
            return
        }
        
        let sortedChannelList = channelList.sorted {
            let videoList1 = videoDictionary[$0.id]
            let videoList2 = videoDictionary[$1.id]
            
            guard let video1 = videoList1?.first else {
                return false
            }
            
            guard let video2 = videoList2?.first else {
                return true
            }
            
            guard let video1PublishedAt = video1.publishedAt, let video2PublishedAt = video2.publishedAt,let video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), let video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) else {
                return false
            }
            
            return video1PublishedDate.compare(video2PublishedDate) == .orderedDescending
        }
        
        let nonEmptyChannelList = sortedChannelList.filter{ videoDictionary[$0.id]?.count != 0}
        
        completed(nonEmptyChannelList)
    }
}
