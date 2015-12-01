//
//  PASSignaller.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/14/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassInfo = [String: String]

typealias PassFuture = Future<PassInfo, PassError>
typealias PassesFuture = Future<[PassInfo], PassError>

class Signaller {
    
    let controller = NetworkController()
    
    func futureForPassesInfo(infos: [PassInfo]) -> PassesFuture {
        let future: PassesFuture = Future() { completion in
            
            // TODO: map the future?
            
            let group = dispatch_group_create()
            var updates: [PassInfo] = []
            
            infos.forEach { (info) -> () in
                dispatch_group_enter(group)
                
                self.futureForPassInfo(info).start({ (result) -> () in
                    switch result {
                    case .Success(let info):
                        updates.append(info)
                    case .Failure:
                        // TODO: handle error
                        print("error")
                    }
                    
                    dispatch_group_leave(group)
                })
            }
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_group_notify(group, queue) { () -> Void in
                if updates.count == 0 {
                    completion(Result.Failure(PassError.NoData))
                }
                else {
                    completion(Result.Success(updates))
                }
            }
        }
        
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
                case .Failure:
                    completion(Result.Failure(PassError.NoData))
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
}
