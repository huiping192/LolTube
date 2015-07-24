//
// Created by 郭 輝平 on 4/9/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AFNetworking
import JSONModel

public enum YoutubeSearchType:String {
    case Video = "video"
    case Channel = "channel"
    case Playlist = "playlist"
}

@objc
public class YoutubeService: NSObject {
    
    let kYoutubeApiKey = "AIzaSyBb1ZDTeUmzba4Kk4wsYtmi70tr7UBo3HA"
    
    // api url
    let searchUrlString = "https://www.googleapis.com/youtube/v3/search?fields=items(id%2Csnippet)%2CpageInfo%2CnextPageToken"
    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos"
    let videoDetailUrlString = "https://www.googleapis.com/youtube/v3/videos"
    let channelUrlString = "https://www.googleapis.com/youtube/v3/channels?fields=items(auditDetails,brandingSettings,contentDetails,contentOwnerDetails,id,snippet,statistics,status,topicDetails)"
    
    let playlistsUrlString = "https://www.googleapis.com/youtube/v3/playlists"
    
    let playlistItemsUrlString = "https://www.googleapis.com/youtube/v3/playlistItems"
    
    public override init() {
        
    }
    
    public func videoList(channelId: String, searchText: String?, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
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
        
        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    public func videoList(channelIdList: [String], searchText: String?, nextPageTokenList: [String]?, success: (([RSSearchModel]) -> Void)?, failure: ((NSError) -> Void)?) {
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
        
        request(searchUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    public func video(videoIdList: [String], success: ((RSVideoModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,statistics,contentDetails",
            "id": ",".join(videoIdList)
        ]
        
        request(videoUrlString, queryParameters: queryparameters, jsonModelClass: RSVideoModel.self, success: success, failure: failure)
    }
    
    public func channel(channelIdList: [String], success: ((RSChannelModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet"
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(channelIdList)
        
        let successBlock: (([RSChannelModel]) -> Void) = {
            jsonModeList in
            
            var allChannelItems = [RSChannelItem]()
            for channelModel in jsonModeList {
                allChannelItems += channelModel.items as! [RSChannelItem]
            }
            let allChannelModel = RSChannelModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(channelUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSChannelModel.self, success: successBlock, failure: failure)
    }
    
    public func channelDetail(channelIdList: [String], success: ((RSChannelModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,brandingSettings,statistics",
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(channelIdList)
        
        let successBlock: (([RSChannelModel]) -> Void) = {
            jsonModeList in
            
            var allChannelItems = [RSChannelItem]()
            for channelModel in jsonModeList {
                allChannelItems += channelModel.items as! [RSChannelItem]
            }
            let allChannelModel = RSChannelModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(channelUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSChannelModel.self, success: successBlock, failure: failure)
    }
    
    public func channelList(searchText: String?, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "type": "channel",
            "maxResults": "10",
            "order": "date",
            "pageToken": nextPageToken ?? "",
            "q": searchText ?? ""
        ]
        
        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    
    public func todayVideoList(channelIdList: [String], success: (([RSSearchModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "type": "video",
            "maxResults": "5",
            "order": "date",
            "publishedAfter": NSDate.todayRFC3339DateTime() as String
        ]
        
        let dynamicParametersValueList = ["channelId": channelIdList]
        
        request(searchUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    public func relatedVideoList(videoId: String, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "relatedToVideoId": videoId,
            "type": "video",
            "maxResults": "20"
        ]
        
        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }
    
    public func videoDetailList(videoIdList: [String], success: ((RSVideoDetailModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "contentDetails,statistics"
        ]
        let dynamicParametersValueList = requestMultipleIdsDynamicParamter(videoIdList)
        
        let successBlock: (([RSVideoDetailModel]) -> Void) = {
            videoDetailModelList in
            
            var allChannelItems = [RSVideoDetailItem]()
            for channelModel in videoDetailModelList {
                allChannelItems += channelModel.items as! [RSVideoDetailItem]
            }
            let allChannelModel = RSVideoDetailModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }
        
        request(videoDetailUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSVideoDetailModel.self, success: successBlock, failure: failure)
    }
    
    public func playlists(channelId: String, nextPageToken: String?, success: ((RSPlaylistModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet,contentDetails",
            "pageToken": nextPageToken ?? "",
            "channelId": channelId,
            "maxResults": "20"
        ]
        
        request(playlistsUrlString, queryParameters: queryparameters, jsonModelClass: RSPlaylistModel.self, success: success, failure: failure)
    }
    
    public func playlistsDetail(playlistsIdList: [String], success: ((RSPlaylistModel) -> Void)?, failure: ((NSError) -> Void)?) {
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
        
        request(playlistsUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSPlaylistModel.self, success: successBlock, failure: failure)
    }
    
    public func playlistItems(playlistId: String, nextPageToken: String?, success: ((RSPlaylistItemsModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
            "key": kYoutubeApiKey,
            "part": "snippet",
            "playlistId": playlistId,
            "pageToken": nextPageToken ?? "",
            "maxResults": "20"
        ]
        
        request(playlistItemsUrlString, queryParameters: queryparameters, jsonModelClass: RSPlaylistItemsModel.self, success: success, failure: failure)
    }

    public func search(searchType:YoutubeSearchType,searchText: String, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet",
                "type": searchType.rawValue,
                "maxResults": "20",
                "pageToken": nextPageToken ?? "",
                "q": searchText ?? ""
        ]

        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self, success: success, failure: failure)
    }

    private func requestMultipleIdsDynamicParamter(idList:[String]) -> [String:[String]] {
        var idPerUnitList = [String]()
        let idPerUnitCount = 50
        let idListCount = idList.count
        
        var requestCount = idListCount / idPerUnitCount
        if idListCount % idPerUnitCount != 0 {
            requestCount++
        }
        for index in 0 ..< requestCount {
            let beginListIndex = index * idPerUnitCount
            var endListIndex = (index + 1) * idPerUnitCount - 1
            if endListIndex >= idListCount {
                endListIndex = idListCount - 1
            }
            idPerUnitList.append(",".join(Array(idList[beginListIndex ... endListIndex])))
        }
        
        return ["id": idPerUnitList]
    }
    
    private func request<T:RSJsonModel>(urlString: String, queryParameters: [String:String], jsonModelClass: T.Type, success: ((T) -> Void)?, failure: ((NSError) -> Void)?) {
        
        let successBlock: ((AFHTTPRequestOperation!, AnyObject!) -> Void) = {
            (_, responseObject) in
            
            do {
                let jsonModel = try jsonModelClass.init(dictionary: responseObject as! [String:AnyObject])
                success?(jsonModel)
            } catch let error  {
                failure?(error as NSError)
            }
        }
        
        AFHTTPRequestOperationManager().GET(urlString, parameters: queryParameters, success: successBlock, failure: {
            (_, error) in
            failure?(error)
        })
    }
    
    private func request<T:RSJsonModel>(urlString: String, staticParameters: [String:String], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        var operationList = [AFHTTPRequestOperation]()
        
        var parameters = staticParameters
        var dynamicParameterKeyList = Array(dynamicParameters.keys)
        for index in 0 ..< (dynamicParameters[dynamicParameterKeyList[0]]?.count ?? 0) {
            for key in dynamicParameterKeyList {
                if let dynamicParameterValue = dynamicParameters[key]?[index] {
                    parameters[key] = dynamicParameterValue
                }
            }
            let httpRequestOperation = AFHTTPRequestOperation(request: AFHTTPRequestSerializer().requestWithMethod("GET", URLString: urlString, parameters: parameters))
            operationList.append(httpRequestOperation)
        }
        
        var jsonModelList = [T]()
        var error: NSError?
        
        let progressBlock: ((UInt, UInt) -> Void) = {
            (numberOfFinishedOperations, totalNumberOfOperations) in
            
            let operation = operationList[Int(numberOfFinishedOperations - 1)]
            if let operationError = operation.error {
                error = operationError
                return
            }
            
            var jsonParseError: JSONModelError?
            let jsonModel = jsonModelClass.init(string: operation.responseString, error: &jsonParseError)
            if let jsonParseError = jsonParseError {
                error = jsonParseError
            } else {
                jsonModelList.append(jsonModel)
            }
        }
        
        let completionBlock: ([AnyObject]! -> Void) = {
            _ in
            
            if let error = error {
                failure?(error)
            } else {
                success?(jsonModelList)
            }
        }
        
        let operations = AFURLConnectionOperation.batchOfRequestOperations(operationList, progressBlock: progressBlock, completionBlock: completionBlock) as! [NSOperation]
        
        NSOperationQueue.mainQueue().addOperations(operations, waitUntilFinished: false)
    }
    
}
