//
//  TopViewDataLoadOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class TopViewDataLoadOperation: GroupOperation {
    
    var bannerItemList: [TopItem]?
    var channelList: [Channel]?
    var videoDictionary: [String:[TopItem]]?
    
    var error: NSError?
    
    let success: (bannerItemList: [TopItem]?,channelList: [Channel]?,videoDictionary: [String:[TopItem]]?) -> Void
    let failure: ((NSError) -> Void)?
    
    private weak var channelLoadOperation:NSOperation?
    private weak var channelVideoListLoadOperation:ChannelVideoListLoadOperation?
    private weak var twitchStreamListLoadOperation:NSOperation?
    private weak var bannerItemListGenerationOperation:BannerItemListGenerationOperation?
    private weak var channelSortOperation:ChannelSortOperation?
    private weak var channelVideoListMergeOperation:ChannelVideoListMergeOperation?
    private weak var suggestionVideoListLoadOperation:SuggestionVideoListLoadOperation?
    
    init(success: (bannerItemList: [TopItem]?,channelList: [Channel]?,videoDictionary: [String:[TopItem]]?) -> Void, failure: ((NSError) -> Void)?){
        self.success = success
        self.failure = failure
        
        super.init()
        
        finishedBlock = {
            [weak self] in
            guard let strongSelf = self else { return }
            if let error = strongSelf.error {
                strongSelf.failure?(error)
                return
            }
            
            strongSelf.success(bannerItemList: strongSelf.bannerItemList, channelList: strongSelf.channelList, videoDictionary: strongSelf.videoDictionary)
        }
    }
    
    override var subOperations:[NSOperation]? {
        let failure: (NSError) -> Void = {
            [weak self]error in
            self?.error = error 
        }
        
        let channelLoadOperation = ChannelLoadOperation(success: {
            [weak self]channelList in 
            self?.channelVideoListLoadOperation?.channelList = channelList
            self?.channelSortOperation?.channelList = channelList.map{ $0 as Channel}
            
            }, failure: failure)
        self.channelLoadOperation = channelLoadOperation
        
        let channelVideoListLoadOperation = ChannelVideoListLoadOperation(success: {[weak self]videoDictionary in 
            self?.channelSortOperation?.videoDictionary = videoDictionary
            self?.bannerItemListGenerationOperation?.videoDictionary = videoDictionary
            self?.channelVideoListMergeOperation?.videoDictionary = videoDictionary
            
            }, failure: failure)
        channelVideoListLoadOperation.addDependency(channelLoadOperation)
        self.channelVideoListLoadOperation = channelVideoListLoadOperation
        
        let channelSortOperation = ChannelSortOperation(){
            [weak self] channelList in
            self?.channelVideoListMergeOperation?.channelList = channelList
        }
        channelSortOperation.addDependency(channelVideoListLoadOperation)
        self.channelSortOperation = channelSortOperation
        
        let bannerItemListGenerationOperation = BannerItemListGenerationOperation(){
            [weak self]bannerItemList in
            self?.bannerItemList = bannerItemList
        }
        bannerItemListGenerationOperation.addDependency(channelVideoListLoadOperation)
        self.bannerItemListGenerationOperation = bannerItemListGenerationOperation
        
        let twitchStreamListLoadOperation = TwitchStreamListLoadOperation(success: {
            [weak self] twitchStreamList in
            self?.channelVideoListMergeOperation?.twtichStreamList = twitchStreamList
            }, failure: failure)
        self.twitchStreamListLoadOperation = twitchStreamListLoadOperation
        
        let suggestionVideoListLoadOperation = SuggestionVideoListLoadOperation(success: {
            [weak self] suggestionVideoList in
            self?.channelVideoListMergeOperation?.suggestionVideoList = suggestionVideoList
            }, failure: failure)
        
        self.suggestionVideoListLoadOperation = suggestionVideoListLoadOperation
        
        let channelVideoListMergeOperation = ChannelVideoListMergeOperation(){
            [weak self] channelList,videoDictionary in 
            self?.channelList = channelList
            self?.videoDictionary = videoDictionary
        }
        
        channelVideoListMergeOperation.addDependency(twitchStreamListLoadOperation)
        channelVideoListMergeOperation.addDependency(channelSortOperation)
        channelVideoListMergeOperation.addDependency(suggestionVideoListLoadOperation)
        
        self.channelVideoListMergeOperation = channelVideoListMergeOperation
        
        return [channelLoadOperation,channelVideoListLoadOperation,twitchStreamListLoadOperation,bannerItemListGenerationOperation,channelSortOperation,channelVideoListMergeOperation,suggestionVideoListLoadOperation]
    }
    
    
    
}