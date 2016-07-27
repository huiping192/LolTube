

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
        let historyVideoIdList = VideoService.sharedInstance.historyVideoIdList()

        guard let newVideoIdList = historyVideoIdList where newVideoIdList.count != 0 else {
            success()
            return
        }
        
        let successBlock:((RSVideoModel) -> Void) = {
            [weak self]videoModel in
            
            self?.videoList = (videoModel.items).map{ Video($0) }
            
            success()
        }
        youtubeService.video(newVideoIdList, success: successBlock, failure: failure)
    }
    
    func refresh(success success: ((isDataChanged:Bool) -> Void), failure: ((error:NSError) -> Void)){                
        guard let newVideoIdList = VideoService.sharedInstance.historyVideoIdList() else {
            success(isDataChanged: false)
            return
        }
        
        let videoIdList = videoList.map{ $0.videoId! }

        guard newVideoIdList.count != 0 && newVideoIdList != videoIdList else {
            success(isDataChanged: false)
            return
        }
                
        update(success: {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            let isDataChanged =  videoIdList != weakSelf.videoList.map{ $0.videoId! }
            success(isDataChanged: isDataChanged)
            }, failure: failure)
    }
}