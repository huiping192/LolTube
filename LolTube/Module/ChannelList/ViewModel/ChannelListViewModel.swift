
import Foundation
import UIKit

class ChannelListViewModel: SimpleListCollectionViewModelProtocol{
    
    var channelList = [Channel]()
    
    private let youtubeService = YoutubeService()
    private let channelService = ChannelService()
    
    init() {
        
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        
        let channelIdList = channelService.channelIds()
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self](channelModel) in
            self?.channelList = (channelModel.items as! [RSChannelItem]).map{Channel(channelItem:$0)}
            
            success()
        }
        
        youtubeService.channel(channelIdList, success: successBlock, failure: failure)
    }
    
    
    func refresh(success success: ((isDataChanged:Bool) -> Void), failure: ((error:NSError) -> Void)) {
        
        let newChannelIdList = channelService.channelIds()
        let channelIdList = channelList.map{ $0.channelId! }
        
        guard newChannelIdList.count != 0 && newChannelIdList != channelIdList else {
            success(isDataChanged: false)
            return
        }
        
        update(success: {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            let isDataChanged =  channelIdList != weakSelf.channelList.map{ $0.channelId! }
            success(isDataChanged: isDataChanged)
            }, failure: failure)
    }

    
    func loadedNumberOfItems() -> Int{
        return channelList.count
    }
    
    func allNumberOfItems() -> Int {
        return channelList.count
    }
    
    func deleteChannel(channelId channelId:String){
        channelService.deleteChannelId(channelId)
    }
    
}
