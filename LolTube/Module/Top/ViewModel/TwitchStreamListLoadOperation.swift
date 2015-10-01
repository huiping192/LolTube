//
//  TwitchStreamListLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/27/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class TwitchStreamListLoadOperation: ConcurrentOperation {
    private let twitchService = TwitchService()
    
    private let success: ([TwitchStream]) -> Void
    private let failure: ((NSError) -> Void)?
    
    init(success: ([TwitchStream]) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
    }
    
    override func start() {
        state = .Executing
        let successBlock:(RSStreamListModel -> Void) = {
            [weak self]streamListModel in
            self?.success(streamListModel.streams.map{ TwitchStream($0) })
            self?.state = .Finished
        }
        
        let failureBlock:(NSError -> Void) = {
            [weak self]error in
            self?.failure?(error)
            self?.state = .Finished
        }
        
        twitchService.steamList(pageCount:4, pageNumber: 0, success: successBlock, failure: failureBlock)
    }
}