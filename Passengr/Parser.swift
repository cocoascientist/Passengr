//
//  Parser.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/16/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

enum ParseError: ErrorProtocol {
    case NoRootDoc
}

func passInfoFromData(data: NSData) -> Result<PassInfo> {
    let queries: [String: String] = {
        return [
            "conditions": "//span[@id='PassInfoConditions']",
            "eastbound": "//span[@id='PassInfoRestrictionsOne']",
            "westbound": "//span[@id='PassInfoRestrictionsTwo']",
            "last_updated": "//span[@id='PassInfoLastUpdate']"
        ]
    }()
    
    let doc = HTMLDoc(data: data)
    guard let root = doc.root else {
        return Result.Failure(ParseError.NoRootDoc)
    }
    
    var info: [String: String] = [:]
    for (key, xpath) in queries {
        guard let value = root.xpath(xpath: xpath).first?.nodeValue else { continue }
        info[key] = value
    }
    
    return Result.Success(info)
}

class Parser {
    private class var queries: [String: String] {
        return [
            "conditions": "//span[@id='PassInfoConditions']",
            "eastbound": "//span[@id='PassInfoRestrictionsOne']",
            "westbound": "//span[@id='PassInfoRestrictionsTwo']",
            "last_updated": "//span[@id='PassInfoLastUpdate']"
        ]
    }
    
    class func passInfoFromResponse(response data: NSData) -> PassInfo {
        let doc = HTMLDoc(data: data)
        guard let root = doc.root else {
            return [:]
        }
        
        var info: [String: String] = [:]
        for (key, xpath) in queries {
            guard let value = root.xpath(xpath: xpath).first?.nodeValue else { continue }
            info[key] = value
        }
        
        return info
    }
}
