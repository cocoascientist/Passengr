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

public class NetworkController {
    
    private let configuration: NSURLSessionConfiguration
    
    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.configuration = configuration
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
    
    - parameter request: A reqeust object to return a task for
    
    - returns: An NSURLSessionTask associated with the request
    */
    
    public func dataForRequest(request: NSURLRequest) -> TaskFuture {
        
        let future: TaskFuture = Future() { completion in
            
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
            
            let delegate = SessionDelegate()
            let configuration = self.configuration
            let session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
            let task = session.dataTaskWithRequest(request, completionHandler: completion)
            
            task.resume()
        }
        
        return future
    }
}

public enum TaskError: ErrorType {
    case NoData
    case BadResponse
    case BadStatusCode(Int)
    case Other(NSError)
}