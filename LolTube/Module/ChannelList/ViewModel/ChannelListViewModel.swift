
import Foundation
import UIKit

class ChannelListViewModel: SimpleListCollectionViewModelProtocol{
    
    var channelList = [Channel]()
    
    private let youtubeService = YoutubeService()
    private let channelService = RSChannelService()
    
    init() {
        
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        
        let channelIdList = channelService.channelIds() as! [String]
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self](channelModel) in
            
            self?.channelList = (channelModel.items as! [RSChannelItem]).map{Channel(channelItem:$0)}
            
            success()
        }
        
        youtubeService.channel(channelIdList, success: successBlock, failure: failure)
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
