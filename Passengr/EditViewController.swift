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
        self.tableView.isEditing = true
        
        let nib = UINib(nibName: String(PassEditCell), bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.passes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PassEditCell else { fatalError() }
        
        configureCell(cell: cell, forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: NSIndexPath, to destinationIndexPath: NSIndexPath) {
        var passes = self.passes
        
        let pass = passes.remove(at: sourceIndexPath.row)
        passes.insert(pass, at: destinationIndexPath.row)
        
        var order = 0
        for pass in passes {
            pass.order = order
            order += 1
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButton(_ sender: AnyObject) {
        defer { self.dismiss(animated: true, completion: nil) }
        guard let dataSource = dataSource else {
            fatalError("data soure should not be nil")
        }
        
        dataSource.willChangeValue(forKey: "passes")
        dataSource.saveDataStore()
        dataSource.didChangeValue(forKey: "passes")
    }

    @IBAction func handleSwitchChange(_ sender: AnyObject) {
        guard let swtch = sender as? UISwitch else { return }
        let pass = self.passes[swtch.tag]
        
        pass.enabled = swtch.isOn
        
        dataSource?.saveDataStore()
    }
    
    // MARK: - Private
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassEditCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.swtch.tag = indexPath.row
        cell.swtch.isOn = pass.enabled.boolValue
        
        let action = #selector(EditViewController.handleSwitchChange(_:))
        cell.swtch.removeTarget(self, action: action, for: .touchUpInside)
        cell.swtch.addTarget(self, action: action, for: .touchUpInside)
    }
}
