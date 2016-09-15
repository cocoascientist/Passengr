//
//  RefreshController.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

enum RefreshState {
    case idle
    case updating
    case error
}

final class RefreshController: NSObject {
    weak var refreshControl: UIRefreshControl?
    weak var dataSource: PassDataSource?
    
    init(refreshControl: UIRefreshControl, dataSource: PassDataSource) {
        self.refreshControl = refreshControl
        self.dataSource = dataSource
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshController.handleRefresh(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setControlState(state: RefreshState) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let string = title(for: state)
        refreshControl.attributedTitle = NSAttributedString(string: string)
        
        transition(to: state)
    }
    
    func setControlState(error: NSError) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let string = title(for: error)
        refreshControl.attributedTitle = NSAttributedString(string: string)
        
        transition(to: .error)
    }
    
    func handleRefresh(_ notification: NSNotification) {
        self.dataSource?.reloadData()
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension RefreshController {
    fileprivate func transition(to state: RefreshState) {
        if state == .updating {
            let delayTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { [weak self] in
                self?.dataSource?.reloadData()
                })
            
        }
        else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func title(for state: RefreshState) -> String {
        guard let dataSource = dataSource else {
            fatalError("dataSource should not be nil")
        }
        
        switch state {
        case .error:
            return NSLocalizedString("Error", comment: "Error")
        case .updating:
            return NSLocalizedString("Updating...", comment: "Updating")
        case .idle:
            let dateString = self.dateFormatter.string(from: dataSource.lastUpdated)
            let prefix = NSLocalizedString("Updated on", comment: "Updated on")
            return "\(prefix) \(dateString)"
        }
    }
    
    fileprivate func title(for error: NSError) -> String {
        var string = title(for: .error)
        if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
            string = "\(string): \(message)"
        }
        
        return string
    }
}
