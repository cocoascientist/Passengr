//
//  PassSignaller.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/14/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassFuture = Future<PassInfo, PassError>
typealias PassesFuture = Future<[PassInfo], PassError>

class PassSignaller {
    
    let controller = NetworkController()
    private var error: PassError? = nil
    
    func futureForPassesInfo(infos: [PassInfo]) -> PassesFuture {
        let future: PassesFuture = Future() { completion in
            
            // TODO: map the future?
            
            let group = dispatch_group_create()
            var updates: [PassInfo] = []
            
            for info in infos {
                dispatch_group_enter(group)
                
                self.futureForPassInfo(info).start({ (result) -> () in
                    switch result {
                    case .Success(let info):
                        updates.append(info)
                    case .Failure(let error):
                        self.error = error
                        print("error loading pass info: \(error)")
                    }
                    
                    dispatch_group_leave(group)
                })
            }
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_group_notify(group, queue) { () -> Void in
                if let error = self.error {
                    completion(Result.Failure(error))
                }
                else if updates.count == 0 {
                    completion(Result.Failure(PassError.NoData))
                }
                else {
                    completion(Result.Success(updates))
                }
            }
        }
        
        self.error = nil
        
        return future
    }
    
    func futureForPassInfo(info: PassInfo) -> PassFuture {
        let future: PassFuture = Future() { completion in
            
            guard let urlString = info[PassInfoKeys.ReferenceURL] else {
                return completion(Result.Failure(PassError.NoData))
            }
            
            guard let url = NSURL(string: urlString) else {
                return completion(Result.Failure(PassError.NoData))
            }
            
            let request = NSURLRequest(URL: url)
            let future = self.controller.dataForRequest(request)
            
            future.start { (result) -> () in
                switch result {
                case .Success(let data):
                    let info = self.passInfoFromData(data, info: info)
                    completion(Result.Success(info))
                case .Failure(let error):
                    completion(Result.Failure(PassError(error: error)))
                }
            }
        }
        
        return future
    }
    
    private func passInfoFromData(data: NSData, info: PassInfo) -> PassInfo {
        var response = Parser.parsePassFromResponse(response: data)
        for (key, value) in info {
            response[key] = value
        }
        return response
    }
}

enum PassError: ErrorType {
    case NoData
    case Offline
}

extension PassError {
    init(error: TaskError) {
        switch error {
        case .Offline:
            self = PassError.Offline
        default:
            self = PassError.NoData
        }
    }
}
