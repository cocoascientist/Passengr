//
//  Parser.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/16/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case noRootDoc
}

func passInfoFromData(data: Data) -> Result<PassInfo> {
    let doc = HTMLDoc(data: data)
    guard let root = doc?.root else {
        return .failure(ParseError.noRootDoc)
    }
    
    var info: [String: String] = [:]
    for (key, xpath) in queries {
        guard let value = root.evaluate(xpath: xpath).first?.nodeValue else { continue }
        info[key] = value
    }
    
    return .success(info)
}

public class Parser {
    class func passInfoFromResponse(response data: Data) -> PassInfo {
        let doc = HTMLDoc(data: data)
        guard let root = doc?.root else {
            return [:]
        }
        
        var info: [String: String] = [:]
        for (key, xpath) in queries {
            guard let value = root.evaluate(xpath: xpath).first?.nodeValue else { continue }
            info[key] = value
        }
        
        return info
    }
}

private let queries: [String: String] = {
    return [
        "conditions": "//span[@id='PassInfoConditions']",
        "eastbound": "//span[@id='PassInfoRestrictionsOne']",
        "westbound": "//span[@id='PassInfoRestrictionsTwo']",
        "last_updated": "//span[@id='PassInfoLastUpdate']"
    ]
}()
