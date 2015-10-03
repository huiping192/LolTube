import Foundation

// FIXME: change Video to struct
class Video: TopItem {
    var id: String{
        return "Youtbe Video \(videoId)"
    }
    var videoId: String!
    var channelId: String?

    var title: String?
    var channelTitle: String?
    var publishedAt: String?
    var duration: String?
    var viewCount: Int?
    var thumbnailUrl: String?
    
    var durationString: String?{
        return RSVideoInfoUtil.convertVideoDuration(duration)
    }
    var highThumbnailUrl: String?{
        return "https://i.ytimg.com/vi/\(videoId)/maxresdefault.jpg"
    }
    var viewCountString: String?{
        return RSVideoInfoUtil.convertVideoViewCount(viewCount ?? 0)
    }
    var publishedAtString: String?{
        return RSVideoInfoUtil.convertToShortPostedTime(publishedAt)
    }
    var viewCountPublishedAt:String?{
        guard let viewCount = viewCountString , publishedAtString = publishedAtString else {
            return nil
        }
        return "\(viewCount) ・ \(publishedAtString)"
    }
    
    init(_ videoItem:RSVideoItem){
        self.videoId = videoItem.id
        self.channelId = videoItem.snippet.channelId
        self.channelTitle = videoItem.snippet.channelTitle
        self.title = videoItem.snippet.title
        self.thumbnailUrl = videoItem.snippet.thumbnails.medium.url
        self.publishedAt = videoItem.snippet.publishedAt        
        self.duration = videoItem.contentDetails.duration
        self.viewCount = Int(videoItem.statistics.viewCount)
    }
    
    init(_ playlistVideoItem:RSPlaylistVideoItem){
        self.videoId = playlistVideoItem.snippet.resourceId.videoId
        self.channelId = playlistVideoItem.snippet.channelId
        self.channelTitle = playlistVideoItem.snippet.channelTitle
        self.title = playlistVideoItem.snippet.title
        self.thumbnailUrl = playlistVideoItem.snippet.thumbnails?.medium.url
        self.publishedAt = playlistVideoItem.snippet.publishedAt
    }
    
    init(_ item:RSItem){
        self.videoId = item.id.videoId
        self.channelId = item.snippet.channelId
        self.channelTitle = item.snippet.channelTitle
        self.title = item.snippet.title
        self.thumbnailUrl = item.snippet.thumbnails.medium.url
        self.publishedAt = item.snippet.publishedAt

    }
    
    func update(videoDetailModel: RSVideoDetailItem){
        duration = videoDetailModel.contentDetails.duration
        viewCount = Int(videoDetailModel.statistics.viewCount)
    }
    
    var selectedAction:(sourceViewController:UIViewController) -> Void {
        return { [weak self]sourceViewController in
            guard let strongSelf = self else {
                return 
            }
            sourceViewController.showViewController(sourceViewController.instantiateVideoDetailViewController(strongSelf.videoId), sender: sourceViewController)
        }
    }
}
