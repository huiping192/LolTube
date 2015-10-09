//
//  SuggestionVideoListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/6/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation


class SuggestionVideoListLoadOperation : GroupOperation {
    
    private let videoService = RSVideoService.sharedInstance()
    
    private var videoList: [Video] = []
    private let success: [Video] -> Void
    private let failure: ((NSError) -> Void)?
    
    init(success: ([Video]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
        
        super.init()

        guard let historyList = videoService.historyVideoIdList() else {
            return;
        }
        
        let historyTopList = historyList.prefix(5)
        let operations = historyTopList.map{
            RelatedVideoListLoadOperation(videoId: $0, count: 2, success: {
                [weak self] videoList in
                self?.videoList += videoList
                }, failure: {
                    [weak self] error in
                    self?.failure?(error)
                })
        }
        
        let finishedOperation = NSBlockOperation(block: {
            [weak self] in
            guard let strongSelf = self else { return } 
            let videoList = Array(Set<Video>(strongSelf.videoList)).filter{
                !historyList.contains($0.videoId)
            }
            strongSelf.success(videoList)
        })
        
        operations.forEach{ finishedOperation.addDependency($0) }
        
        addOperations([finishedOperation] + operations)
    }
    
}