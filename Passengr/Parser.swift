//
//  Parser.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/16/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

class Parser {
    
    private class var queries: [String: String] {
        return [
            "conditions": "//span[@id='PassInfoConditions']",
            "eastbound": "//span[@id='PassInfoRestrictionsOne']",
            "westbound": "//span[@id='PassInfoRestrictionsTwo']",
            "last_updated": "//span[@id='PassInfoLastUpdate']"
        ]
    }
    
    class func parsePassFromResponse(response data: NSData) -> [String: String] {
        let doc = HTMLDoc(data: data)
        guard let root = doc.root else { return [:] }
        
        for node in root.childrenOf() {
            print("node: \(node.nodeValue)")
        }

        var info: [String: String] = [:]
        Parser.queries.forEach { (key, xpath) -> () in
            guard let value = root.xpath(xpath).first?.nodeValue else { return }
            info[key] = value
        }

        return info
    }
}
