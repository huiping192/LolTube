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
            [unowned self](playlistItems) in
            var videoList = [Video]()
            
            for item in playlistItems.items as! [RSPlaylistVideoItem] {
                let video = Video(playlistVideoItem:item)
                videoList.append(video)
            }
            
            let successBlock:(() -> Void) = {
                self.totalResults = Int(playlistItems.pageInfo.totalResults)
                self.nextPageToken = playlistItems.nextPageToken
                self.videoList += videoList
                success()
            }
            
            self.updateVideoDetail(videoList: videoList,
                success: successBlock, failure: failure)
            
        }
        youtubeService.playlistItems(playlistId,nextPageToken:nextPageToken, success: successBlock, failure: failure)
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