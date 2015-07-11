import Foundation


class VideoListViewModel: SimpleListCollectionViewModelProtocol {
    private let channelId: String

    var videoList = [Video]()

    var nextPageToken: String?
    var totalResults:Int?

    private let youtubeService = YoutubeService()

    init(channelId: String) {
        self.channelId = channelId
    }

    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard videoList.count !=  totalResults else {
            success()
            return
        }
        
        youtubeService.videoList(channelId, searchText: nil, nextPageToken: nextPageToken, success: {
            [unowned self](searchModel) in
            
            var videoList = [Video]()

            for item in searchModel.items as! [RSItem] {
                let video = self.convertVideo(item)
                videoList.append(video)
            }

            self.updateVideoDetail(videoList: videoList,
                    success: {
                        [unowned self] in
                        self.totalResults = Int(searchModel.pageInfo.totalResults)
                        self.nextPageToken = searchModel.nextPageToken
                        self.videoList += videoList
                        success()
                    }, failure: failure)

        }, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return videoList.count
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
            }

            success()
        }, failure: failure)
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
        return video
    }
}