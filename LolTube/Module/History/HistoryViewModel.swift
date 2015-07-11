

import Foundation

class HistoryViewModel:SimpleListCollectionViewModelProtocol {
    
    var videoList = [Video]()
    
    private let youtubeService = YoutubeService()

    func numberOfItems() -> Int{
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        let videoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]

        youtubeService.video(videoIdList, success: {
            [unowned self]videoModel in
            
            var videoList = [Video]()
            
            for videoItem in videoModel.items as! [RSVideoItem] {
                videoList.append(self.convertVideo(videoItem))
            }
            
            self.videoList = videoList
            success()
            }, failure: failure)
    }
    
    
    private func convertVideo(item: RSVideoItem) -> Video {
        let video = Video()
        video.videoId = item.id
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails.medium.url
        video.publishedAt = item.snippet.publishedAt
        
        video.duration = RSVideoInfoUtil.convertVideoDuration(item.contentDetails.duration)
        video.viewCountString = RSVideoInfoUtil.convertVideoViewCount(Int(item.statistics.viewCount) ?? 0)
        video.viewCount = Int(item.statistics.viewCount) ?? 0

        return video
    }
}