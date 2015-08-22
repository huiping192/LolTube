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
    
    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return totalResults ?? 0
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard videoList.count != totalResults else {
            success()
            return
        }
        
        let successBlock:((RSPlaylistItemsModel) -> Void) = {
            [weak self](playlistItems) in
            
            let videoList = (playlistItems.items as! [RSPlaylistVideoItem]).map{ Video(playlistVideoItem:$0) }
            
            let successBlock:(() -> Void) = {
                [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.totalResults = Int(playlistItems.pageInfo.totalResults)
                weakSelf.nextPageToken = playlistItems.nextPageToken
                weakSelf.videoList += videoList
                success()
            }
            
            self?.updateVideoDetail(videoList: videoList,
                success: successBlock, failure: failure)
            
        }
        youtubeService.playlistItems(playlistId,nextPageToken:nextPageToken, success: successBlock, failure: failure)
    }
    
    private func updateVideoDetail(videoList videoList: [Video], success: (() -> Void), failure: ((error:NSError) -> Void)?) {
        let videoIdList = videoList.map { $0.videoId! }
        
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