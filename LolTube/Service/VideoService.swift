//
//  VideoService.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/25/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


let kPlayFinishedVideoIdsKey: String = "playFinishedVideoIds"

let kHistoryVideoIdsKey: String = "historyVideoIds"


class VideoService {
    
    let kDiffPlaybackTime: TimeInterval = 5.0
    
    let kMaxItemCount: Int = 49
    
    var videoDictionary: [String : TimeInterval]?
    var videoIdList: [String]?
    
    static let sharedInstance = VideoService()
    
    func configure() {
        
        let userDefaults: UserDefaults = UserDefaults.standard
        
        self.videoDictionary = userDefaults.dictionary(forKey: kPlayFinishedVideoIdsKey) as? [String : TimeInterval] 
        if self.videoDictionary == nil{
            let cloudStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
            self.videoDictionary = cloudStore.dictionary( forKey: kPlayFinishedVideoIdsKey) as? [String : TimeInterval]
            if self.videoDictionary == nil {
                self.videoDictionary = [String : TimeInterval]()
            }
        }
        self.videoIdList = userDefaults.stringArray(forKey: kHistoryVideoIdsKey)
        if self.videoIdList == nil {
            self.videoIdList = [String]()
        }
    }
    
    func isPlayFinishedWithVideoId(_ videoId: String) -> Bool {
        return videoDictionary?[videoId] != nil
    }
    
    func saveHistoryVideoId(_ videoId: String) {
        
        if let index =  self.videoIdList?.firstIndex(of: videoId) {
            self.videoIdList?.remove(at: index)
        }
        
        if self.videoIdList?.count >= kMaxItemCount {
            self.videoIdList?.remove(at: 0)
        }
        self.videoIdList?.append(videoId)
    }
    
    func savePlayFinishedVideoId(_ videoId: String) {
        if self.videoDictionary?[videoId] != nil {
            return
        }
        if self.videoDictionary?.count >= kMaxItemCount {
            if let keys = videoDictionary?.keys, let key = keys.first {
                videoDictionary?.removeValue(forKey: key)
            }
        }
        self.videoDictionary?[videoId] = 0
        self.save()
    }
    
    func updateLastPlaybackTimeWithVideoId(_ videoId: String, lastPlaybackTime: TimeInterval) {
        self.videoDictionary?[videoId] = lastPlaybackTime
        self.save()
    }
    
    func lastPlaybackTimeWithVideoId(_ videoId: String) -> TimeInterval {
        guard let lastPlaybackTimeNumber: TimeInterval = self.videoDictionary?[videoId] else {
            return 0
        }
        
        return lastPlaybackTimeNumber - kDiffPlaybackTime > 0 ? lastPlaybackTimeNumber - kDiffPlaybackTime : lastPlaybackTimeNumber
    }
    
    func overrideVideoDataWithVideoDictionary(_ videoDictionary: [String : TimeInterval]?) {
        self.videoDictionary = videoDictionary
        if self.videoDictionary == nil {
            self.videoDictionary = [String : TimeInterval]()
        }
        self.save()
    }
    
    func save() {
        let userDefaults: UserDefaults = UserDefaults.standard
        
        userDefaults.set(self.videoDictionary, forKey: kPlayFinishedVideoIdsKey)
        userDefaults.set(self.videoIdList, forKey: kHistoryVideoIdsKey)
        userDefaults.synchronize()
        
        let cloudStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default        
        cloudStore.set(videoDictionary, forKey: kPlayFinishedVideoIdsKey)
        cloudStore.synchronize()
    }
    
    func historyVideoIdList() -> [String]? {
        return self.videoIdList?.reversed()
    }
}
