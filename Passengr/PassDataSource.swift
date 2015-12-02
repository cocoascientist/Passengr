//
//  PassDataSource.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation
import CoreData

public let PassesDidChangeNotification = "PassesDidChangeNotification"

class PassDataSource: NSObject {
    private let controller = PassDataController()
    
    var context: NSManagedObjectContext {
        return controller.managedObjectContext
    }
    
    var visiblePasses: [Pass] {
        return self.orderedPasses.filter { $0.enabled == true }
    }
    
    var orderedPasses: [Pass] {
        return self.passes.sort { Int($0.order) < Int($1.order) }
    }
    
    private(set) var passes: [Pass] = []
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("initializeModel:"), name: DataControllerInitializedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Public
    
    func saveDataStore() {
        do {
            try context.save()
            
            
        } catch {
            print("error saving context: \(error)")
            context.rollback()
        }
    }
    
    // MARK: - Notifications
    
    func initializeModel(notification: NSNotification) {
        loadOrCreateInitialModel()
    }
    
    // MARK: - Private
    
    private lazy var seedDictionary: [String: String] = {
        return [
            "Blewett": "http://www.wsdot.com/traffic/passes/blewett/",
            "Manastash": "http://www.wsdot.com/traffic/passes/manastash/",
            "Snoqualmie": "http://www.wsdot.com/traffic/passes/snoqualmie/",
            "Status": "http://www.wsdot.com/traffic/passes/satus/",
            "Stevens": "http://www.wsdot.com/traffic/passes/stevens/",
            "White": "http://www.wsdot.com/traffic/passes/white/"
        ]
    }()
    
    private func loadOrCreateInitialModel() {
        self.context.performBlock { () -> Void in
            do {
                let request = NSFetchRequest(entityName: Pass.entityName)
                
                var results = try self.context.executeFetchRequest(request)
                if results.count == 0 {
                    self.createInitialModel()
                    
                    results = try self.context.executeFetchRequest(request)
                    assert(results.count > 0, "results should be greater than zero")
                }
                
                if self.context.hasChanges {
                    self.saveDataStore()
                }
                
                let descriptors = [NSSortDescriptor(key: "order", ascending: true)]
                let array = NSArray(array: results).sortedArrayUsingDescriptors(descriptors)
                
                guard let passes = array as? [Pass] else { return }
                
                // TODO: remove
                assert(NSThread.isMainThread(), "expecting main thread")
                
                self.passes = passes
                
                NSNotificationCenter.defaultCenter().postNotificationName(PassesDidChangeNotification, object: nil)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
        }
    }
    
    private func createInitialModel() {
        var order = 0
        let keys = seedDictionary.keys.sort { $0 < $1 }
        
        for key in keys {
            guard let pass = NSEntityDescription.insertNewObjectForEntityForName(Pass.entityName, inManagedObjectContext: context) as? Pass else { return }
            
            pass.name = key
            pass.enabled = true
            pass.order = order
            
            order += 1
            
            guard let url = seedDictionary[key] else { return }
            pass.url = url
        }
    }
    
}
 