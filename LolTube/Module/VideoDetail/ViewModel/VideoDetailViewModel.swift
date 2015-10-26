//
//  VideoDetailViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/3/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AsyncSwift 

class VideoDetailViewModel {

    let videoId:String
    var shareTitle:String?
    var shareUrl:NSURL?{
        return NSURL(string: "https://www.youtube.com/watch?v=\(videoId)")
    }
  
    var thumbnailImageUrl:String?
    
    var channelId:String?
    var channelTitle:String?
    
    private let youtubeService = YoutubeService()
    
    init(videoId:String){
        self.videoId = videoId
    }
    
    func update(success success:() -> Void,failure:(NSError) -> Void){
        let successBlock: (RSVideoModel -> Void) = {
            [weak self]videoModel in
            guard let strongSelf = self else {
                return
            }
            guard let videoItem = videoModel.items?.first else {
                Async.main{success()}
                return 
            }
            strongSelf.shareTitle = videoItem.snippet.title
            strongSelf.thumbnailImageUrl = videoItem.snippet.thumbnails.medium.url
            strongSelf.channelId = videoItem.snippet.channelId
            strongSelf.channelTitle = videoItem.snippet.channelTitle
                        
            Async.main{success()}
        }
        
        youtubeService.video([videoId], success: successBlock, failure: failure)
    }
    
    func handoffUrl(videoCurrentPlayTime:NSTimeInterval?) -> NSURL? {
        if let videoCurrentPlayTime = videoCurrentPlayTime {
            return NSURL(string: "https://www.youtube.com/watch?v=\(videoId)&t=\(videoCurrentPlayTime)")
        }
        return NSURL(string: "https://www.youtube.com/watch?v=\(videoId)")
    }
}