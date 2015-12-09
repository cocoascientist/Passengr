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
public let PassesErrorNotification = "PassesErrorNotification"

typealias PassUpdatesFuture = Future<[Pass], PassError>

class PassDataSource: NSObject {
    private let controller = PassDataController()
    private let signaller = PassSignaller()
    
    var context: NSManagedObjectContext {
        return controller.managedObjectContext
    }
    
    var visiblePasses: [Pass] {
        return self.orderedPasses.filter { $0.enabled == true }
    }
    
    var orderedPasses: [Pass] {
        return self.passes.sort { Int($0.order) < Int($1.order) }
    }
    
    private(set) var lastUpdated: NSDate
    private(set) var passes: [Pass] {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    override init() {
        self.passes = []
        self.lastUpdated = NSDate()
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("initializeModel:"), name: DataControllerInitializedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Public
    
    func saveDataStore() {
        do {
            if context.hasChanges {
                try context.save()
                NSNotificationCenter.defaultCenter().postNotificationName(PassesDidChangeNotification, object: nil)
            }
        } catch {
            print("error saving context: \(error)")
            context.rollback()
        }
    }
    
    func reloadData() {
        refreshFromRemoteData()
    }
    
    // MARK: - Notifications
    
    func initializeModel(notification: NSNotification) {
        loadOrCreateInitialModel()
    }
    
    // MARK: - Private
    
    private func refreshFromRemoteData() {
        typealias PassesResult = Result<[Pass], PassError>
        
        let refresh: ([Pass]) -> () = { [weak self] passes in
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.passes = passes
                self?.saveDataStore()
            })
        }
        
        let raiseError: (PassError) -> () = { error in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let name = PassesErrorNotification
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: info)
            })
        }
        
        let future = self.futureForPassUpdates()
        future.start { (result) -> () in
            switch result {
            case .Success(let passes):
                refresh(passes)
            case .Failure(let error):
                raiseError(error)
            }
        }
    }
    
    private func futureForPassUpdates() -> PassUpdatesFuture {
        
        let future: PassUpdatesFuture = Future() { completion in
            
            let success: ([PassInfo]) -> Void = { info in
                let passes = self.passesFromPassInfoUpdates(info)
                completion(Result.Success(passes))
            }
            
            let failure: (PassError) -> Void = { error in
                completion(Result.Failure(error))
            }
            
            let infos = self.passes.map { (pass) -> PassInfo in
                return pass.passInfo
            }
            
            let future = self.signaller.futureForPassesInfo(infos)
            future.start { (result) -> () in
                switch result {
                case .Success(let infos):
                    success(infos)
                case .Failure(let error):
                    failure(error)
                }
            }
        }
        
        return future
    }
    
    private func passesFromPassInfoUpdates(updates: [PassInfo]) -> [Pass] {
        
        let passes = updates.flatMap { (passInfo) -> Pass? in
            guard let name = passInfo[PassInfoKeys.Title] else { fatalError() }
            
            let request = NSFetchRequest(entityName: Pass.entityName)
            request.predicate = NSPredicate(format: "%K = %@", "name", name)
            
            do {
                let results = try self.context.executeFetchRequest(request)
                guard let pass = results.first as? Pass else { fatalError() }
                
                pass.updateUsingPassInfo(passInfo)
                
                guard let string = passInfo[PassInfoKeys.LastUpdated] else { return pass }
                guard let lastModified = self.dateFormatter.dateFromString(string) else { return pass }
                
                pass.lastModified = lastModified
                
                return pass
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return nil
        }
        
        return passes
    }
    
    private func loadOrCreateInitialModel() {
        self.context.performBlock { () -> Void in
            do {
                let request = NSFetchRequest(entityName: Pass.entityName)
                
                var results = try self.context.executeFetchRequest(request)
                if results.count == 0 {
                    self.createInitialModel()
                    self.saveDataStore()
                    
                    results = try self.context.executeFetchRequest(request)
                    assert(results.count > 0, "results should be greater than zero")
                }
                
                let descriptors = [NSSortDescriptor(key: "order", ascending: true)]
                let array = NSArray(array: results).sortedArrayUsingDescriptors(descriptors)
                
                guard let passes = array as? [Pass] else { return }
                self.passes = passes
                
                NSNotificationCenter.defaultCenter().postNotificationName(PassesDidChangeNotification, object: nil)
                
                self.refreshFromRemoteData()
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
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE MMMM d, yyyy hh:mm a"
        return formatter
    }()
    
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
}
 