//
//  VideoRelatedVideosViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/4/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AsyncSwift

class VideoRelatedVideosViewModel: SimpleListCollectionViewModelProtocol {
    
    var videoList = [Video]()
    
    private let videoId: String
    private let youtubeService = YoutubeService()
    
    init(videoId:String){
        self.videoId = videoId
    }
    
    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        let successBlock:((RSSearchModel) -> Void) = {
            [weak self]videoModel in
            
            let videoList = videoModel.items.map{ Video($0) }
            self?.updateVideoDetail(videoList: videoList,
                success: {
                    [weak self] in
                    self?.videoList = videoList
                    Async.main{ success() }
                }, failure: failure)
        }
        
        youtubeService.relatedVideoList(videoId, success: successBlock, failure: failure)
    }
    
    private func updateVideoDetail(videoList videoList: [Video], success: (() -> Void), failure: ((error:NSError) -> Void)? = nil) {
        let videoIdList = videoList.map { $0.videoId! }
        
        let successBlock: ((RSVideoDetailModel) -> Void) = {
            videoDetailModel in
            
            for (index, detailItem) in (videoDetailModel.items).enumerate() {
                let video = videoList[index]
                video.update(detailItem)
            }
            
            success()
        }
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }
}