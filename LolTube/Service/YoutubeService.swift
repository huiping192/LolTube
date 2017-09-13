//
// Created by 郭 輝平 on 4/9/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import JSONModel

public enum YoutubeSearchType:String {
    case Video = "video"
    case Channel = "channel"
    case Playlist = "playlist"
}

open class YoutubeService: HttpService {
    
    let kYoutubeApiKey = "AIzaSyBb1ZDTeUmzba4Kk4wsYtmi70tr7UBo3HA"
    
    // api url
    let searchUrlString = "https://www.googleapis.com/youtube/v3/search?fields=items(id%2Csnippet)%2CpageInfo%2CnextPageToken"
    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos"
    let videoDetailUrlString = "https://www.googleapis.com/youtube/v3/videos"
    let channelUrlString = "https://www.googleapis.com/youtube/v3/channels?fields=items(auditDetails,brandingSettings,contentDetails,contentOwnerDetails,id,snippet,statistics,status,topicDetails)"
    
    let playlistsUrlString = "https://www.googleapis.com/youtube/v3/playlists"
    
    let playlistItemsUrlString = "https://www.googleapis.com/youtube/v3/playlistItems"
    
    open func videoList(_ channelId: String, searchText: String? = nil, nextPageToken: String? = nil, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "channelId": channelId,
            "type": "video",
            "maxResults": "20",
            "order": "date",
            "pageToken": nextPageToken ?? "",
            "q": searchText ?? ""
        ]
        
        request(searchUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    open func videoList(_ channelIdList: [String], searchText: String?, nextPageTokenList: [String]?, success: (([RSSearchModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        guard channelIdList.count != 1 else {
            videoList(channelIdList[0], searchText: searchText, nextPageToken: nextPageTokenList?[0], success: {
                (searchModel: RSSearchModel) in
                success?([searchModel])
                
                }, failure: failure)
            return
        }
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "type": "video",
            "maxResults": "5",
            "order": "date",
            "q": searchText ?? ""
        ]
        
        var dynamicParametersValueList = ["channelId": channelIdList]
        if let nextPageTokenList = nextPageTokenList {
            dynamicParametersValueList["pageToken"] = nextPageTokenList
        }
        
        request(searchUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    open func video(_ videoIdList: [String], success: ((RSVideoModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,statistics,contentDetails",
            "id": videoIdList.joined(separator: ",")
        ]
        
        request(videoUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSVideoModel.self, success: success, failure: failure)
    }
    
    open func channel(_ channelIdList: [String], success: ((RSChannelModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet"
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(channelIdList)
        
        let successBlock: (([RSChannelModel]) -> Void) = {
            jsonModeList in
            
            var allChannelItems = [RSChannelItem]()
            for channelModel in jsonModeList {
                allChannelItems += channelModel.items
            }
            let allChannelModel = RSChannelModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(channelUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSChannelModel.self, success: successBlock, failure: failure)
    }
    
    open func channelDetail(_ channelIdList: [String], success: ((RSChannelModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,brandingSettings,statistics",
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(channelIdList)
        
        let successBlock: (([RSChannelModel]) -> Void) = {
            jsonModeList in
            
            var allChannelItems = [RSChannelItem]()
            for channelModel in jsonModeList {
                allChannelItems += channelModel.items
            }
            let allChannelModel = RSChannelModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(channelUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSChannelModel.self, success: successBlock, failure: failure)
    }
    
    open func channelList(_ searchText: String?, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "type": "channel",
            "maxResults": "10",
            "order": "date",
            "pageToken": nextPageToken ?? "",
            "q": searchText ?? ""
        ]
        
        request(searchUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    
    open func todayVideoList(_ channelIdList: [String], success: (([RSSearchModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "type": "video",
            "maxResults": "5",
            "order": "date",
            "publishedAfter": Date.todayRFC3339DateTime() as String
        ]
        
        let dynamicParametersValueList = ["channelId": channelIdList]
        
        request(searchUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    open func relatedVideoList(_ videoId: String,count: Int = 20 , success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "relatedToVideoId": videoId,
            "type": "video",
            "maxResults": String(count)
        ]
        
        request(searchUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    open func videoDetail(_ videoId: String, success: ((RSVideoDetailModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "contentDetails,statistics",
            "id": videoId
        ]
        
        request(videoDetailUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSVideoDetailModel.self, success: success, failure: failure)
    }
    
    open func videoDetailList(_ videoIdList: [String], success: ((RSVideoDetailModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "contentDetails,statistics"
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(videoIdList)
        
        let successBlock: (([RSVideoDetailModel]) -> Void) = {
            videoDetailModelList in
            
            var allChannelItems = [RSVideoDetailItem]()
            for channelModel in videoDetailModelList {
                allChannelItems += channelModel.items
            }
            let allChannelModel = RSVideoDetailModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(videoDetailUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSVideoDetailModel.self, success: successBlock, failure: failure)
    }
    
    open func playlists(_ channelId: String, nextPageToken: String?, success: ((RSPlaylistModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,contentDetails",
            "pageToken": nextPageToken ?? "",
            "channelId": channelId,
            "maxResults": "20"
        ]
        
        request(playlistsUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSPlaylistModel.self, success: success, failure: failure)
    }
    
    open func playlistsDetail(_ playlistsIdList: [String], success: ((RSPlaylistModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,contentDetails",
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(playlistsIdList)
        
        let successBlock: (([RSPlaylistModel]) -> Void) = {
            playlistModel in
            
            var allPlaylistItems = [RSPlaylistItem]()
            for playlistModel in playlistModel {
                allPlaylistItems += playlistModel.items as! [RSPlaylistItem]
            }
            let allPlaylistModel = RSPlaylistModel()
            allPlaylistModel.items = allPlaylistItems
            success?(allPlaylistModel)
        }
        
        request(playlistsUrlString, staticParameters: queryparameters as [String : AnyObject], dynamicParameters: dynamicParametersValueList, jsonModelClass: RSPlaylistModel.self, success: successBlock, failure: failure)
    }
    
    open func playlistItems(_ playlistId: String, nextPageToken: String?, success: ((RSPlaylistItemsModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "playlistId": playlistId,
            "pageToken": nextPageToken ?? "",
            "maxResults": "20"
        ]
        
        request(playlistItemsUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSPlaylistItemsModel.self, success: success, failure: failure)
    }

    open func search(_ searchType:YoutubeSearchType,searchText: String, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet",
                "type": searchType.rawValue,
                "maxResults": "20",
                "pageToken": nextPageToken ?? "",
                "q": searchText ?? ""
        ]

        request(searchUrlString, queryParameters: queryparameters as [String : AnyObject], jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
}
