import Foundation


class VideoListViewModel: SimpleListCollectionViewModelProtocol {
    fileprivate let channelId: String
    
    var videoList = [Video]()
    
    fileprivate var nextPageToken: String?
    fileprivate var totalResults:Int?
    
    fileprivate let youtubeService = YoutubeService()
    
    init(channelId: String) {
        self.channelId = channelId
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        guard videoList.count !=  totalResults else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [weak self](searchModel) in
            
            let videoList = (searchModel.items).map{ Video($0) }
            
            let successBlock:(() -> Void) = {
                [weak self] in
                self?.totalResults = Int(searchModel.pageInfo.totalResults)
                self?.nextPageToken = searchModel.nextPageToken
                self?.videoList += videoList
                success()
            }
            
            self?.updateVideoDetail(videoList: videoList,
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
    
    fileprivate func updateVideoDetail(videoList: [Video], success: @escaping (() -> Void), failure: ((_ error:NSError) -> Void)?) {
        let videoIdList = videoList.map { $0.videoId! }
        
        let successBlock:((RSVideoDetailModel) -> Void) = {
            (videoDetailModel: RSVideoDetailModel!) in
            for (index, detailItem) in (videoDetailModel.items).enumerated() {
                let video = videoList[index]
                video.update(detailItem)
            }
            success()
        }
        
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }
}
