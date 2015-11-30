//
//  PassDataSource.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation
import CoreData

class PassDataSource {
    static let sharedInstance = PassDataSource()
    
    let context = createMainContext()
    
    var visiblePasses: [Pass] {
        return self.passes.filter { $0.enabled == true }
    }
    
    private(set) var passes: [Pass] = []
    
    init() {
        self.passes = self.initialModel()
    }
    
    lazy var seedDictionary: [String: String] = {
        return [
            "Blewett": "http://www.wsdot.com/traffic/passes/blewett/",
            "Manastash": "http://www.wsdot.com/traffic/passes/manastash/",
            "Snoqualmie": "http://www.wsdot.com/traffic/passes/snoqualmie/",
            "Status": "http://www.wsdot.com/traffic/passes/satus/",
            "Stevens": "http://www.wsdot.com/traffic/passes/stevens/",
            "White": "http://www.wsdot.com/traffic/passes/white/"
        ]
    }()
    
    private func initialModel() -> [Pass] {
        do {
            let request = NSFetchRequest(entityName: Pass.entityName)
            
            var results = try context.executeFetchRequest(request)
            if results.count == 0 {
                self.createInitialModel()
                
                results = try context.executeFetchRequest(request)
                assert(results.count > 0, "results should be greater than zero")
            }
            
            let descriptors = [NSSortDescriptor(key: "order", ascending: true)]
            let array = NSArray(array: results).sortedArrayUsingDescriptors(descriptors)
            
            guard let passes = array as? [Pass] else { return [] }
            
            return passes
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return []
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
        
        context.saveOrRollBack()
    }
}
 