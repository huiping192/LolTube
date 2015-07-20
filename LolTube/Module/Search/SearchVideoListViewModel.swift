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
    
    private var videoListNextPageToken: String?
    private var videoListTotalResults:Int?
    
    private let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard let searchText = searchText else {
            success()
            return
        }
        
        guard videoListTotalResults != videoList.count else {
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
            
            self.updateVideoDetail(videoList: videoList,
                success: {
                    [unowned self] in
                    self.videoListNextPageToken = searchModel.nextPageToken
                    self.videoListTotalResults = Int(searchModel.pageInfo.totalResults)
                    self.videoList += videoList
                    success()
                }, failure: failure)
            
            
        }
        
        youtubeService.search(searchType, searchText: searchText, nextPageToken: videoListNextPageToken, success: successBlock, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return videoList.count
    }
    
    private func updateVideoDetail(videoList videoList: [Video], success: (() -> Void), failure: ((error:NSError) -> Void)? = nil) {
        let videoIdList = videoList.map {
            video in
            return video.videoId
            } as [String]
        
        let successBlock: ((RSVideoDetailModel) -> Void) = {
            videoDetailModel in
            
            for (index, detailItem) in (videoDetailModel.items as! [RSVideoDetailItem]).enumerate() {
                let video = videoList[index]
                video.update(detailItem)
            }
            
            success()
        }
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }
    
}
