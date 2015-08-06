import Foundation

class SearchChannelListViewModel: SimpleListCollectionViewModelProtocol {
    
    var searchText:String?{
        didSet{
            channelList = [Channel]()
            channelListNextPageToken = nil
            channelListTotalResults = nil
        }
    }
    
    var channelList = [Channel]()
    
    private var channelListNextPageToken: String?
    private var channelListTotalResults:Int?
    
    private let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard let searchText = searchText else {
            success()
            return
        }
        
        guard channelListTotalResults != channelList.count else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [unowned self](searchModel) in
            
            var channelList = [Channel]()
            for item in searchModel.items as! [RSItem] {
                let channel = Channel(item:item)
                channelList.append(channel)
            }
            let successBlock:(([Channel]) -> Void) = {
                [unowned self]channelList in
                self.channelListNextPageToken = searchModel.nextPageToken
                self.channelListTotalResults = Int(searchModel.pageInfo.totalResults)
                self.channelList += channelList
                
                success()
            }
            self.updateChannelDetail(channelList, success: successBlock, failure: failure)
        }
        
        youtubeService.search(.Channel, searchText: searchText, nextPageToken: channelListNextPageToken, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int{
        return channelList.count
    }
    
    func allNumberOfItems() -> Int {
        return channelListTotalResults ?? 0
    }
    
    private func updateChannelDetail(channelList:[Channel],success:(([Channel]) -> Void),failure: ((error:NSError) -> Void)? = nil){
        let channelIdList = channelList.map{
            channel in
            return channel.channelId
            } as [String]
        
        let successBlock:((RSChannelModel) -> Void) = {
            channelModel in
            var updatedChannelList = [Channel]()
            
            for channelItem in channelModel.items as! [RSChannelItem]{
                updatedChannelList.append(Channel(channelItem: channelItem))
            }
            
            success(updatedChannelList)
        }
        
        youtubeService.channelDetail(channelIdList, success: successBlock, failure: failure)
    }
}