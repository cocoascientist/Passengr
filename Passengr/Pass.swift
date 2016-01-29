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
    
    var order: Int
    var enabled: Bool
    
    var lastModified: NSDate = NSDate()
    
    init(name: String, url: String, order: Int, enabled: Bool) {
        self.name = name
        self.url = url
        self.order = order
        self.enabled = enabled
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObjectForKey("name") as? String,
            let url = aDecoder.decodeObjectForKey("url") as? String
            else { return nil }
        
        let enabled = aDecoder.decodeBoolForKey("enabled")
        let order = aDecoder.decodeIntegerForKey("order")
        
        self.init(name: name, url: url, order: order, enabled: enabled)
        
        let conditions = aDecoder.decodeObjectForKey("conditions") as? String ?? ""
        let westbound = aDecoder.decodeObjectForKey("westbound") as? String ?? ""
        let eastbound = aDecoder.decodeObjectForKey("eastbound") as? String ?? ""
        let lastModified = aDecoder.decodeObjectForKey("lastModified") as? NSDate ?? NSDate()
        
        self.eastbound = eastbound
        self.westbound = westbound
        self.conditions = conditions
        self.lastModified = lastModified
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeBool(enabled, forKey: "enabled")
        aCoder.encodeInteger(order, forKey: "order")
        aCoder.encodeObject(conditions, forKey: "conditions")
        aCoder.encodeObject(westbound, forKey: "westbound")
        aCoder.encodeObject(eastbound, forKey: "eastbound")
        aCoder.encodeObject(lastModified, forKey: "lastModified")
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
        self.conditions = info[PassInfoKeys.Conditions] ?? ""
        self.westbound = info[PassInfoKeys.Westbound] ?? ""
        self.eastbound = info[PassInfoKeys.Eastbound] ?? ""
    }
}