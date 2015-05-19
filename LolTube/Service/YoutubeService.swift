//
// Created by 郭 輝平 on 4/9/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation

@objc
public class YoutubeService: NSObject {

    let kYoutubeApiKey = "AIzaSyBb1ZDTeUmzba4Kk4wsYtmi70tr7UBo3HA"

    // api url
    let searchUrlString = "https://www.googleapis.com/youtube/v3/search?fields=items(id%2Csnippet)%2CpageInfo%2CnextPageToken"
    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos?fields=items(fileDetails%2Cplayer%2CprocessingDetails%2CprojectDetails%2CrecordingDetails%2Csnippet%2Cstatistics%2Cstatus)"
    let videoDetailUrlString = "https://www.googleapis.com/youtube/v3/videos"
    let channelUrlString = "https://www.googleapis.com/youtube/v3/channels?fields=items(auditDetails,brandingSettings,contentDetails,contentOwnerDetails,id,snippet,statistics,status,topicDetails)"

    public override init() {

    }

    public func videoList(channelId: String, searchText: String?, nextPageToken: String?, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet",
                "channelId": channelId,
                "type": "video",
                "maxResults": "10",
                "order": "date",
                "pageToken": nextPageToken ?? "",
                "q": searchText ?? ""
        ]

        let httpOperationManager = AFHTTPRequestOperationManager()

        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self as RSJsonModel.Type, success: {
            (jsonModel: RSJsonModel) in
            success?(jsonModel as! RSSearchModel)
        }, failure: failure)
    }

    public func videoList(channelIdList: [String], searchText: String?, nextPageTokenList: [String]?, success: (([RSSearchModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        if channelIdList.count == 1 {
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

        request(searchUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self as RSJsonModel.Type, success: {
            (jsonModeList: [RSJsonModel]) in
            success?(jsonModeList as! [RSSearchModel])
        }, failure: failure)
    }

    public func video(videoId: String, success: ((RSVideoModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet",
                "id": videoId
        ]

        request(videoUrlString, queryParameters: queryparameters, jsonModelClass: RSVideoModel.self as RSJsonModel.Type, success: {
            (jsonModel: RSJsonModel) in
            success?(jsonModel as! RSVideoModel)
        }, failure: failure)
    }

    public func channel(channelIdList: [String], success: ((RSChannelModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet"
        ]
        var dynamicParametersValueList = requestMultipleIdsDynamicParamter(channelIdList)

        request(channelUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSChannelModel.self as RSJsonModel.Type, success: {
            (jsonModeList: [RSJsonModel]) in

            var allChannelItems = [RSChannelItem]()
            for channelModel in jsonModeList as! [RSChannelModel] {
                allChannelItems += channelModel.items as! [RSChannelItem]
            }
            var allChannelModel = RSChannelModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }, failure: failure)

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

        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self as RSJsonModel.Type, success: {
            (jsonModel: RSJsonModel) in
            success?(jsonModel as! RSSearchModel)
        }, failure: failure)
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

        var dynamicParametersValueList = ["channelId": channelIdList]

        request(searchUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSSearchModel.self as RSJsonModel.Type, success: {
            (jsonModeList: [RSJsonModel]) in
            success?(jsonModeList as! [RSSearchModel])
        }, failure: failure)
    }

    public func relatedVideoList(videoId: String, success: ((RSSearchModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "snippet",
                "relatedToVideoId": videoId,
                "type": "video",
                "maxResults": "20"
        ]

        request(searchUrlString, queryParameters: queryparameters, jsonModelClass: RSSearchModel.self as RSJsonModel.Type, success: {
            (jsonModel: RSJsonModel) in
            success?(jsonModel as! RSSearchModel)
        }, failure: failure)
    }

    public func videoDetailList(videoIdList: [String], success: ((RSVideoDetailModel) -> Void)?, failure: ((NSError) -> Void)?) {
        let queryparameters = [
                "key": kYoutubeApiKey,
                "part": "contentDetails,statistics"
        ]
        var dynamicParametersValueList = requestMultipleIdsDynamicParamter(videoIdList)

        request(videoDetailUrlString, staticParameters: queryparameters, dynamicParameters: dynamicParametersValueList, jsonModelClass: RSVideoDetailModel.self as RSJsonModel.Type, success: {
            (jsonModeList: [RSJsonModel]) in

            var allChannelItems = [RSVideoDetailItem]()
            for channelModel in jsonModeList as! [RSVideoDetailModel] {
                allChannelItems += channelModel.items as! [RSVideoDetailItem]
            }
            var allChannelModel = RSVideoDetailModel()
            allChannelModel.items = allChannelItems
            success?(allChannelModel)
        }, failure: failure)
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
        let httpOperationManager = AFHTTPRequestOperationManager()
        httpOperationManager.GET(urlString, parameters: queryParameters, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in

            var jsonParseError: NSError?
            let jsonModel = jsonModelClass(dictionary: responseObject as! [String:AnyObject], error: &jsonParseError)
            if let jsonParseError = jsonParseError {
                failure?(jsonParseError)
            } else {
                success?(jsonModel)
            }

        }, failure: {
            (operation: AFHTTPRequestOperation!, error: NSError!) in
            failure?(error)
        })
    }

    private func request<T:RSJsonModel>(urlString: String, staticParameters: [String:String], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        var operationList = [AFHTTPRequestOperation]()

        var parameters = staticParameters
        var dynamicParameterKeyList = Array(dynamicParameters.keys)
        for index in 0 ..< dynamicParameters[dynamicParameterKeyList[0]]!.count {
            for key in dynamicParameterKeyList {
                if let dynamicParameterValue = dynamicParameters[key]?[index] {
                    parameters[key] = dynamicParameterValue
                }
            }
            let httpRequestOperation = AFHTTPRequestOperation(request: AFHTTPRequestSerializer().requestWithMethod("GET", URLString: urlString, parameters: parameters, error: nil))
            operationList.append(httpRequestOperation)
        }

        var jsonModelList = [T]()
        var error: NSError?
        let operations = AFURLConnectionOperation.batchOfRequestOperations(operationList, progressBlock: {
            (numberOfFinishedOperations: UInt, totalNumberOfOperations: UInt) in

            let operation = operationList[Int(numberOfFinishedOperations - 1)]
            if let operationError = operation.error {
                error = operationError
                return
            }

            var jsonParseError: JSONModelError?
            let jsonModel = jsonModelClass(string: operation.responseString, error: &jsonParseError)
            if let jsonParseError = jsonParseError {
                error = jsonParseError
            } else {
                jsonModelList.append(jsonModel)
            }

        }, completionBlock: {
            (operations: Array!) in

            if let error = error {
                failure?(error)
            } else {
                success?(jsonModelList)
            }
        })

        NSOperationQueue.mainQueue().addOperations(operations, waitUntilFinished: false)
    }
}
