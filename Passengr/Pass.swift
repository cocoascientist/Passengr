//
//  Pass.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation
import CoreData

struct PassInfoKeys {
    static let Title = "title"
    static let ReferenceURL = "referenceURL"
    static let Conditions = "conditions"
    static let Westbound = "westbound"
    static let Eastbound = "eastbound"
    static let LastUpdated = "last_updated"
}

class Pass: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Pass: ManagedObjectType {
    static var entityName: String {
        return "Pass"
    }
}