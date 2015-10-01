//
//  ChannelLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class ChannelLoadOperation : ConcurrentOperation {
    private let youtubeService = YoutubeService()
    private let channelService = ChannelService()

    private let success: ([YoutubeChannel]) -> Void
    private let failure: ((NSError) -> Void)?
    
    init(success: ([YoutubeChannel]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .Executing
        let defaultChannelIdList = channelService.channelIds()
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self]channelModel in
            
            let channelList = channelModel.items.map{YoutubeChannel($0)}
            self?.success(channelList)
            self?.state = .Finished
        }
        
        let failureBlock:(NSError -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .Finished
        }
        
        youtubeService.channel(defaultChannelIdList, success: successBlock, failure: failureBlock)
    }
}