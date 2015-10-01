//
//  ChannelVideoListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelVideoListLoadOperation : ConcurrentOperation {
    private let youtubeService = YoutubeService()
    
    var channelList: [YoutubeChannel]?
    
    private let success: ([String:[Video]]) -> Void
    private let failure: ((NSError) -> Void)?
    
    init(success: ([String:[Video]]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .Executing
        
        guard let channelList = channelList else {
            state = .Finished
            return
        }
        
        
        let successBlock:(([RSSearchModel]) -> Void) = {
            [weak self]searchModelList in
            guard let strongSelf = self else { return }
            var videoDictionary = [String: [Video]]()
            
            for (index, searchModel) in searchModelList.enumerate() {
                videoDictionary[channelList[index].id] = searchModel.items?.map{ Video($0) }
            }
            strongSelf.success(videoDictionary)
            strongSelf.state = .Finished
        }
        
        let failureBlock:(NSError -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .Finished
        } 
        let channelIdList = channelList.map{ $0.channelId }
        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failureBlock)
    }
}