import Foundation

class PlaylistViewModel:SimpleListCollectionViewModelProtocol {
    private let playlistId: String

    var videoList = [Video]()
    var nextPageToken: String?
    var totalResults:Int?

    private let youtubeService = YoutubeService()
    
    init(playlistId: String) {
        self.playlistId = playlistId
    }
    
    func numberOfItems() -> Int{
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard videoList.count !=  totalResults else {
            success()
            return
        }
        
        youtubeService.playlistItems(playlistId,nextPageToken:nextPageToken, success: {
            [unowned self](playlistItems) in
            var videoList = [Video]()
            
            for item in playlistItems.items as! [RSPlaylistVideoItem] {
                let video = self.convertVideo(item)
                videoList.append(video)
            }
            
            self.updateVideoDetail(videoList: videoList,
                success: {
                    self.totalResults = Int(playlistItems.pageInfo.totalResults)
                    self.nextPageToken = playlistItems.nextPageToken
                    self.videoList += videoList
                    success()
                }, failure: failure)
            
            }, failure: failure)
    }
    
    private func updateVideoDetail(videoList videoList: [Video], success: (() -> Void), failure: ((error:NSError) -> Void)?) {
        let videoIdList = videoList.map {
            video in
            return video.videoId
            } as [String]
        
        youtubeService.videoDetailList(videoIdList, success: {
            (videoDetailModel: RSVideoDetailModel!) in
            
            for (index, detailItem) in (videoDetailModel.items as! [RSVideoDetailItem]).enumerate() {
                let video = videoList[index]
                video.duration = RSVideoInfoUtil.convertVideoDuration(detailItem.contentDetails.duration)
                video.viewCountString = RSVideoInfoUtil.convertVideoViewCount(Int(detailItem.statistics.viewCount) ?? 0)
                video.viewCount = Int(detailItem.statistics.viewCount) ?? 0
                if let viewCount = video.viewCountString , publishedAtString = video.publishedAtString{
                    video.viewCountPublishedAt = "\(viewCount) ・ \(publishedAtString)"
                }
            }
            
            success()
            }, failure: failure)
    }
    
    private func convertVideo(item: RSPlaylistVideoItem) -> Video {
        let video = Video()
        video.videoId = item.snippet.resourceId.videoId
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails?.medium.url
        video.highThumbnailUrl = "http://i.ytimg.com/vi/\(video.videoId)/maxresdefault.jpg"
        video.publishedAt = item.snippet.publishedAt
        video.publishedAtString = RSVideoInfoUtil.convertToShortPostedTime(item.snippet.publishedAt)

        return video
    }
}