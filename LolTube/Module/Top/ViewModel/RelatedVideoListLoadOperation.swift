//
//  RelatedVideoListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/7/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation


class RelatedVideoListLoadOperation : ConcurrentOperation {
    fileprivate let youtubeService = YoutubeService()
    
    fileprivate let success: ([Video]) -> Void
    fileprivate let failure: ((NSError) -> Void)?
    
    fileprivate let videoId: String
    fileprivate let count: Int

    init(videoId: String,count: Int = 20, success: @escaping ([Video]) -> Void, failure: ((NSError) -> Void)?){
        self.videoId = videoId
        self.count = count
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .executing
        
        let successBlock:((RSSearchModel) -> Void) = {
            [weak self]searchModel in
            guard let strongSelf = self else { return }
            let videoList = searchModel.items.map{ Video($0) }
            strongSelf.success(videoList)
            strongSelf.state = .finished
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .finished
        } 
        
        youtubeService.relatedVideoList(videoId,count: count, success: successBlock, failure: failureBlock)
    }
}
