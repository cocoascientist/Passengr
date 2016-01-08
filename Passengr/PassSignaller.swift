//
//  PassSignaller.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/14/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassesFuture = Future<[PassInfo]>
private typealias PassFuture = Future<PassInfo>

class PassSignaller {
    
    private let controller = NetworkController()
    private var error: ErrorType? = nil
    
    func futureForPassesInfo(infos: [PassInfo]) -> PassesFuture {
        let future: PassesFuture = Future() { completion in
            
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
    
    private func futureForPassInfo(info: PassInfo) -> PassFuture {
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
                
                let passResult = result.map({ (data) -> PassInfo in
                    var passInfo = Parser.passInfoFromResponse(response: data)
                    for (key, value) in info {
                        passInfo[key] = value
                    }
                    return passInfo
                })
                
                completion(passResult)
            }
        }
        
        return future
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

extension PassError: CustomStringConvertible {
    var description: String {
        switch self {
        case .Offline:
            return NSLocalizedString("Connection is Offline", comment: "Connection is Offline")
        case .NoData:
            return NSLocalizedString("No Data Received", comment: "No Data Received")
        }
    }
}
