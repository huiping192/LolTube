//
//  VideoInfoViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import AsyncSwift

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
    
    func updateWithSuccess(success: () -> Void, failure: (NSError) -> Void) {
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
    
    func updateVideoDetailWithSuccess(success: () -> Void, failure: (NSError) -> Void) {
        self.service.videoDetailList([self.videoId], success: {[weak self]videoDetailModel in
            guard let weakSelf = self else {
                return
            }
            
            Async.userInitiated {
                if videoDetailModel.items.count != 1 {
                    return
                }
                let detailItem: RSVideoDetailItem = videoDetailModel.items[0]
                let formatter: NSNumberFormatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                let formatted: String = formatter.stringFromNumber(Int(detailItem.statistics.viewCount)!)!
                weakSelf.viewCount = String(format: NSLocalizedString("VideoViewCountFormat",comment: "%@ views"), formatted)
                let likeCount: String = formatter.stringFromNumber(Int(detailItem.statistics.likeCount)!)!
                let dislikeCount: String = formatter.stringFromNumber(Int(detailItem.statistics.dislikeCount)!)!
                weakSelf.rate = String(format: NSLocalizedString("VideoLikeDislikeFormat",comment: "%@ likes, %@ dislikes"), likeCount, dislikeCount)
                
                }.main {
                    success()   
            }
            
            
            }, failure: failure)
    }
    
    func p_postedTimeWithPublishedAt(publishedAt: String) -> String? {
        guard let publishedDate: NSDate = NSDate.date(iso8601String: publishedAt) else {
            return nil
        }
        
        let form: NSDateFormatter = NSDateFormatter()
        form.dateFormat = "yyyy/MM/dd HH:mm"
        form.locale = NSLocale.currentLocale()
        return String(format: NSLocalizedString("VideoDetailPostedAtFormatter",comment: ""), form.stringFromDate(publishedDate))
    }
}