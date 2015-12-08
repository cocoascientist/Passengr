//
//  Pass.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation
import CoreData

class Pass: NSManagedObject {

    var open: Bool {
        let westboundString = self.westbound as NSString
        let westboundOpen = westboundString.rangeOfString("no restrictions", options: .CaseInsensitiveSearch).location != NSNotFound
        
        let eastboundString = self.eastbound as NSString
        let eastboundOpen = eastboundString.rangeOfString("no restrictions", options: .CaseInsensitiveSearch).location != NSNotFound
        
        return westboundOpen && eastboundOpen
    }
    
    var closed: Bool {
        let westboundString = self.westbound as NSString
        let westboundClosed = westboundString.rangeOfString("pass closed", options: .CaseInsensitiveSearch).location != NSNotFound
        
        let eastboundString = self.eastbound as NSString
        let eastboundClosed = eastboundString.rangeOfString("pass closed", options: .CaseInsensitiveSearch).location != NSNotFound
        
        return eastboundClosed || westboundClosed
    }
}

extension Pass: ManagedObjectType {
    static var entityName: String {
        return "Pass"
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
        self.name = info[PassInfoKeys.Title] ?? ""
        self.url = info[PassInfoKeys.ReferenceURL] ?? ""
        
        self.conditions = info[PassInfoKeys.Conditions] ?? ""
        self.westbound = info[PassInfoKeys.Westbound] ?? ""
        self.eastbound = info[PassInfoKeys.Eastbound] ?? ""
    }
}