//
//  ChannelVideoListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelVideoListLoadOperation : ConcurrentOperation {
    fileprivate let youtubeService = YoutubeService()
    
    var channelList: [YoutubeChannel]?
    
    fileprivate let success: ([String:[Video]]) -> Void
    fileprivate let failure: ((NSError) -> Void)?
    
    init(success: @escaping ([String:[Video]]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .executing
        
        guard let channelList = channelList else {
            state = .finished
            return
        }
        
        
        let successBlock:(([RSSearchModel]) -> Void) = {
            [weak self]searchModelList in
            guard let strongSelf = self else { return }
            var videoDictionary = [String: [Video]]()
            
            for (index, searchModel) in searchModelList.enumerated() {
                videoDictionary[channelList[index].id] = searchModel.items?.map{ Video($0) }
            }
            strongSelf.success(videoDictionary)
            strongSelf.state = .finished
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .finished
        } 
        let channelIdList = channelList.map{ $0.channelId }
        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failureBlock)
    }
}
