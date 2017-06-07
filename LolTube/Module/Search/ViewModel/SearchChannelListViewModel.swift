import Foundation

class SearchChannelListViewModel: SimpleListCollectionViewModelProtocol {
    
    var searchText:String?{
        didSet{
            channelList = [YoutubeChannel]()
            channelListNextPageToken = nil
            channelListTotalResults = nil
        }
    }
    
    var channelList = [YoutubeChannel]()
    
    fileprivate var channelListNextPageToken: String?
    fileprivate var channelListTotalResults:Int?
    
    fileprivate let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        guard let searchText = searchText else {
            success()
            return
        }
        
        guard channelListTotalResults != channelList.count else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [weak self](searchModel) in
            
            let channelList = (searchModel.items).map{ YoutubeChannel($0) }
  
            let successBlock:(([YoutubeChannel]) -> Void) = {
                [weak self]channelList in
                self?.channelListNextPageToken = searchModel.nextPageToken
                self?.channelListTotalResults = Int(searchModel.pageInfo.totalResults)
                self?.channelList += channelList
                
                success()
            }
            self?.updateChannelDetail(channelList, success: successBlock, failure: failure)
        }
        
        youtubeService.search(.Channel, searchText: searchText, nextPageToken: channelListNextPageToken, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int{
        return channelList.count
    }
    
    func allNumberOfItems() -> Int {
        return channelListTotalResults ?? 0
    }
    
    fileprivate func updateChannelDetail(_ channelList:[YoutubeChannel],success:@escaping (([YoutubeChannel]) -> Void),failure: ((_ error:NSError) -> Void)? = nil){
        let channelIdList = channelList.map{ $0.channelId } 
        
        let successBlock:((RSChannelModel) -> Void) = {
            channelModel in
            let updatedChannelList = channelModel.items.map{ YoutubeChannel($0) }
            
            success(updatedChannelList)
        }
        
        youtubeService.channelDetail(channelIdList, success: successBlock, failure: failure)
    }
}
