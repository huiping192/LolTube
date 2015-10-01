import Foundation
import Async

class TopViewModel {
    private let youtubeService = YoutubeService()
    private let channelService = ChannelService()
    private let twitchService = TwitchService()
    
    var bannerItemList: [TopItem]?
    
    var channelList: [Channel]?
    var videoDictionary: [String:[TopItem]]?
        
    private let operationQueue = NSOperationQueue()

    private var channelLoadOperation:NSOperation?
    private var channelVideoListLoadOperation:ChannelVideoListLoadOperation?
    private var twitchStreamListLoadOperation:NSOperation?
    private var bannerItemListGenerationOperation:BannerItemListGenerationOperation?
    private var channelSortOperation:ChannelSortOperation?
    private var channelVideoListMergeOperation:ChannelVideoListMergeOperation?
    
    func update(videoSuccess: () -> Void,bannerSuccess: () -> Void,failure: (NSError) -> Void) {
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
            Async.main{bannerSuccess()}
        }
        bannerItemListGenerationOperation.addDependency(channelVideoListLoadOperation)
        self.bannerItemListGenerationOperation = bannerItemListGenerationOperation

        let twitchStreamListLoadOperation = TwitchStreamListLoadOperation(success: {
            [weak self] twitchStreamList in
            self?.channelVideoListMergeOperation?.twtichStreamList = twitchStreamList
            }, failure: failure)
        self.twitchStreamListLoadOperation = twitchStreamListLoadOperation
        
        let channelVideoListMergeOperation = ChannelVideoListMergeOperation(){
            [weak self] channelList,videoDictionary in 
            self?.channelList = channelList
            self?.videoDictionary = videoDictionary
            
            Async.main{videoSuccess()}
        }
        channelVideoListMergeOperation.addDependency(twitchStreamListLoadOperation)
        channelVideoListMergeOperation.addDependency(channelSortOperation)
        self.channelVideoListMergeOperation = channelVideoListMergeOperation
        
        operationQueue.addOperation(channelLoadOperation)
        operationQueue.addOperation(channelVideoListLoadOperation)
        operationQueue.addOperation(channelSortOperation)
        operationQueue.addOperation(bannerItemListGenerationOperation)
        operationQueue.addOperation(twitchStreamListLoadOperation)
        operationQueue.addOperation(channelVideoListMergeOperation)
    }
    
   
    func updateVideoDetail(video: Video, success: () -> Void) {
        let successBlock:() -> Void = {
            Async.main{success()}
        }
        let videoDetailUpdateOperation = VideoDetailUpdateOperation(video: video, success: successBlock, failure: nil)
        operationQueue.addOperation(videoDetailUpdateOperation)
    }
}
