//
//  Future.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/19/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

// https://realm.io/news/swift-summit-javier-soto-futures/

public protocol FutureType {
    associatedtype Value
    
    init(value: Value)
}

public struct Future<T>: FutureType {
    public typealias ResultType = Result<T, Error>
    public typealias Completion = (ResultType) -> ()
    public typealias AsyncOperation = (@escaping Completion) -> ()
    
    private let operation: AsyncOperation
    
    public init(value result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    
    public init(operation: @escaping AsyncOperation) {
        self.operation = operation
    }
    
    public func start(_ completion: @escaping Completion) {
        self.operation() { result in
            completion(result)
        }
    }
}
