//
//  GroupOperation.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/7/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

class GroupOperation: ConcurrentOperation {
    private let internalQueue = NSOperationQueue()
    
    init(operations: [NSOperation]? = nil) {
        super.init()
        
        internalQueue.suspended = true
        guard let operations = operations else { return }
        addOperations(operations)
    }
    
    func addOperations(operations: [NSOperation]){
        let finishingOperation = NSBlockOperation(block: {
            [weak self] in
            self?.state = .Finished
            })
        
        for operation in operations {
            internalQueue.addOperation(operation)
            finishingOperation.addDependency(operation)
        }
        internalQueue.addOperation(finishingOperation)
    }
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func start() {
        state = .Executing
        internalQueue.suspended = false
    }
    
}