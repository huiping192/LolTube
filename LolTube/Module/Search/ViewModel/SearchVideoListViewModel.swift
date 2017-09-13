import Foundation

class SearchVideoListViewModel:SimpleListCollectionViewModelProtocol{
    var searchType:YoutubeSearchType = .Video
    var searchText:String?{
        didSet{
            videoList = [Video]()
            videoListNextPageToken = nil
            videoListTotalResults = nil
        }
    }
    
    var videoList = [Video]()
    
    fileprivate var videoListNextPageToken: String?
    fileprivate var videoListTotalResults:Int?
    
    fileprivate let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        guard let searchText = searchText else {
            success()
            return
        }
        
        guard videoListTotalResults != videoList.count else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [weak self](searchModel) in
            
            let videoList = (searchModel.items).map{ Video($0) }
            self?.updateVideoDetail(videoList: videoList,
                success: {
                    [weak self] in
                    self?.videoListNextPageToken = searchModel.nextPageToken
                    self?.videoListTotalResults = Int(searchModel.pageInfo.totalResults)
                    self?.videoList += videoList
                    success()
                }, failure: failure)
            
            
        }
        
        youtubeService.search(searchType, searchText: searchText, nextPageToken: videoListNextPageToken, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return videoListTotalResults ?? 0
    }
    
    fileprivate func updateVideoDetail(videoList: [Video], success: @escaping (() -> Void), failure: ((_ error:NSError) -> Void)? = nil) {
        let videoIdList = videoList.map { $0.videoId! } 
        
        let successBlock: ((RSVideoDetailModel) -> Void) = {
            videoDetailModel in
            
            for (index, detailItem) in (videoDetailModel.items).enumerated() {
                let video = videoList[index]
                video.update(detailItem)
            }
            
            success()
        }
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }
    
}
