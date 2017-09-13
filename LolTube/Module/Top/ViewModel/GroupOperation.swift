//
//  GroupOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/7/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class GroupOperation: ConcurrentOperation {
    let internalQueue = OperationQueue()
    
    // override point
    var subOperations: [Operation]? {
        return nil
    }
    
    var finishedBlock: (() -> Void)? 
    
    init(operations: [Operation]? = nil) {
        super.init()
        
        internalQueue.isSuspended = true
    }
    
    fileprivate func addOperations(){
        let finishingOperation = BlockOperation(block: {
            [weak self] in
            self?.state = .finished
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

        state = .executing
        internalQueue.isSuspended = false
    }
    
    
    
}
