//
//  TopRankVideoGenerationOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class BannerItemListGenerationOperation: Operation {
    
    var videoDictionary: [String:[Video]]?
    fileprivate let completed:(([TopItem]) -> Void)
    
    fileprivate let highRankVideoCount = 4
    
    init(completed:@escaping (([TopItem]) -> Void)){
        self.completed = completed
    }
    
    override func main() {
        completed(highRankVideoList())
    }
    
    fileprivate func highRankVideoList() -> [TopItem] {
        guard let videoDictionary = videoDictionary else {
            return []
        }
        
        let videoList = videoDictionary.map{ $0.1 }.reduce([], (+))
        
        let sortedVideoList = videoList.sorted {
            guard let video1PublishedAt = $0.publishedAt, let video2PublishedAt = $1.publishedAt else {
                return false   
            }
            guard let video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), let video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) else {
                return false 
            }
            
            return $0.viewCount > $1.viewCount || video1PublishedDate.compare(video2PublishedDate) == .orderedDescending
        }
        
        return Array(sortedVideoList.prefix(highRankVideoCount)).map{$0 as TopItem}
    }
}
