//
//  VideoDetailUpdateOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class VideoDetailUpdateOperation: ConcurrentOperation {
    fileprivate let youtubeService = YoutubeService()
    
    fileprivate let video: Video
    fileprivate let success: () -> Void
    fileprivate let failure: ((NSError) -> Void)?
    
    init(video: Video,success: @escaping () -> Void, failure: ((NSError) -> Void)?){
        self.video = video
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .executing
        
        guard video.duration == nil || video.viewCount == nil else {
            success()
            state = .finished
            return
        }
        
        let successBlock:((RSVideoDetailModel) -> Void) = {
            [weak self]videoDetailModel in
            if let videoDetail = videoDetailModel.items.first {
                self?.video.update(videoDetail)
            }
            self?.success()
            self?.state = .finished
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .finished
        }
        
        youtubeService.videoDetail(video.videoId, success: successBlock, failure: failureBlock)
    }
}
