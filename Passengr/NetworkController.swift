//
//  NetworkController.swift
//  Passengr
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

public typealias TaskResult = Result<NSData>
public typealias TaskFuture = Future<NSData>
public typealias TaskCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

public enum TaskError: ErrorProtocol {
    case Offline
    case NoData
    case BadResponse
    case BadStatusCode(Int)
    case Other(NSError)
}

public struct NetworkController: Reachable {
    
    private let configuration: NSURLSessionConfiguration
    private let session: NSURLSession
    
    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.default()) {
        self.configuration = configuration
        
        let queue = NSOperationQueue.main()
        self.session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
    }
    
    /**
    Creates an NSURLSessionTask for the request
    
    - parameter request: A request object to return a future for
    
    - returns: A TaskFuture associated with the request
    */
    
    public func dataForRequest(_ request: NSURLRequest) -> TaskFuture {
        
        let future: TaskFuture = Future() { completion in
            
            let fulfill: (result: TaskResult) -> Void = {(taskResult) in
                switch taskResult {
                case .Success(let data):
                    completion(.Success(data))
                case .Failure(let error):
                    completion(.Failure(error))
                }
            }
            
            let completion: TaskCompletion = { (data, response, err) in
                guard let data = data else {
                    guard let err = err else {
                        return fulfill(result: .Failure(TaskError.NoData))
                    }
                    
                    return fulfill(result: .Failure(TaskError.Other(err)))
                }
                
                guard let response = response as? NSHTTPURLResponse else {
                    return fulfill(result: .Failure(TaskError.BadResponse))
                }
                
                switch response.statusCode {
                case 200...204:
                    fulfill(result: .Success(data))
                default:
                    fulfill(result: .Failure(TaskError.BadStatusCode(response.statusCode)))
                }
            }
            
            let task = self.session.dataTask(with: request, completionHandler: completion)
            
            switch self.reachable {
            case .Online:
                task.resume()
            case .Offline:
                fulfill(result: .Failure(TaskError.Offline))
            }
        }
        
        return future
    }
}
