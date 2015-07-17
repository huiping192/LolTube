

import Foundation

class HistoryViewModel:SimpleListCollectionViewModelProtocol {
    
    var videoList = [Video]()
    
    private let youtubeService = YoutubeService()

    func numberOfItems() -> Int{
        return videoList.count
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        let newVideoIdList = RSVideoService.sharedInstance().historyVideoIdList() as! [String]

        guard newVideoIdList.count != 0 else {
            success()
            return
        }
        
        let videoIdList = videoList.map{
            video in
            return video.videoId
        } as [String]
        
        guard newVideoIdList != videoIdList else {
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
}