import Foundation

class ChannelDetailViewModel {
    let channelId:String

    var channel:Channel?
    
    private let youtubeService = YoutubeService()

    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: () -> Void, failure: (NSError) -> Void) {
        
        let successBlock:((RSChannelModel) -> Void) = {
            [unowned self](channelModel) in
            if let channelItem = channelModel.items[0] as? RSChannelItem{
                self.channel = Channel(channelItem: channelItem)
            }
            success()
        }
        youtubeService.channelDetail([channelId], success: successBlock, failure: failure)
    }
}
