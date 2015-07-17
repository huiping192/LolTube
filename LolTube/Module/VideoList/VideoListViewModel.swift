import Foundation


class VideoListViewModel: SimpleListCollectionViewModelProtocol {
    private let channelId: String

    var videoList = [Video]()

    private var nextPageToken: String?
    private var totalResults:Int?

    private let youtubeService = YoutubeService()

    init(channelId: String) {
        self.channelId = channelId
    }

    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard videoList.count !=  totalResults else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [unowned self](searchModel) in
            
            var videoList = [Video]()
            
            for item in searchModel.items as! [RSItem] {
                let video = self.convertVideo(item)
                videoList.append(video)
            }
            
            let successBlock:(() -> Void) = {
                [unowned self] in
                self.totalResults = Int(searchModel.pageInfo.totalResults)
                self.nextPageToken = searchModel.nextPageToken
                self.videoList += videoList
                success()
            }
            
            self.updateVideoDetail(videoList: videoList,
                success: successBlock, failure: failure)
        }

        youtubeService.videoList(channelId, searchText: nil, nextPageToken: nextPageToken, success: successBlock, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return videoList.count
    }

    private func updateVideoDetail(videoList videoList: [Video], success: (() -> Void), failure: ((error:NSError) -> Void)?) {
        let videoIdList = videoList.map {
            video in
            return video.videoId
        } as [String]

        let successBlock:((RSVideoDetailModel) -> Void) = {
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
        }
        
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }

    private func convertVideo(item: RSItem) -> Video {
        let video = Video()
        video.videoId = item.id.videoId
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails.medium.url
        video.highThumbnailUrl = "http://i.ytimg.com/vi/\(video.videoId)/maxresdefault.jpg"
        video.publishedAt = item.snippet.publishedAt
        video.publishedAtString = RSVideoInfoUtil.convertToShortPostedTime(item.snippet.publishedAt)

        return video
    }
}