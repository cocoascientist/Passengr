//
//  PassSignaler.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/14/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassesFuture = Future<[PassInfo]>
private typealias PassFuture = Future<PassInfo>

class PassSignaler {
    
    private let controller = NetworkController()
    private var error: ErrorProtocol? = nil
    
    func futureForPassesInfo(infos: [PassInfo]) -> PassesFuture {
        let future: PassesFuture = Future() { completion in
            
            let group = DispatchGroup()
            var updates: [PassInfo] = []
            
            for info in infos {
                group.enter()
                
                self.futureForPassInfo(info).start({ (result) -> () in
                    switch result {
                    case .Success(let info):
                        updates.append(info)
                    case .Failure(let error):
                        self.error = error
                    }
                    
                    group.leave()
                })
            }
            
            let queue = DispatchQueue.global()
            
            group.notify(queue: queue, execute: { 
                if let error = self.error {
                    completion(Result.Failure(error))
                }
                else if updates.count == 0 {
                    completion(Result.Failure(PassError.NoData))
                }
                else {
                    completion(Result.Success(updates))
                }
            })
        }
        
        self.error = nil
        
        return future
    }
    
    private func futureForPassInfo(_ info: PassInfo) -> PassFuture {
        let future: PassFuture = Future() { completion in
            
            guard let urlString = info[PassInfoKeys.ReferenceURL] else {
                return completion(Result.Failure(PassError.NoData))
            }
            
            guard let url = URL(string: urlString) else {
                return completion(Result.Failure(PassError.NoData))
            }
            
            let request = URLRequest(url: url)
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

enum PassError: ErrorProtocol {
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
