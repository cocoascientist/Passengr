//
//  EditViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/28/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PassEditCell"

class EditViewController: UITableViewController {
    
    private var passes: [Pass] {
        return PassDataSource.sharedInstance.passes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.editing = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.passes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        
        if cell == nil {
            cell = newCellForIndexPath(indexPath)
        }
        
        guard let _ = cell else { fatalError() }
        
        configureCell(cell!, forIndexPath: indexPath)
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // TODO: reorder passes
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButton(sender: AnyObject) {
        PassDataSource.sharedInstance.context.saveOrRollBack()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func handleEnableSwitchChange(sender: AnyObject) {
        guard let enableSwitch = sender as? UISwitch else { return }
        let index = enableSwitch.tag - 1
        let pass = self.passes[index]
        
        pass.enabled = enableSwitch.on
    }
    
    // MARK: - Private
    
    private func newCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        let swtch = UISwitch()
        let switchSize = swtch.sizeThatFits(CGSizeZero)
        swtch.frame = CGRectMake(cell.contentView.bounds.width - switchSize.width - 15.0,
            (cell.contentView.bounds.height - switchSize.height) / 2.0,
            switchSize.width, switchSize.height)
        
        swtch.tag = indexPath.row + 1
        swtch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        swtch.addTarget(self, action: "handleEnableSwitchChange:", forControlEvents: .ValueChanged)
        
        cell.contentView.addSubview(swtch)
        
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        let pass = passes[indexPath.row]
        cell.textLabel?.text = pass.name
        
        if let swtch = cell.contentView.viewWithTag(indexPath.row + 1) as? UISwitch {
            swtch.on = pass.enabled.boolValue
        }
    }
}
