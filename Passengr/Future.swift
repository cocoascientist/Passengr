//
//  Future.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/19/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

// https://realm.io/news/swift-summit-javier-soto-futures/

public struct Future<T, E: ErrorType> {
    public typealias ResultType = Result<T, E>
    public typealias Completion = ResultType -> ()
    public typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    public init(result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    public init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    public func start(completion: Completion) {
        self.operation() { result in
            completion(result)
        }
    }
}

extension Future {
    public func map<U>(f: T -> U) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { result in
                switch result {
                    case .Success(let value): completion(Result.Success(f(value)))
                    case .Failure(let error): completion(Result.Failure(error))
                }
            }
        })
    }
}