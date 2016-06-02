//
//  RefreshController.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

enum RefreshState {
    case Idle
    case Updating
    case Error
}

class RefreshController: NSObject {
    weak var refreshControl: UIRefreshControl?
    weak var dataSource: PassDataSource?
    
    init(refreshControl: UIRefreshControl, dataSource: PassDataSource) {
        self.refreshControl = refreshControl
        self.dataSource = dataSource
        
        super.init()
        
        NSNotificationCenter.default().addObserver(self, selector: #selector(RefreshController.handleRefresh(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.default().removeObserver(self)
    }
    
    func setControlState(state: RefreshState) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForState(state: state)
        refreshControl.attributedTitle = NSAttributedString(string: title)
        
        transitionToState(state: state)
    }
    
    func setControlState(error: NSError) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForError(error: error)
        refreshControl.attributedTitle = NSAttributedString(string: title)
        
        transitionToState(state: .Error)
    }
    
    func handleRefresh(_ notification: NSNotification) {
        self.dataSource?.reloadData()
    }
    
    // MARK: - Private
    
    private func transitionToState(state: RefreshState) {
        if state == .Updating {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.dataSource?.reloadData()
            }
        }
        else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func titleForState(state: RefreshState) -> String {
        guard let dataSource = dataSource else {
            fatalError("dataSource should not be nil")
        }
        
        switch state {
        case .Error:
            return NSLocalizedString("Error", comment: "Error")
        case .Updating:
            return NSLocalizedString("Updating...", comment: "Updating")
        case .Idle:
            let dateString = self.dateFormatter.string(from: dataSource.lastUpdated)
            let prefix = NSLocalizedString("Updated on", comment: "Updated on")
            return "\(prefix) \(dateString)"
        }
    }
    
    private func titleForError(error: NSError) -> String {
        var title = titleForState(state: .Error)
        if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
            title = "\(title): \(message)"
        }
        
        return title
    }
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .mediumStyle
        formatter.timeStyle = .shortStyle
        return formatter
    }()
}
