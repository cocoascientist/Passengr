//
//  PassSignaler.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/14/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassesFuture = Future<[PassInfo]>
typealias PassFuture = Future<PassInfo>

final class PassSignaler {
    
    private let controller = NetworkController()
    private var error: Error? = nil
    
    func future(for passInfo: [PassInfo]) -> PassesFuture {
        let future: PassesFuture = Future() { completion in
            
            let group = DispatchGroup()
            var updates: [PassInfo] = []
            
            for info in passInfo {
                group.enter()
                
                self.futureForPassInfo(info).start({ (result) -> () in
                    switch result {
                    case .success(let info):
                        updates.append(info)
                    case .failure(let error):
                        self.error = error
                    }
                    
                    group.leave()
                })
            }
            
            let queue = DispatchQueue.global()
            
            group.notify(queue: queue, execute: { 
                if let error = self.error {
                    completion(Result.failure(error))
                } else if updates.count == 0 {
                    completion(Result.failure(PassError.noData))
                } else {
                    completion(Result.success(updates))
                }
            })
        }
        
        self.error = nil
        
        return future
    }
    
    private func futureForPassInfo(_ info: PassInfo) -> PassFuture {
        let future: PassFuture = Future() { completion in
            
            guard let urlString = info[PassInfoKeys.ReferenceURL] else {
                return completion(Result.failure(PassError.noData))
            }
            
            guard let url = URL(string: urlString) else {
                return completion(Result.failure(PassError.noData))
            }
            
            let request = URLRequest(url: url)
            let future = self.controller.data(for: request)
            
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

enum PassError: Error {
    case noData
    case offline
}

extension PassError {
    init(error: TaskError) {
        switch error {
        case .offline:
            self = PassError.offline
        default:
            self = PassError.noData
        }
    }
}

extension PassError: CustomStringConvertible {
    var description: String {
        switch self {
        case .offline:
            return NSLocalizedString("Connection is Offline", comment: "Connection is Offline")
        case .noData:
            return NSLocalizedString("No Data Received", comment: "No Data Received")
        }
    }
}
