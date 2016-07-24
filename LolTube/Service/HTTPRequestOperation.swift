//
//  HTTPRequestOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 7/24/16.
//  Copyright © 2016 Huiping Guo. All rights reserved.
//

import Foundation
import AFNetworking

class RSHTTPRequestOperation: ConcurrentOperation {
    
    private var task: NSURLSessionDataTask?
    
    init(urlString: String, parameters: AnyObject?, success: ((NSURLSessionDataTask, AnyObject?) -> Void)?, failure: ((NSURLSessionDataTask?, NSError) -> Void)?) {
        super.init()
        
        self.task =  AFHTTPSessionManager().GET(urlString, parameters: parameters, success: {
                success?($0,$1)
                self.state = .Finished
                
            }, failure: {
                failure?($0,$1)
                self.state = .Finished
        })
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    override func start() {
        state = .Executing
        
        task?.resume()
    }
    
}