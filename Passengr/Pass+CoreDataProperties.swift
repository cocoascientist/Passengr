//
//  Pass+CoreDataProperties.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pass {

    @NSManaged var name: String
    @NSManaged var url: String
    
    @NSManaged var conditions: String
    @NSManaged var eastbound: String
    @NSManaged var westbound: String
    
    @NSManaged var order: NSNumber
    @NSManaged var enabled: NSNumber
    
    @NSManaged var lastModified: NSDate
}
