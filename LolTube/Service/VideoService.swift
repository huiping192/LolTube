//
//  VideoService.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/25/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation

let kPlayFinishedVideoIdsKey: String = "playFinishedVideoIds"

let kHistoryVideoIdsKey: String = "historyVideoIds"


class VideoService {
    
    let kDiffPlaybackTime: NSTimeInterval = 5.0
    
    let kMaxItemCount: Int = 49
    
    var videoDictionary: [String : NSTimeInterval]?
    var videoIdList: [String]?
    
    static let sharedInstance = VideoService()
    
    func configure() {
        
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        self.videoDictionary = userDefaults.dictionaryForKey(kPlayFinishedVideoIdsKey) as? [String : NSTimeInterval] 
        if self.videoDictionary == nil{
            let cloudStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
            self.videoDictionary = cloudStore.dictionaryForKey( kPlayFinishedVideoIdsKey) as? [String : NSTimeInterval]
            if self.videoDictionary == nil {
                self.videoDictionary = [String : NSTimeInterval]()
            }
        }
        self.videoIdList = userDefaults.stringArrayForKey(kHistoryVideoIdsKey)
        if self.videoIdList == nil {
            self.videoIdList = [String]()
        }
    }
    
    func isPlayFinishedWithVideoId(videoId: String) -> Bool {
        return videoDictionary?[videoId] != nil
    }
    
    func saveHistoryVideoId(videoId: String) {
        
        if let index =  self.videoIdList?.indexOf(videoId) {
            self.videoIdList?.removeAtIndex(index)
        }
        
        if self.videoIdList?.count >= kMaxItemCount {
            self.videoIdList?.removeAtIndex(0)
        }
        self.videoIdList?.append(videoId)
    }
    
    func savePlayFinishedVideoId(videoId: String) {
        if self.videoDictionary?[videoId] != nil {
            return
        }
        if self.videoDictionary?.count >= kMaxItemCount {
            if let keys = videoDictionary?.keys, key = keys.first {
                videoDictionary?.removeValueForKey(key)
            }
        }
        self.videoDictionary?[videoId] = 0
        self.save()
    }
    
    func updateLastPlaybackTimeWithVideoId(videoId: String, lastPlaybackTime: NSTimeInterval) {
        self.videoDictionary?[videoId] = lastPlaybackTime
        self.save()
    }
    
    func lastPlaybackTimeWithVideoId(videoId: String) -> NSTimeInterval {
        guard let lastPlaybackTimeNumber: NSTimeInterval = self.videoDictionary?[videoId] else {
            return 0
        }
        
        return lastPlaybackTimeNumber - kDiffPlaybackTime > 0 ? lastPlaybackTimeNumber - kDiffPlaybackTime : lastPlaybackTimeNumber
    }
    
    func overrideVideoDataWithVideoDictionary(videoDictionary: [String : NSTimeInterval]?) {
        self.videoDictionary = videoDictionary
        if self.videoDictionary == nil {
            self.videoDictionary = [String : NSTimeInterval]()
        }
        self.save()
    }
    
    func save() {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(self.videoDictionary, forKey: kPlayFinishedVideoIdsKey)
        userDefaults.setObject(self.videoIdList, forKey: kHistoryVideoIdsKey)
        userDefaults.synchronize()
        
        let cloudStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()        
        cloudStore.setObject(videoDictionary, forKey: kPlayFinishedVideoIdsKey)
        cloudStore.synchronize()
    }
    
    func historyVideoIdList() -> [String]? {
        return self.videoIdList?.reverse()
    }
}