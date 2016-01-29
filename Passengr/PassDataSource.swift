//
//  PassDataSource.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias PassUpdatesFuture = Future<[Pass]>

class PassDataSource: NSObject, NSCoding {
    
    dynamic private(set) var passes: [Pass] {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    dynamic private(set) var updating: Bool = false
    dynamic private(set) var error: NSError? = nil
    
    var orderedPasses: [Pass] {
        return self.passes.sort { Int($0.order) < Int($1.order) }
    }
    
    var visiblePasses: [Pass] {
        return self.orderedPasses.filter { $0.enabled == true }
    }
    
    private(set) var lastUpdated: NSDate
    
    private let signaller = PassSignaller()
    
    override init() {
        self.passes = []
        self.lastUpdated = NSDate()
        
        super.init()
        
        loadOrCreateInitialModel()
    }
    
    // MARK: - Public
    
    func saveDataStore() {
        if didWritePasses(passes, toURL: modelURL) == false {
            print("error saving passes to url: \(modelURL)")
        }
    }
    
    func reloadData() {
        refreshFromRemoteData()
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.lastUpdated, forKey: "lastUpdated")
        aCoder.encodeObject(self.passes, forKey: "passes")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let passes = aDecoder.decodeObjectForKey("passes") as? [Pass],
            let lastUpdated = aDecoder.decodeObjectForKey("lastUpdated") as? NSDate
        else { return nil }
        
        self.init()
        
        self.passes = passes
        self.lastUpdated = lastUpdated
    }
    
    // MARK: - Private
    
    private func refreshFromRemoteData() {
        typealias PassesResult = Result<[Pass]>
        
        let refresh: ([Pass]) -> () = { [weak self] passes in
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.updating = false
                self?.passes = passes
                self?.saveDataStore()
            })
        }
        
        let raiseError: (ErrorType) -> () = { error in
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.updating = false
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                let error = NSError(domain: "com.cocoascientist.Passengr", code: -101, userInfo: info)
                self?.error = error
            })
        }
        
        self.updating = true
        
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
            
            let failure: (ErrorType) -> Void = { error in
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
            
            let filtered = self.passes.filter { $0.name == name }
            guard let pass = filtered.first else { return nil }
            
            pass.updateUsingPassInfo(passInfo)
            
            guard let string = passInfo[PassInfoKeys.LastUpdated] else { return pass }
            guard let lastModified = self.dateFormatter.dateFromString(string) else { return pass }
            
            pass.lastModified = lastModified
            
            return pass
        }
        
        return passes
    }
    
    internal func loadOrCreateInitialModel() {
        if NSFileManager.defaultManager().fileExistsAtPath(modelURL.path!) == false {
            createInitialModelAtURL(modelURL)
        }
        
        guard let data = NSData(contentsOfURL: modelURL) else {
            fatalError("model data not found")
        }
        
        guard let passes = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Pass] else {
            fatalError("could not load passes, wrong data type")
        }
        
        assert(passes.count > 0, "passes should not be zero")
        
        self.passes = passes
        
        self.refreshFromRemoteData()
    }
    
    private func createInitialModelAtURL(url: NSURL) {
        var order = 0
        var passes: [Pass] = []
        
        for info in seedData {
            let url = info.path
            let name = info.name
            let pass = Pass(name: name, url: url, order: order, enabled: true)
            
            passes.append(pass)
            order += 1
        }
        
        if didWritePasses(passes, toURL: modelURL) == false {
            fatalError("cannot saved model to url: \(modelURL)")
        }
    }
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE MMMM d, yyyy hh:mm a"
        return formatter
    }()
    
    private lazy var seedData: [CascadePass] = {
        return CascadePass.allPasses().sort { $0.name < $1.name }
    }()
    
    private var modelURL: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1].URLByAppendingPathComponent("passengr.plist")
    }
    
    private func didWritePasses(passes: [Pass], toURL url: NSURL) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(passes)
        return data.writeToURL(url, atomically: true)
    }
}
