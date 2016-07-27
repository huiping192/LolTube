//
//  TodayVideoTableViewModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/25/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation

let kVideoWidgetCacheKey: String = "videoWidgetCache"

let kSharedUserDefaultsSuitName: String = "kSharedUserDefaultsSuitName"


class TodayVideoTableViewModel: NSObject {
    var items: [RSVideoListTableViewCellVo]?
    
    private var channelIds:[String]
    
    private let service =  YoutubeService()

    init(channelIds: [String]) {        
        self.channelIds = channelIds
    }
    
    func updateCacheDataWithSuccess(success: (hasCacheData: Bool) -> Void) {
        let cacheData = self.p_videoCache()
        self.items = cacheData
        success(hasCacheData: cacheData != nil)
    }
    
    func p_videoCache() -> [RSVideoListTableViewCellVo]? {
        guard let userDefaults: NSUserDefaults = NSUserDefaults(suiteName: kSharedUserDefaultsSuitName),archivedServerModules = userDefaults.dataForKey(kVideoWidgetCacheKey) else {
            return nil
        }
         
        return NSKeyedUnarchiver.unarchiveObjectWithData(archivedServerModules) as?[RSVideoListTableViewCellVo]
    }
    
    func p_saveVideoCache(videoData: [RSVideoListTableViewCellVo]) {
        guard let userDefaults: NSUserDefaults = NSUserDefaults(suiteName: kSharedUserDefaultsSuitName) else {
            return
        }
        let archivedServerModules: NSData = NSKeyedArchiver.archivedDataWithRootObject(videoData)
        
        userDefaults.setObject(archivedServerModules, forKey: kVideoWidgetCacheKey)
        userDefaults.synchronize()
    }
    
    func updateWithSuccess(success: (hasNewData: Bool) -> Void, failure: (NSError) -> Void) {
        self.service.todayVideoList(self.channelIds, success: {(searchModelList: [RSSearchModel]) -> Void in
            let newItems: [RSVideoListTableViewCellVo] = self.p_itemsWithSearchModelList(searchModelList)
            let hasNewData: Bool = self.items?.count != newItems.count
            self.items = newItems
            self.p_saveVideoCache(newItems)
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    success(hasNewData: hasNewData)
            })
            }, failure: {(error: NSError) -> Void in
                    failure(error)
        })
    }
    
    func p_itemsWithSearchModelList(searchModelList: [RSSearchModel]) -> [RSVideoListTableViewCellVo] {
        var items = [RSVideoListTableViewCellVo]()
        for searchModel: RSSearchModel in searchModelList {
            for item: RSItem in searchModel.items {
                let cellVo: RSVideoListTableViewCellVo = RSVideoListTableViewCellVo()
                cellVo.videoId = item.id.videoId
                cellVo.title = item.snippet.title
                cellVo.defaultThumbnailUrl = item.snippet.thumbnails.medium.url
                cellVo.publishedAt = item.snippet.publishedAt
                items.append(cellVo)
            }
        }
        if items.count == 0 {
            let cellVo: RSVideoListTableViewCellVo = RSVideoListTableViewCellVo()
            cellVo.title = NSLocalizedString("VideoWidgetNoVideos",comment: "no videos")
            items.append(cellVo)
        }
        return self.p_sortChannelItems(items)
    }
    
    func p_sortChannelItems(items: [RSVideoListTableViewCellVo]) -> [RSVideoListTableViewCellVo] {
        return items.sort({item1, item2 in
            
            guard let publishedAt1 = item2.publishedAt, publishedAt2 = item2.publishedAt, date1 = NSDate.date(iso8601String: publishedAt2), date2 = NSDate.date(iso8601String: publishedAt1) else {
                return false
            }
            
            return date2.compare(date1) == .OrderedAscending
        })

    }
}

class RSVideoListTableViewCellVo: NSObject, NSCoding {
    var videoId: String?
    var title: String?
    var defaultThumbnailUrl: String?
    var publishedAt: String?
    
    override init() {
        
    }
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.videoId, forKey: "videoId")
        encoder.encodeObject(self.title, forKey: "title")
        encoder.encodeObject(self.defaultThumbnailUrl, forKey: "defaultThumbnailUrl")
    }
    
    convenience required init?(coder decoder: NSCoder) {
        self.init()

        self.videoId = decoder.decodeObjectForKey("videoId") as? String
        self.title = decoder.decodeObjectForKey("title") as? String
        self.defaultThumbnailUrl = decoder.decodeObjectForKey("defaultThumbnailUrl") as? String
    }
}