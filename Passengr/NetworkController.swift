//
//  NetworkController.swift
//  Passengr
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

public typealias TaskResult = Result<Data>
public typealias TaskFuture = Future<Data>
public typealias TaskCompletion = (Data?, URLResponse?, Error?) -> Void

public enum TaskError: Error {
    case offline
    case noData
    case badResponse
    case badStatusCode(Int)
    case other(Error)
}

public struct NetworkController: Reachable {
    
    fileprivate let configuration: URLSessionConfiguration
    fileprivate let session: URLSession
    
    init(with configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.configuration = configuration
        
        let queue = OperationQueue.main
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
    }
    
    /**
    Creates an NSURLSessionTask for the request
    
    - parameter request: A request object to return a future for
    
    - returns: A TaskFuture associated with the request
    */
    
    public func data(for request: URLRequest) -> TaskFuture {
        
        let future: TaskFuture = Future() { completion in
            
            let fulfill: (_ result: TaskResult) -> Void = {(taskResult) in
                switch taskResult {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            let completion: TaskCompletion = { (data, response, err) in
                guard let data = data else {
                    guard let err = err else {
                        return fulfill(.failure(TaskError.noData))
                    }
                    
                    return fulfill(.failure(TaskError.other(err)))
                }
                
                guard let response = response as? HTTPURLResponse else {
                    return fulfill(.failure(TaskError.badResponse))
                }
                
                switch response.statusCode {
                case 200...204:
                    fulfill(.success(data))
                default:
                    fulfill(.failure(TaskError.badStatusCode(response.statusCode)))
                }
            }
            
            let task = self.session.dataTask(with: request, completionHandler: completion)
            
            switch self.reachable {
            case .online:
                task.resume()
            case .offline:
                fulfill(.failure(TaskError.offline))
            }
        }
        
        return future
    }
}
