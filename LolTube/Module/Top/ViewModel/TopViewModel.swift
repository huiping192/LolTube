import Foundation
import Async

class TopViewModel {
    
    var bannerItemList: [TopItem]?
    
    var channelList: [Channel]?
    var videoDictionary: [String:[TopItem]]?
    
    let dataLoadOperationQueue = OperationQueue()
    
    func update(_ success: @escaping () -> Void,failure: @escaping (NSError) -> Void) {
        let topViewDataLoadOperation = TopViewDataLoadOperation(success: {
            [weak self]bannerItemList,channelList,videoDictionary in
            self?.channelList = channelList
            self?.videoDictionary = videoDictionary
            self?.bannerItemList = bannerItemList

            Async.main{ success() }
            }, failure: {
                error in
                Async.main{ failure(error) }
        })
        dataLoadOperationQueue.addOperation(topViewDataLoadOperation)
    }
    
    
    func updateVideoDetail(_ video: Video, success: @escaping () -> Void) {
        let successBlock:() -> Void = {
            Async.main{success()}
        }
        let videoDetailUpdateOperation = VideoDetailUpdateOperation(video: video, success: successBlock, failure: nil)
        dataLoadOperationQueue.addOperation(videoDetailUpdateOperation)
    }
}
