//
//  TwitchStreamListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class TwitchStreamListLoadOperation: ConcurrentOperation {
    fileprivate let twitchService = TwitchService()
    
    fileprivate let success: ([TwitchStream]) -> Void
    fileprivate let failure: ((NSError) -> Void)?
    
    init(success: @escaping ([TwitchStream]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .executing
        let successBlock:((RSStreamListModel) -> Void) = {
            [weak self]streamListModel in
            self?.success(streamListModel.streams.map{ TwitchStream($0) })
            self?.state = .finished
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .finished
        }
        
        twitchService.steamList(pageCount:4, pageNumber: 0, success: successBlock, failure: failureBlock)
    }
}
