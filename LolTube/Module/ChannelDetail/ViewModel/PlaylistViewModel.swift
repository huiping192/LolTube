import Foundation

class PlaylistViewModel:SimpleListCollectionViewModelProtocol {
    fileprivate let playlistId: String

    var videoList = [Video]()
    var nextPageToken: String?
    var totalResults:Int?

    fileprivate let youtubeService = YoutubeService()
    
    init(playlistId: String) {
        self.playlistId = playlistId
    }
    
    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return totalResults ?? 0
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        guard videoList.count != totalResults else {
            success()
            return
        }
        
        let successBlock:((RSPlaylistItemsModel) -> Void) = {
            [weak self](playlistItems) in
            
            let videoList = (playlistItems.items as! [RSPlaylistVideoItem]).map{ Video($0) }
            
            let successBlock:(() -> Void) = {
                [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.totalResults = Int(playlistItems.pageInfo!.totalResults)
                weakSelf.nextPageToken = playlistItems.nextPageToken
                weakSelf.videoList += videoList
                success()
            }
            
            self?.updateVideoDetail(videoList: videoList,
                success: successBlock, failure: failure)
            
        }
        youtubeService.playlistItems(playlistId,nextPageToken:nextPageToken, success: successBlock, failure: failure)
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
