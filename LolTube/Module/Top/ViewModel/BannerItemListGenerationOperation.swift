//
//  TopRankVideoGenerationOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class BannerItemListGenerationOperation: NSOperation {
    
    var videoDictionary: [String:[Video]]?
    private let completed:([TopItem] -> Void)
    
    private let highRankVideoCount = 4
    
    init(completed:([TopItem] -> Void)){
        self.completed = completed
    }
    
    override func main() {
        completed(highRankVideoList())
    }
    
    private func highRankVideoList() -> [TopItem] {
        guard let videoDictionary = videoDictionary else {
            return []
        }
        
        let videoList = videoDictionary.map{ $0.1 }.reduce([], combine: (+))
        
        let sortedVideoList = videoList.sort {
            guard let video1PublishedAt = $0.publishedAt, video2PublishedAt = $1.publishedAt else {
                return false   
            }
            guard let video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) else {
                return false 
            }
            
            return $0.viewCount > $1.viewCount || video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }
        
        return Array(sortedVideoList.prefix(highRankVideoCount)).map{$0 as TopItem}
    }
}