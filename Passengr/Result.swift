//
//  Result.swift
//  Passengr
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

protocol ResultType {
    associatedtype Value
    
    init(success value: Value)
    init(failure error: ErrorProtocol)
    
    func map<U>(_ f: (Value) -> U) -> Result<U>
}

public enum Result<T>: ResultType {
    case success(T)
    case failure(ErrorProtocol)
    
    init(success value: T) {
        self = .success(value)
    }
    
    init(failure error: ErrorProtocol) {
        self = .failure(error)
    }
}

extension Result {
    func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case let .success(value):
            return Result<U>.success(f(value))
        case let .failure(error):
            return Result<U>.failure(error)
        }
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .success(let value):
            return "success: \(String(value))"
        case .failure(let error):
            return "error: \(String(error))"
        }
    }
}
