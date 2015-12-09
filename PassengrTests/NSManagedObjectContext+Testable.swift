//
//  NSManagedObjectContext+Testable.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    class func testableContext() -> NSManagedObjectContext {
        guard let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()]) else {
            fatalError("model is missing")
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        }
        catch {
            print("Adding in-memory persistent store coordinator failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
}
