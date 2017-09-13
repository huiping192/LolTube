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
    
    fileprivate var channelIds:[String]
    
    fileprivate let service =  YoutubeService()

    init(channelIds: [String]) {        
        self.channelIds = channelIds
    }
    
    func updateCacheDataWithSuccess(_ success: (_ hasCacheData: Bool) -> Void) {
        let cacheData = self.p_videoCache()
        self.items = cacheData
        success(cacheData != nil)
    }
    
    func p_videoCache() -> [RSVideoListTableViewCellVo]? {
        guard let userDefaults: UserDefaults = UserDefaults(suiteName: kSharedUserDefaultsSuitName),let archivedServerModules = userDefaults.data(forKey: kVideoWidgetCacheKey) else {
            return nil
        }
         
        return NSKeyedUnarchiver.unarchiveObject(with: archivedServerModules) as?[RSVideoListTableViewCellVo]
    }
    
    func p_saveVideoCache(_ videoData: [RSVideoListTableViewCellVo]) {
        guard let userDefaults: UserDefaults = UserDefaults(suiteName: kSharedUserDefaultsSuitName) else {
            return
        }
        let archivedServerModules: Data = NSKeyedArchiver.archivedData(withRootObject: videoData)
        
        userDefaults.set(archivedServerModules, forKey: kVideoWidgetCacheKey)
        userDefaults.synchronize()
    }
    
    func updateWithSuccess(_ success: @escaping (_ hasNewData: Bool) -> Void, failure: @escaping (NSError) -> Void) {
        self.service.todayVideoList(self.channelIds, success: {(searchModelList: [RSSearchModel]) -> Void in
            let newItems: [RSVideoListTableViewCellVo] = self.p_itemsWithSearchModelList(searchModelList)
            let hasNewData: Bool = self.items?.count != newItems.count
            self.items = newItems
            self.p_saveVideoCache(newItems)
            DispatchQueue.main.async(execute: {() -> Void in
                    success(hasNewData)
            })
            }, failure: {(error: NSError) -> Void in
                    failure(error)
        })
    }
    
    func p_itemsWithSearchModelList(_ searchModelList: [RSSearchModel]) -> [RSVideoListTableViewCellVo] {
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
    
    func p_sortChannelItems(_ items: [RSVideoListTableViewCellVo]) -> [RSVideoListTableViewCellVo] {
        return items.sorted(by: {item1, item2 in
            
            guard let publishedAt1 = item2.publishedAt, let publishedAt2 = item2.publishedAt, let date1 = Date.date(iso8601String: publishedAt2), let date2 = Date.date(iso8601String: publishedAt1) else {
                return false
            }
            
            return date2.compare(date1) == .orderedAscending
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
    func encode(with encoder: NSCoder) {
        encoder.encode(self.videoId, forKey: "videoId")
        encoder.encode(self.title, forKey: "title")
        encoder.encode(self.defaultThumbnailUrl, forKey: "defaultThumbnailUrl")
    }
    
    convenience required init?(coder decoder: NSCoder) {
        self.init()

        self.videoId = decoder.decodeObject(forKey: "videoId") as? String
        self.title = decoder.decodeObject(forKey: "title") as? String
        self.defaultThumbnailUrl = decoder.decodeObject(forKey: "defaultThumbnailUrl") as? String
    }
}
