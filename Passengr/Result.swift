//
//  Result.swift
//  Passengr
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

protocol ResultType {
    typealias Value
    
    init(value: Value)
    init(error: ErrorType)
}

public enum Result<T>: ResultType {
    case Success(T)
    case Failure(ErrorType)
    
    init(value: T) {
        self = .Success(value)
    }
    
    init(error: ErrorType) {
        self = .Failure(error)
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "success: \(String(value))"
        case .Failure(let error):
            return "error: \(String(error))"
        }
    }
}

extension Result {
    func result() -> T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
}

public func success<T>(value: T) -> Result<T> {
    return .Success(value)
}

public func failure<T>(error: ErrorType) -> Result<T> {
    return .Failure(error)
}