import Foundation
import Async

class TopViewModel {
    
    var bannerItemList: [TopItem]?
    
    var channelList: [Channel]?
    var videoDictionary: [String:[TopItem]]?
    
    let dataLoadOperationQueue = NSOperationQueue()
    
    func update(success: () -> Void,failure: (NSError) -> Void) {
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
    
    
    func updateVideoDetail(video: Video, success: () -> Void) {
        let successBlock:() -> Void = {
            Async.main{success()}
        }
        let videoDetailUpdateOperation = VideoDetailUpdateOperation(video: video, success: successBlock, failure: nil)
        dataLoadOperationQueue.addOperation(videoDetailUpdateOperation)
    }
}
