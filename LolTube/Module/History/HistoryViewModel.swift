

import Foundation

class HistoryViewModel:SimpleListCollectionViewModelProtocol {
    
    var videoList = [Video]()
    
    private let youtubeService = YoutubeService()

    func loadedNumberOfItems() -> Int {
        return videoList.count
    }
    
    func allNumberOfItems() -> Int {
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        let newVideoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]

        guard newVideoIdList.count != 0 else {
            success()
            return
        }
        
        let successBlock:((RSVideoModel) -> Void) = {
            [weak self]videoModel in
            
            self?.videoList = (videoModel.items as! [RSVideoItem]).map{ Video(videoItem:$0) }
            
            success()
        }
        youtubeService.video(newVideoIdList, success: successBlock, failure: failure)
    }
    
    func refresh(success success: ((isDataChanged:Bool) -> Void), failure: ((error:NSError) -> Void)){
        let newVideoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]
        
        let videoIdList = videoList.map{ $0.videoId! }

        guard newVideoIdList.count != 0 || newVideoIdList != videoIdList else {
            success(isDataChanged: false)
            return
        }
        
        update(success: {success(isDataChanged: true)}, failure: failure)
    }
}