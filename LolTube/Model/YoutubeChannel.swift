import Foundation

struct YoutubeChannel:Channel,Equatable {
    var id: String{
        return "Youtube_Channel_\(channelId)"
    }
    var channelId: String
    var title: String?
    var description: String?
    var thumbnailUrl: String?
    var bannerImageUrl: String?

    var videoCount: Int?
    var subscriberCount: Int?
    var viewCount: Int?
    
    var videoCountString: String? {
        return (videoCount ?? 0).toVideoCountFormat()
    }
    var subscriberCountString: String? {
        return (subscriberCount ?? 0).toSubscriberCountFormat()
    }
    var viewCountString: String? {
        return RSVideoInfoUtil.convertVideoViewCount(viewCount ?? 0)
    }

    var selectedAction:(sourceViewController:UIViewController) -> Void {
        return { sourceViewController in
            sourceViewController.showViewController(sourceViewController.instantiateChannelDetailViewController(id:self.channelId,title:self.title), sender: sourceViewController)
        }
    }
    
    let thumbnailType:ThumbnailType = .Remote
    
    init(_ channelItem:RSChannelItem){
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
    
    init(_ item:RSItem){
        self.channelId = item.snippet.channelId
        self.title = item.snippet.title
        self.thumbnailUrl = item.snippet.thumbnails.medium.url
    }
}

func ==(lhs: YoutubeChannel, rhs: YoutubeChannel) -> Bool {
    return lhs.channelId == rhs.channelId
}