//
//  ChannelLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelLoadOperation : ConcurrentOperation {
    fileprivate let youtubeService = YoutubeService()
    fileprivate let channelService = ChannelService()

    fileprivate let success: ([YoutubeChannel]) -> Void
    fileprivate let failure: ((NSError) -> Void)?
    
    init(success: @escaping ([YoutubeChannel]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .executing
        let defaultChannelIdList = channelService.channelIds()
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self]channelModel in
            
            let channelList = channelModel.items.map{YoutubeChannel($0)}
            self?.success(channelList)
            self?.state = .finished
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .finished
        }
        
        youtubeService.channel(defaultChannelIdList, success: successBlock, failure: failureBlock)
    }
}
