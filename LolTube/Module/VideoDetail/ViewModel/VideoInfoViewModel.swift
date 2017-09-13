//
//  VideoInfoViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import Async

class VideoInfoViewModel {
    
    var videoId: String
    var title: String?
    var postedTime: String?
    var rate: String?
    var viewCount: String?
    var videoDescription: String?
    
    var service: YoutubeService = YoutubeService()
    
    init(videoId: String) {
        self.videoId = videoId
    }
    
    func updateWithSuccess(_ success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        self.service.video([videoId], success: {[weak self]videoModel in
            guard let weakSelf = self else {
                return
            }
            
            if videoModel.items == nil || videoModel.items.count == 0 {
                return
            }
            let videoItem: RSVideoItem = videoModel.items[0]
            weakSelf.videoDescription = videoItem.snippet.videoDescription
            weakSelf.title = videoItem.snippet.title
            weakSelf.postedTime = weakSelf.p_postedTimeWithPublishedAt(videoItem.snippet.publishedAt)
            
            Async.main {
                success() 
            }
            }, failure: { error in
                failure(error)
        })
    }
    
    func updateVideoDetailWithSuccess(_ success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        self.service.videoDetailList([self.videoId], success: {[weak self]videoDetailModel in
            guard let weakSelf = self else {
                return
            }
            
            Async.userInitiated {
                if videoDetailModel.items.count != 1 {
                    return
                }
                let detailItem: RSVideoDetailItem = videoDetailModel.items[0]
                let formatter: NumberFormatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                
                let viewCount = Int(detailItem.statistics.viewCount)! as NSNumber
                let formatted: String = formatter.string(from: viewCount)!
                weakSelf.viewCount = String(format: NSLocalizedString("VideoViewCountFormat",comment: "%@ views"), formatted)
                
                let a = Int(detailItem.statistics.likeCount)! as NSNumber
                let likeCount: String = formatter.string(from:a)!
                
                let b = Int(detailItem.statistics.dislikeCount)! as NSNumber
                let dislikeCount: String = formatter.string(from:b)!
                weakSelf.rate = String(format: NSLocalizedString("VideoLikeDislikeFormat",comment: "%@ likes, %@ dislikes"), likeCount, dislikeCount)
                
                }.main {
                    success()   
            }
            
            
            }, failure: failure)
    }
    
    func p_postedTimeWithPublishedAt(_ publishedAt: String) -> String? {
        guard let publishedDate: Date = Date.date(iso8601String: publishedAt) else {
            return nil
        }
        
        let form: DateFormatter = DateFormatter()
        form.dateFormat = "yyyy/MM/dd HH:mm"
        form.locale = Locale.current
        return String(format: NSLocalizedString("VideoDetailPostedAtFormatter",comment: ""), form.string(from: publishedDate))
    }
}
