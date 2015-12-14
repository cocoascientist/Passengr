//
//  PassDataSource.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/30/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

public let PassesDidChangeNotification = "PassesDidChangeNotification"
public let PassesErrorNotification = "PassesErrorNotification"

typealias PassUpdatesFuture = Future<[Pass]>

private let modelName = "passengr.plist"

class PassDataSource: NSObject {
    
    var orderedPasses: [Pass] {
        return self.passes.sort { Int($0.order) < Int($1.order) }
    }
    
    var visiblePasses: [Pass] {
        return self.orderedPasses.filter { $0.enabled == true }
    }
    
    private(set) var lastUpdated: NSDate
    private var passes: [Pass] {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    private let signaller = PassSignaller()
    
    override init() {
        self.passes = []
        self.lastUpdated = NSDate()
        
        super.init()
        
        loadOrCreateInitialModel()
    }
    
    // MARK: - Public
    
    func saveDataStore() {
        let url = NSURL.applicationDocumentsDirectory().URLByAppendingPathComponent(modelName)
        let data = NSKeyedArchiver.archivedDataWithRootObject(passes)
        data.writeToURL(url, atomically: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassesDidChangeNotification, object: nil)
    }
    
    func reloadData() {
        refreshFromRemoteData()
    }
    
    // MARK: - Private
    
    private func refreshFromRemoteData() {
        typealias PassesResult = Result<[Pass]>
        
        let refresh: ([Pass]) -> () = { [weak self] passes in
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.passes = passes
                self?.saveDataStore()
            })
        }
        
        let raiseError: (ErrorType) -> () = { error in
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
        
        let url = NSURL.applicationDocumentsDirectory().URLByAppendingPathComponent(modelName)
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!) == false {
            createInitialModelAtURL(url)
        }
        
        guard let data = NSData(contentsOfURL: url) else {
            fatalError("model data not found")
        }
        
        guard let passes = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Pass] else {
            fatalError("could not load passes, wrong data type")
        }
        
        self.passes = passes
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassesDidChangeNotification, object: nil)
        
        self.refreshFromRemoteData()
    }
    
    private func createInitialModelAtURL(url: NSURL) -> Bool {
        var order = 0
        let names = seedDictionary.keys.sort { $0 < $1 }
        
        var passes: [Pass] = []
        for name in names {
            guard let url = seedDictionary[name] else { continue }
            let pass = Pass(name: name, url: url, order: order, enabled: true)
            
            passes.append(pass)
            order += 1
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(passes)
        return data.writeToURL(url, atomically: true)
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

extension NSURL {
    class func applicationDocumentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }
}
