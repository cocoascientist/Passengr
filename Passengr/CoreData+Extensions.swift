//
//  CoreData+Extensions.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/13/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectType {
    static var entityName: String { get }
}

public func createMainContext() -> NSManagedObjectContext {
    let coordinator = NSPersistentStoreCoordinator.coordinatorWithModelName(applicationModelName())
    let context = NSManagedObjectContext.mainContextForCoordinator(coordinator)
    return context
}

public func saveContext(context: NSManagedObjectContext) {
    if context.hasChanges {
        do {
            try context.save()
        }
        catch (let error as NSError) {
            fatalError("error saving context: \(error)")
        }
    }
}

private func applicationModelName() -> String {
    return "Passengr"
}

private func applicationDocumentsDirectory() -> NSURL {
    guard let identifier = NSBundle.mainBundle().bundleIdentifier else { fatalError() }
    let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
    guard let url = urls.first else { fatalError() }
    return url.URLByAppendingPathComponent(identifier)
}

extension NSURL {
    public static func storeURL(name: String) -> NSURL {
        let identifier = name
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let url = urls.first else { fatalError() }
        return url.URLByAppendingPathComponent(identifier)
    }
}

extension NSPersistentStoreCoordinator {
    public static func coordinatorWithModelName(name: String, bundle: NSBundle = NSBundle.mainBundle()) -> NSPersistentStoreCoordinator {
        
        let model = NSManagedObjectModel.modelWithName(name, bundle: bundle)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = NSURL.storeURL("\(self.modelName).sqlite")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true), NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)]
        try! createApplicationSupportDirectory()
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        return coordinator
    }
    
    private static var modelName: String {
        return applicationModelName()
    }
    
    private static func createApplicationSupportDirectory() throws -> Void {
        do {
            let directory = applicationDocumentsDirectory()
            let properties = try directory.resourceValuesForKeys([NSURLIsDirectoryKey])
            if properties[NSURLIsDirectoryKey]!.boolValue == false {
                print("Expected a folder to store application data, found a file \(directory.path).")
            }
        }
        catch (let error as NSError) {
            if error.code == NSFileReadNoSuchFileError {
                do {
                    let directory = applicationDocumentsDirectory()
                    let fileManager = NSFileManager.defaultManager()
                    try fileManager.createDirectoryAtPath(directory.path!, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    throw error
                }
            }
            else {
                throw error
            }
        }
    }
}

extension NSManagedObjectModel {
    public static func modelWithName(name: String, bundle: NSBundle) -> NSManagedObjectModel {
        guard let url = bundle.URLForResource(name, withExtension: "momd") else {
            fatalError("Model not found at url: \(name)")
        }
        guard let model = NSManagedObjectModel(contentsOfURL: url) else {
            fatalError("Model could not be created")
        }
        return model
    }
}

extension NSManagedObjectContext {
    public static func mainContextForCoordinator(coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
    
    public func saveOrRollBack() -> Bool {
        do { try save(); return true }
        catch (let e) { print(e); rollback(); return false }
    }
}