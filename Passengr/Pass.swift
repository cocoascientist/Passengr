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

// Insert code here to add functionality to your managed object subclass

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
        self.name = info[PassInfoKeys.Title] ?? "Missing Title"
        self.url = info[PassInfoKeys.ReferenceURL] ?? ""
        
        let conditions = info[PassInfoKeys.Conditions] ?? ""
        
        print("\(name): \(conditions)")
    }
}