import Foundation

class ChannelDetailViewModel {
    let channelId:String

    var channel:Channel?
    
    var isSubscribed:Bool?
    private let youtubeService = YoutubeService()
    private let channelService = RSChannelService()


    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: () -> Void, failure: (NSError) -> Void) {
        
        let successBlock:((RSChannelModel) -> Void) = {
            [unowned self](channelModel) in
            
            guard channelModel.items.count > 0 else {
                success()
                return
            }
            if let channelItem = channelModel.items[0] as? RSChannelItem{
                self.channel = Channel(channelItem: channelItem)
            }
            
            self.isSubscribed = (self.channelService.channelIds() as! [String]).contains(self.channelId)
            success()
        }
        youtubeService.channelDetail([channelId], success: successBlock, failure: failure)
    }
    
    func subscribeChannel(success success: () -> Void, failure: (NSError) -> Void){
        guard let isSubscribed = isSubscribed else {
            success()
            return
        }
        if isSubscribed {
            channelService.deleteChannelId(channelId)
            self.isSubscribed = false
        } else {
            channelService.saveChannelId(channelId)
            self.isSubscribed = true
        }
        success()
    }
}
