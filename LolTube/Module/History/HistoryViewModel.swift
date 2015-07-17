

import Foundation

class HistoryViewModel:SimpleListCollectionViewModelProtocol {
    
    var videoList = [Video]()
    
    private let youtubeService = YoutubeService()

    func numberOfItems() -> Int{
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        let newVideoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]

        guard newVideoIdList.count != 0 else {
            success()
            return
        }
        
        let videoIdList = videoList.map{
            video in
            return video.videoId
        } as [String]
        
        guard newVideoIdList != videoIdList else {
            return
        }
        
        let successBlock:((RSVideoModel) -> Void) = {
            [unowned self]videoModel in
            
            var videoList = [Video]()
            
            for videoItem in videoModel.items as! [RSVideoItem] {
                videoList.append(self.convertVideo(videoItem))
            }
            
            self.videoList = videoList
            success()
        }
        youtubeService.video(newVideoIdList, success: successBlock, failure: failure)
    }
    
    
    private func convertVideo(item: RSVideoItem) -> Video {
        let video = Video()
        video.videoId = item.id
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails.medium.url
        video.publishedAt = item.snippet.publishedAt
        video.publishedAtString = RSVideoInfoUtil.convertToShortPostedTime(item.snippet.publishedAt)

        video.duration = RSVideoInfoUtil.convertVideoDuration(item.contentDetails.duration)
        video.viewCountString = RSVideoInfoUtil.convertVideoViewCount(Int(item.statistics.viewCount) ?? 0)
        video.viewCount = Int(item.statistics.viewCount) ?? 0

        if let viewCount = video.viewCountString , publishedAtString = video.publishedAtString{
            video.viewCountPublishedAt = "\(viewCount) ・ \(publishedAtString)"
        }
        
        return video
    }
}