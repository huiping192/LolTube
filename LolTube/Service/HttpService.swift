//
//  HttpService.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/23/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AFNetworking
import JSONModel

public class HttpService: NSObject  {
    func requestMultipleIdsDynamicParamter(idList:[String]) -> [String:[String]] {
        var idPerUnitList = [String]()
        let idPerUnitCount = 50
        let idListCount = idList.count
        
        var requestCount = idListCount / idPerUnitCount
        if idListCount % idPerUnitCount != 0 {
            requestCount += 1
        }
        for index in 0 ..< requestCount {
            let beginListIndex = index * idPerUnitCount
            var endListIndex = (index + 1) * idPerUnitCount - 1
            if endListIndex >= idListCount {
                endListIndex = idListCount - 1
            }
            idPerUnitList.append(Array(idList[beginListIndex ... endListIndex]).joinWithSeparator(","))
        }
        
        return ["id": idPerUnitList]
    }

    
    func request<T:RSJsonModel>(urlString: String, queryParameters: [String:AnyObject], jsonModelClass: T.Type, success: ((T) -> Void)?, failure: ((NSError) -> Void)?) {
        
        let successBlock: ((AFHTTPRequestOperation!, AnyObject!) -> Void) = {
            (_, responseObject) in
            
            do {
                let jsonModel = try jsonModelClass.init(dictionary: responseObject as? [String:AnyObject])
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
    
    func request<T:RSJsonModel>(urlString: String, staticParameters: [String:AnyObject], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
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
