import Foundation

struct  Channel: Hashable,Equatable {
    var channelId: String!
    var title: String?
    var description: String?
    var thumbnailUrl: String?
    var bannerImageUrl: String?

    var videoCount: Int?
    var subscriberCount: Int?
    var viewCount: Int?
    
    var videoCountString: String? {
        return ChannelInfoUtil.convertVideoCount(videoCount ?? 0)
    }
    var subscriberCountString: String? {
        return ChannelInfoUtil.convertSubscriberCount(subscriberCount ?? 0)
    }
    var viewCountString: String? {
        return RSVideoInfoUtil.convertVideoViewCount(viewCount ?? 0)
    }


    init(channelItem:RSChannelItem){
        self.channelId = channelItem.channelId
        self.title = channelItem.snippet.title
        self.description = channelItem.snippet.channelDescription
        self.thumbnailUrl = channelItem.snippet.thumbnails.medium.url
        self.bannerImageUrl = channelItem.brandingSettings?.image?.bannerMobileImageUrl
        if let statistics = channelItem.statistics {
            self.viewCount = Int(statistics.viewCount)
            self.subscriberCount = Int(statistics.subscriberCount)
            self.videoCount = Int(statistics.videoCount)
        }
        
    }

    var hashValue: Int {
        return 1
    }
}

func ==(lhs: Channel, rhs: Channel) -> Bool {
    return lhs.channelId == rhs.channelId
}