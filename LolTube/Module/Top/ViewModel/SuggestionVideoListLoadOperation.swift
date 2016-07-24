//
//  SuggestionVideoListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/6/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation


class SuggestionVideoListLoadOperation : GroupOperation {
    
    private let videoService = VideoService.sharedInstance
    
    private var videoList: [Video] = []
    private var error: NSError?

    private let success: [Video] -> Void
    private let failure: ((NSError) -> Void)?
    
    init(success: ([Video]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
        
        super.init()
    }
    
    override var subOperations: [NSOperation]? {
        guard let historyList = videoService.historyVideoIdList() else {
            return nil;
        }
        
        let historyTopList = historyList.prefix(5)
        let operations = historyTopList.map{
            RelatedVideoListLoadOperation(videoId: $0, count: 2, success: {
                [weak self] videoList in
                self?.videoList += videoList
                }, failure: {
                    [weak self] error in
                    self?.error = error
                })
        }
        
        super.finishedBlock = {
            [weak self] in
            guard let strongSelf = self else { return } 
            
            if let error = strongSelf.error {
                strongSelf.failure?(error)
                return
            }
            let videoList = Array(Set<Video>(strongSelf.videoList)).filter{
                !historyList.contains($0.videoId)
            }
            strongSelf.success(videoList)
        }
                
        return operations
    }
}