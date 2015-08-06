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
                let video = Video(item:item)
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
    
    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return totalResults ?? 0
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
                video.update(detailItem)
            }
            success()
        }
        
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }
}