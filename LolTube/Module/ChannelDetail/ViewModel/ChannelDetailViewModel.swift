import Foundation

class ChannelDetailViewModel {
    let channelId:String

    var channel: YoutubeChannel?
    
    var isSubscribed:Bool?
    private let youtubeService = YoutubeService()
    private let channelService = ChannelService()


    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: () -> Void, failure: (NSError) -> Void) {
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self](channelModel) in
            guard let weakSelf = self else {
                return
            }
            guard channelModel.items.count > 0 else {
                success()
                return
            }
            if let channelItem = channelModel.items.first {
                weakSelf.channel = YoutubeChannel(channelItem)
            }
            
            weakSelf.isSubscribed = (weakSelf.channelService.channelIds()).contains(weakSelf.channelId)
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
