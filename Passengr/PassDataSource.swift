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
            self.lastUpdated = Date()
        }
    }
    
    dynamic private(set) var updating: Bool = false
    dynamic private(set) var error: NSError? = nil
    
    var orderedPasses: [Pass] {
        return self.passes.sorted(isOrderedBefore: { (first, second) -> Bool in
            return Int(first.order) < Int(second.order)
        })
    }
    
    var visiblePasses: [Pass] {
        return self.orderedPasses.filter { $0.enabled == true }
    }
    
    private(set) var lastUpdated: Date
    
    private let signaler = PassSignaler()
    
    override init() {
        self.passes = []
        self.lastUpdated = Date()
        
        super.init()
        
        loadOrCreateInitialModel()
    }
    
    // MARK: - Public
    
    func saveDataStore() {
        if didWritePasses(passes: passes, toURL: modelURL) == false {
            print("error saving passes to url: \(modelURL)")
        }
    }
    
    func reloadData() {
        refreshFromRemoteData()
    }
    
    // MARK: - NSCoding
    
    @objc(encodeWithCoder:)
    func encode(with coder: NSCoder) {
        coder.encode(self.lastUpdated, forKey: "lastUpdated")
        coder.encode(self.passes, forKey: "passes")

    }
    
    @objc(initWithCoder:)
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let passes = aDecoder.decodeObject(forKey: "passes") as? [Pass],
            let lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as? Date
            else { return nil }
        
        self.init()
        
        self.passes = passes
        self.lastUpdated = lastUpdated

    }
    
    // MARK: - Private
    
    private func refreshFromRemoteData() {
        typealias PassesResult = Result<[Pass]>
        
        let refresh: ([Pass]) -> () = { [weak self] passes in
            
            DispatchQueue.main.async(execute: { [weak self] () -> Void in
                self?.updating = false
                self?.passes = passes
                self?.saveDataStore()
            })
        }
        
        let raiseError: (ErrorProtocol) -> () = { error in
            DispatchQueue.main.async(execute: { [weak self] () -> Void in
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
            case .success(let passes):
                refresh(passes)
            case .failure(let error):
                raiseError(error)
            }
        }
    }
    
    private func futureForPassUpdates() -> PassUpdatesFuture {
        
        let future: PassUpdatesFuture = Future() { completion in
            
            let success: ([PassInfo]) -> Void = { info in
                let passes = self.passesFromPassInfoUpdates(updates: info)
                completion(Result.success(passes))
            }
            
            let failure: (ErrorProtocol) -> Void = { error in
                completion(Result.failure(error))
            }
            
            let infos = self.passes.map { (pass) -> PassInfo in
                return pass.passInfo
            }
            
            let future = self.signaler.futureForPassesInfo(infos: infos)
            future.start { (result) -> () in
                switch result {
                case .success(let infos):
                    success(infos)
                case .failure(let error):
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
            
            pass.updateUsingPassInfo(info: passInfo)
            
            guard let string = passInfo[PassInfoKeys.LastUpdated] else { return pass }
            guard let lastModified = self.dateFormatter.date(from: string) else { return pass }
            
            pass.lastModified = lastModified
            
            return pass
        }
        
        return passes
    }
    
    internal func loadOrCreateInitialModel() {
        if FileManager.default.fileExists(atPath: modelURL.path!) == false {
            createInitialModelAtURL(url: modelURL)
        }
        
        let data = try! Data(contentsOf: modelURL)
        
        guard let passes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Pass] else {
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
        
        if didWritePasses(passes: passes, toURL: modelURL) == false {
            fatalError("cannot saved model to url: \(modelURL)")
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE MMMM d, yyyy hh:mm a"
        return formatter
    }()
    
    private lazy var seedData: [CascadePass] = {
        return CascadePass.allPasses().sorted(isOrderedBefore: { (first, second) -> Bool in
            return first.name < second.name
        })
    }()
    
    private var modelURL: URL {
        let urls = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return try! urls[urls.count - 1].appendingPathComponent("passengr.plist")
    }
    
    private func didWritePasses(passes: [Pass], toURL url: URL) -> Bool {
        do {
            let data = NSKeyedArchiver.archivedData(withRootObject: passes)
            try data.write(to: url, options: .atomicWrite)
            return true
        }
        catch {
            return false
        }
    }
}
