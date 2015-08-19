

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
            [unowned self]videoModel in
            
            var videoList = [Video]()
            
            for videoItem in videoModel.items as! [RSVideoItem] {
                videoList.append(Video(videoItem:videoItem))
            }
            
            self.videoList = videoList
            success()
        }
        youtubeService.video(newVideoIdList, success: successBlock, failure: failure)
    }
    
    func refresh(success success: ((isDataChanged:Bool) -> Void), failure: ((error:NSError) -> Void)){
        let newVideoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]
        
        guard newVideoIdList.count != 0 else {
            success(isDataChanged: false)
            return
        }
        
        let videoIdList = videoList.map{
            video in
            return video.videoId
            } as [String]
        
        guard newVideoIdList != videoIdList else {
            success(isDataChanged: false)
            return
        }
        
        update(success: {success(isDataChanged: true)}, failure: failure)
    }
}