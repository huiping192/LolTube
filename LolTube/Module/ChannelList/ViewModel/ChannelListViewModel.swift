
import Foundation
import UIKit

class ChannelListViewModel: SimpleListCollectionViewModelProtocol{
    
    var channelList = [YoutubeChannel]()
    
    fileprivate let youtubeService = YoutubeService()
    fileprivate let channelService = ChannelService()
    
    init() {
        
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        
        let channelIdList = channelService.channelIds()
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self](channelModel) in
            self?.channelList = (channelModel.items).map{YoutubeChannel($0)}
            
            success()
        }
        
        youtubeService.channel(channelIdList, success: successBlock, failure: failure)
    }
    
    
    func refresh(success: @escaping ((_ isDataChanged:Bool) -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        
        let newChannelIdList = channelService.channelIds()
        let channelIdList = channelList.map{ $0.channelId }
        
        guard newChannelIdList.count != 0 && newChannelIdList != channelIdList else {
            success(false)
            return
        }
        
        update(success: {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            let isDataChanged =  channelIdList != weakSelf.channelList.map{ $0.channelId }
            success(isDataChanged)
            }, failure: failure)
    }

    
    func loadedNumberOfItems() -> Int{
        return channelList.count
    }
    
    func allNumberOfItems() -> Int {
        return channelList.count
    }
    
    func deleteChannel(channelId:String){
        channelService.deleteChannelId(channelId)
    }
    
}
