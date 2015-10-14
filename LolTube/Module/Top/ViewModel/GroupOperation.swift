//
//  GroupOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/7/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class GroupOperation: ConcurrentOperation {
    let internalQueue = NSOperationQueue()
    
    // override point
    var subOperations: [NSOperation]? {
        return nil
    }
    
    var finishedBlock: (() -> Void)? 
    
    init(operations: [NSOperation]? = nil) {
        super.init()
        
        internalQueue.suspended = true
    }
    
    private func addOperations(){
        let finishingOperation = NSBlockOperation(block: {
            [weak self] in
            self?.state = .Finished
            self?.finishedBlock?()
            })        
        subOperations?.forEach{
            internalQueue.addOperation($0)
            finishingOperation.addDependency($0)
        }
        
        internalQueue.addOperation(finishingOperation)
    }
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func start() {
        addOperations()

        state = .Executing
        internalQueue.suspended = false
    }
    
    
    
}