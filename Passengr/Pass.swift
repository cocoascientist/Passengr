//
//  Pass.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

class Pass: NSObject, NSCoding {
    let name: String
    let url: String
    
    var conditions: String = ""
    var eastbound: String = ""
    var westbound: String = ""
    
    var order: NSNumber = 0
    var enabled: NSNumber = 0
    
    var lastModified: NSDate = NSDate()
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObjectForKey("name") as? String,
            let url = aDecoder.decodeObjectForKey("url") as? String
            else { return nil }
        
        self.init(name: name, url: url)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(url, forKey: "url")
    }
}

extension Pass: PassInfoType {
    var passInfo: PassInfo {
        return [
            PassInfoKeys.Title: self.name,
            PassInfoKeys.ReferenceURL: self.url
        ]
    }
    
    func updateUsingPassInfo(info: [String: String]) {
//        self.name = info[PassInfoKeys.Title] ?? ""
//        self.url = info[PassInfoKeys.ReferenceURL] ?? ""
        
        self.conditions = info[PassInfoKeys.Conditions] ?? ""
        self.westbound = info[PassInfoKeys.Westbound] ?? ""
        self.eastbound = info[PassInfoKeys.Eastbound] ?? ""
    }
}