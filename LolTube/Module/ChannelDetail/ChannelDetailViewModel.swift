import Foundation

class ChannelDetailViewModel {
    let channelId:String

    var channel:Channel?
    
    private let youtubeService = YoutubeService()

    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: () -> Void, failure: (NSError) -> Void) {
        youtubeService.channelDetail(channelId, success: {
            [unowned self](channelModel) in
            
            if let channelItem = channelModel.items[0] as? RSChannelItem{
                self.channel = self.convertChannel(channelItem)
            }
            
            success()
            
        }, failure: failure)
    }
    
    private func convertChannel(item: RSChannelItem) -> Channel {
        let channel = Channel()
        channel.channelId = item.channelId
        channel.title = item.snippet.title
        channel.description = item.snippet.channelDescription
        channel.thumbnailUrl = item.snippet.thumbnails.medium.url
        channel.bannerImageUrl = item.brandingSettings.image.bannerMobileImageUrl
        channel.viewCount = Int(item.statistics.viewCount)
        channel.subscriberCount = Int(item.statistics.subscriberCount)
        channel.videoCount = Int(item.statistics.videoCount)
        channel.viewCountString = RSVideoInfoUtil.convertVideoViewCount(Int(item.statistics.viewCount) ?? 0)
        channel.subscriberCountString = ChannelInfoUtil.convertSubscriberCount(Int(item.statistics.subscriberCount) ?? 0)
            channel.videoCountString = ChannelInfoUtil.convertVideoCount(Int(item.statistics.videoCount) ?? 0)
        
        return channel
    }

}
