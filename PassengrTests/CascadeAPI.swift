//
//  CascadeAPI.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

enum CascadeAPI {
    case Snoqualmie
    
    var baseURL: NSURL {
        return NSURL(string: "http://www.wsdot.com/traffic/passes/")!
    }
    
    var path: String {
        switch self {
        case .Snoqualmie:
            return "\(baseURL)/snoqualmie/"
        }
    }
    
    var request: NSURLRequest {
        let path = self.path
        guard let url = NSURL(string: path) else { fatalError("bad url") }
        return NSURLRequest(URL: url, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15.0)
    }
}