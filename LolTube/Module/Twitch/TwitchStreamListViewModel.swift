import Foundation

class TwitchStreamListViewModel:SimpleListCollectionViewModelProtocol {
    
    var streamList = [TwitchStream]()
    
    fileprivate var streamListTotalResults:Int?
    
    fileprivate let twitchService = TwitchService()
    
    init() {
        
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
        guard streamListTotalResults != streamList.count else {
            success()
            return
        }
        
        let successBlock:((RSStreamListModel) -> Void) = {
            [weak self]streamListModel in
            self?.streamListTotalResults = Int(streamListModel._total)
            self?.streamList += streamListModel.streams.map{ TwitchStream($0) }
            
            success()
        }
        
        let perPageCount = 20
        
        twitchService.steamList(pageCount:perPageCount, pageNumber: streamList.count, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int {
        return streamList.count
    }
    
    func allNumberOfItems() -> Int {
        return streamListTotalResults ?? 0
    }
    
}
