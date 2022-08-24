//
//  AsyncOperation.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/24.
//

import Foundation

@objcMembers
public class AsyncOperation: Operation {
    
    public typealias OperationBlock = (AsyncOperation)->Void
    
    public var operationBlock: OperationBlock?
    
    public convenience init(block: @escaping OperationBlock) {
        self.init()
        self.operationBlock = block
    }
    
    open func addExecutionBlock(_ block: @escaping OperationBlock) {
        self.operationBlock = block
    }

    override public var isExecuting: Bool {
        return privateExecuting
    }
      
    override public var isFinished: Bool {
        return privateFinished
    }
       
    override public var isAsynchronous: Bool {
        return true
    }
    
    private var privateExecuting: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet{
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var privateFinished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet{
            didChangeValue(forKey: "isFinished")
        }
    }

    override public func start() {
        if isCancelled {
            finish()
        } else {
            privateExecuting = true
            operationBlock?(self)
        }
    }
    
    override public func cancel() {
        objc_sync_enter(self)
        finish()
        objc_sync_exit(self)
    }
    
    public func finish() {
        super.cancel()
        if(privateExecuting) {
            privateFinished = true
            privateExecuting = false
        }
    }
}
