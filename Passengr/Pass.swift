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
    
    var lastModified: Date = Date()
    
    init(name: String, url: String, order: Int, enabled: Bool) {
        self.name = name
        self.url = url
        self.order = order
        self.enabled = enabled
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let url = aDecoder.decodeObject(forKey: "url") as? String
            else { return nil }
        
        let enabled = aDecoder.decodeBool(forKey: "enabled")
        let order = aDecoder.decodeInteger(forKey: "order")
        
        self.init(name: name, url: url, order: order, enabled: enabled)
        
        let conditions = aDecoder.decodeObject(forKey: "conditions") as? String ?? ""
        let westbound = aDecoder.decodeObject(forKey: "westbound") as? String ?? ""
        let eastbound = aDecoder.decodeObject(forKey: "eastbound") as? String ?? ""
        let lastModified = aDecoder.decodeObject(forKey: "lastModified") as? Date ?? Date()
        
        self.eastbound = eastbound
        self.westbound = westbound
        self.conditions = conditions
        self.lastModified = lastModified
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(url, forKey: "url")
        coder.encode(enabled, forKey: "enabled")
        coder.encode(order, forKey: "order")
        coder.encode(conditions, forKey: "conditions")
        coder.encode(westbound, forKey: "westbound")
        coder.encode(eastbound, forKey: "eastbound")
        coder.encode(lastModified, forKey: "lastModified")
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
