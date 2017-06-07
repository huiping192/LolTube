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

open class HttpService: NSObject  {
    func requestMultipleIdsDynamicParamter(_ idList:[String]) -> [String:[String]] {
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
            idPerUnitList.append(Array(idList[beginListIndex ... endListIndex]).joined(separator: ","))
        }
        
        return ["id": idPerUnitList]
    }

    
    func request<T:RSJsonModel>(_ urlString: String, queryParameters: [String:AnyObject], jsonModelClass: T.Type, success: ((T) -> Void)?, failure: ((NSError) -> Void)?) {
        
        let successBlock: ((AFHTTPRequestOperation?, Any?) -> Void) = {
            (_, responseObject) in
            
            do {
                let jsonModel = try jsonModelClass.init(dictionary: responseObject as? [String:AnyObject])
                success?(jsonModel)
            } catch let error  {
                failure?(error as NSError)
            }
        }
        
        AFHTTPRequestOperationManager().get(urlString, parameters: queryParameters, success: successBlock, failure: {
            (_, error: Error?) in
            failure?(error as! NSError)
        })
        
//        AFHTTPRequestOperationManager().get(
//            
//            , parameters: Any!, success: { (<#AFHTTPRequestOperation?#>, Any?) in
//                code
//        }) { (AFHTTPRequestOperation?, Error?) in
//            
//        }
    }
    
    func request<T:RSJsonModel>(_ urlString: String, staticParameters: [String:AnyObject], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        var operationList = [AFHTTPRequestOperation]()
        
        var parameters = staticParameters
        var dynamicParameterKeyList = Array(dynamicParameters.keys)
        for index in 0 ..< (dynamicParameters[dynamicParameterKeyList[0]]?.count ?? 0) {
            for key in dynamicParameterKeyList {
                if let dynamicParameterValue = dynamicParameters[key]?[index] {
                    parameters[key] = dynamicParameterValue as AnyObject?
                }
            }
            let httpRequestOperation = AFHTTPRequestOperation(request: AFHTTPRequestSerializer().request(withMethod: "GET", urlString: urlString, parameters: parameters) as URLRequest!)
            operationList.append(httpRequestOperation!)
        }
        
        var jsonModelList = [T]()
        var error: NSError?
        
        let progressBlock: ((UInt, UInt) -> Void) = {
            (numberOfFinishedOperations, totalNumberOfOperations) in
            
            let operation = operationList[Int(numberOfFinishedOperations - 1)]
            if let operationError = operation.error {
                error = operationError as NSError?
                return
            }
            
            var jsonParseError: JSONModelError?
            let jsonModel = jsonModelClass.init(string: operation.responseString, error: &jsonParseError)
            if let jsonParseError = jsonParseError {
                error = jsonParseError
            } else {
                jsonModelList.append(jsonModel!)
            }
        }
        
        let completionBlock: (([Any]?) -> Void) = {
            _ in
            
            if let error = error {
                failure?(error)
            } else {
                success?(jsonModelList)
            }
        }
        
        let operations = AFURLConnectionOperation.batch(ofRequestOperations: operationList, progressBlock: progressBlock, completionBlock: completionBlock) as! [Operation]
        
        OperationQueue.main.addOperations(operations, waitUntilFinished: false)
    }
}
