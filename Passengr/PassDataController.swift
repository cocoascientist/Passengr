//
//  PassDataController.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/2/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import CoreData

public let DataControllerInitializedNotification = "DataControllerDidInitializeNotification"

private let modelName = "Passengr"

struct PassDataController {
    private(set) var managedObjectContext: NSManagedObjectContext
    
    init(storeType: String = NSSQLiteStoreType) {
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("error initializing model from: \(modelURL)")
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = coordinator
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeURL = docURL.URLByAppendingPathComponent("\(modelName).sqlite")
            let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true), NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)]
            do {
                try coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: options)
                
                NSNotificationCenter.defaultCenter().postNotificationName(DataControllerInitializedNotification, object: nil)
            }
            catch {
                fatalError("error migrating store: \(error)")
            }
        }
    }
}
