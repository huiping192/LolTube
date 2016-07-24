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
            requestCount++
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
        
        let successBlock: ((NSURLSessionTask, AnyObject?) -> Void) = {
            (_, responseObject) in
            
            do {
                let jsonModel = try jsonModelClass.init(dictionary: responseObject as! [String:AnyObject])
                success?(jsonModel)
            } catch let error  {
                failure?(error as NSError)
            }
        }
        
        AFHTTPSessionManager().GET(urlString, parameters: queryParameters, success: successBlock, failure: {
            (_, error) in
            failure?(error)
        })
        
    }
    
    func request<T:RSJsonModel>(urlString: String, staticParameters: [String:AnyObject], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        
        let operationQueue = NSOperationQueue()
        
        var operationList = [RSHTTPRequestOperation]()
        
        var jsonModelList = [T]()
        var error: NSError?
        
        let completionOperation = NSBlockOperation() {
            dispatch_async(dispatch_get_main_queue(),{
                if let error = error {
                    failure?(error)
                } else {
                    success?(jsonModelList)
                }
            })
            
        }
        
                
        var parameters = staticParameters
        var dynamicParameterKeyList = Array(dynamicParameters.keys)
        for index in 0 ..< (dynamicParameters[dynamicParameterKeyList[0]]?.count ?? 0) {
            for key in dynamicParameterKeyList {
                if let dynamicParameterValue = dynamicParameters[key]?[index] {
                    parameters[key] = dynamicParameterValue
                }
            }
            
            let httpRequestOperation =  RSHTTPRequestOperation(urlString: urlString, parameters: parameters, success: { _,responseObject in
                do {
                    let jsonModel = try jsonModelClass.init(dictionary: responseObject as! [String:AnyObject])
                    jsonModelList.append(jsonModel)
                } catch let parseError  {
                    error = parseError as NSError
                }
                
                }, failure: {
                    error = $1
            })
            
            completionOperation.addDependency(httpRequestOperation)
            operationList.append(httpRequestOperation)
            operationQueue.addOperation(httpRequestOperation)
        }
        
        operationQueue.addOperation(completionOperation)
    }
}