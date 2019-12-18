//
//  HttpService.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/23/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import JSONModel
import Alamofire
import RxSwift

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
        let dataRequest = Alamofire.request(urlString, method: .get, parameters: queryParameters)
        
        dataRequest.response { response in
            if let error = response.error {
                failure?(error as NSError)
                return
            }
            
            do {
                let jsonModel = try jsonModelClass.init(data: response.data)
                success?(jsonModel)
            } catch let error  {
                failure?(error as NSError)
            }
        }
        
        dataRequest.resume()
    }
    
    func request<T:RSJsonModel>(_ urlString: String, staticParameters: [String:AnyObject], dynamicParameters: [String:[String]], jsonModelClass: T.Type, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        
        var requestList = [DataRequest]()
        
        
        var taskList = [Observable<Void>]()
        
        let dynamicParameterKeyList = Array(dynamicParameters.keys)
        
        let count = dynamicParameters[dynamicParameterKeyList[0]]?.count ?? 0
        var dataList = [T](repeating: T(), count: count)

        for index in 0 ..< count {
            var parameters = staticParameters

            for key in dynamicParameterKeyList {
                if let dynamicParameterValue = dynamicParameters[key]?[index] {
                    parameters[key] = dynamicParameterValue as AnyObject
                }
            }
            
            
            let task  = Observable<Void>.create { observer -> Disposable in
                let dataRequest = Alamofire.request(urlString, method: .get, parameters: parameters)
                dataRequest.response { response in
                    if let error = response.error {
                        observer.onError(error)
                        return
                    }
                    
                    do {
                        let jsonModel = try jsonModelClass.init(data: response.data)
                        dataList[index] = jsonModel
                        observer.onNext(Void())
                        observer.onCompleted()
                    } catch let error  {
                        observer.onError(error)
                    }
                }
                
                dataRequest.resume()
                
                requestList.append(dataRequest)
                
                return Disposables.create()
            }
            
            taskList.append(task)
        }
        
        
        _ = Observable.from(taskList).merge().subscribe(
            onError: { error in
                failure?(error as NSError)
        },onCompleted: {
            success?(dataList)
            })
            
            
//            .subscribe(onError: { error in
//            failure(error)
//        }, onCompleted: { _ in
//            success?(dataList)
//        })
        
        
        
//        var operationList = [AFHTTPRequestOperation]()
//
//        var parameters = staticParameters
//        var dynamicParameterKeyList = Array(dynamicParameters.keys)
//        for index in 0 ..< (dynamicParameters[dynamicParameterKeyList[0]]?.count ?? 0) {
//            for key in dynamicParameterKeyList {
//                if let dynamicParameterValue = dynamicParameters[key]?[index] {
//                    parameters[key] = dynamicParameterValue as AnyObject
//                }
//            }
//            let httpRequestOperation = AFHTTPRequestOperation(request: AFHTTPRequestSerializer().request(withMethod: "GET", urlString: urlString, parameters: parameters) as URLRequest?)
//            operationList.append(httpRequestOperation!)
//        }
//
//        var jsonModelList = [T]()
//        var error: NSError?
//
//        let progressBlock: ((UInt, UInt) -> Void) = {
//            (numberOfFinishedOperations, totalNumberOfOperations) in
//
//            let operation = operationList[Int(numberOfFinishedOperations - 1)]
//            if let operationError = operation.error {
//                error = operationError as NSError
//                return
//            }
//
//            var jsonParseError: JSONModelError?
//            let jsonModel = jsonModelClass.init(string: operation.responseString, error: &jsonParseError)
//            if let jsonParseError = jsonParseError {
//                error = jsonParseError
//            } else {
//                jsonModelList.append(jsonModel!)
//            }
//        }
//
//        let completionBlock: (([Any]?) -> Void) = {
//            _ in
//
//            if let error = error {
//                failure?(error)
//            } else {
//                success?(jsonModelList)
//            }
//        }
//
//        let operations = AFURLConnectionOperation.batch(ofRequestOperations: operationList, progressBlock: progressBlock, completionBlock: completionBlock) as! [Operation]
//
//        OperationQueue.main.addOperations(operations, waitUntilFinished: false)
    }
}
