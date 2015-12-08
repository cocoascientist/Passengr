//
//  NetworkController.swift
//  Passengr
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

public typealias TaskResult = Result<NSData, TaskError>
public typealias TaskFuture = Future<NSData, TaskError>
public typealias TaskCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

public enum TaskError: ErrorType {
    case Offline
    case NoData
    case BadResponse
    case BadStatusCode(Int)
    case Other(NSError)
}

public class NetworkController: Reachable {
    
    private let configuration: NSURLSessionConfiguration
    private let session: NSURLSession
    
    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.configuration = configuration
        
        let delegate = SessionDelegate()
        let queue = NSOperationQueue.mainQueue()
        self.session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
    
    deinit {
        session.finishTasksAndInvalidate()
    }
    
    private class SessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
        
        @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
        }
        
        @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
            completionHandler(request)
        }
    }
    
    /**
    Creates an NSURLSessionTask for the request
    
    - parameter request: A request object to return a future for
    
    - returns: A TaskFuture associated with the request
    */
    
    public func dataForRequest(request: NSURLRequest) -> TaskFuture {
        
        let future: TaskFuture = Future() { [unowned self] completion in
            
            let fulfill: (result: TaskResult) -> Void = {(taskResult) in
                switch taskResult {
                case .Success(let data):
                    completion(Result.Success(data))
                case .Failure(let error):
                    completion(Result.Failure(error))
                }
            }
            
            let completion: TaskCompletion = { (data, response, err) in
                guard let data = data else {
                    guard let err = err else {
                        return fulfill(result: .Failure(TaskError.NoData))
                    }
                    
                    return fulfill(result: .Failure(.Other(err)))
                }
                
                guard let response = response as? NSHTTPURLResponse else {
                    return fulfill(result: .Failure(.BadResponse))
                }
                
                switch response.statusCode {
                case 200...204:
                    fulfill(result: success(data))
                default:
                    fulfill(result: .Failure(TaskError.BadStatusCode(response.statusCode)))
                }
            }
            
            let task = self.session.dataTaskWithRequest(request, completionHandler: completion)
            
            switch self.reachable {
            case .Online:
                task.resume()
            case .Offline:
                fulfill(result: .Failure(.Offline))
            }
        }
        
        return future
    }
}
