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
        
        NotificationCenter.default().addObserver(self, selector: #selector(RefreshController.handleRefresh(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default().removeObserver(self)
    }
    
    func setControlState(state: RefreshState) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForState(state: state)
        refreshControl.attributedTitle = AttributedString(string: title)
        
        transitionToState(state: state)
    }
    
    func setControlState(error: NSError) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForError(error: error)
        refreshControl.attributedTitle = AttributedString(string: title)
        
        transitionToState(state: .Error)
    }
    
    func handleRefresh(_ notification: NSNotification) {
        self.dataSource?.reloadData()
    }
    
    // MARK: - Private
    
    private func transitionToState(state: RefreshState) {
        if state == .Updating {
            // FIXME
            let delayTime = DispatchTime.now()
            DispatchQueue.main.after(when: delayTime, execute: { [weak self] in
                self?.dataSource?.reloadData()
            })
            
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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .mediumStyle
        formatter.timeStyle = .shortStyle
        return formatter
    }()
}
