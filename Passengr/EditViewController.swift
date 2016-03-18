//
//  EditViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/28/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = String(PassEditCell)

class EditViewController: UITableViewController {
    
    var dataSource: PassDataSource?
    
    private var passes: [Pass] {
        guard let dataSource = dataSource else {
            fatalError("data source is missing")
        }
        
        return dataSource.orderedPasses
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Edit Passes", comment: "Edit Passes")
        self.tableView.editing = true
        
        let nib = UINib(nibName: String(PassEditCell), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.passes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? PassEditCell else { fatalError() }
        
        configureCell(cell, forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        var passes = self.passes
        
        let pass = passes.removeAtIndex(sourceIndexPath.row)
        passes.insert(pass, atIndex: destinationIndexPath.row)
        
        var order = 0
        for pass in passes {
            pass.order = order
            order += 1
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButton(sender: AnyObject) {
        defer { self.dismissViewControllerAnimated(true, completion: nil) }
        guard let dataSource = dataSource else {
            fatalError("data soure should not be nil")
        }
        
        dataSource.willChangeValueForKey("passes")
        dataSource.saveDataStore()
        dataSource.didChangeValueForKey("passes")
    }

    @IBAction func handleSwitchChange(sender: AnyObject) {
        guard let swtch = sender as? UISwitch else { return }
        let pass = self.passes[swtch.tag]
        
        pass.enabled = swtch.on
        
        dataSource?.saveDataStore()
    }
    
    // MARK: - Private
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassEditCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.swtch.tag = indexPath.row
        cell.swtch.on = pass.enabled.boolValue

        cell.swtch.removeTarget(self, action: #selector(EditViewController.handleSwitchChange(_:)), forControlEvents: .TouchUpInside)
        cell.swtch.addTarget(self, action: #selector(EditViewController.handleSwitchChange(_:)), forControlEvents: .TouchUpInside)
    }
}
