//
//  RefreshController.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

enum RefreshState {
    case Updating
    case Updated
    case Error
}

class RefreshController {
    weak var refreshControl: UIRefreshControl?
    weak var dataSource: PassDataSource?
    
    init(refreshControl: UIRefreshControl, dataSource: PassDataSource) {
        self.refreshControl = refreshControl
        self.dataSource = dataSource
    }
    
    func setControlState(state: RefreshState) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForState(state)
        refreshControl.attributedTitle = NSAttributedString(string: title)
        
        transitionToState(state)
    }
    
    func setControlState(notification: NSNotification) {
        guard let refreshControl = refreshControl else {
            fatalError("refreshControl should not be nil")
        }
        
        let title = titleForNotification(notification)
        refreshControl.attributedTitle = NSAttributedString(string: title)
        
        transitionToState(.Error)
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
        case .Updated:
            let dateString = self.dateFormatter.stringFromDate(dataSource.lastUpdated)
            let prefix = NSLocalizedString("Updated on", comment: "Updated on")
            return "\(prefix) \(dateString)"
        }
    }
    
    private func titleForNotification(notification: NSNotification) -> String {
        var title = titleForState(.Error)
        if let error = notification.userInfo?[NSLocalizedDescriptionKey] as? String {
            title = "\(title): \(error)"
        }
        
        return title
    }
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
}
