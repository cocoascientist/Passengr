//
//  PassViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/24/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PassListCell"

class PassViewController: UICollectionViewController, SegueHandlerType {
    
    var dataSource: PassDataSource?
    
    enum SegueIdentifier: String {
        case ShowDetailView = "ShowDetailView"
        case ShowEditView = "ShowEditView"
    }
    
    private var passes: [Pass] {
        guard let dataSource = dataSource else {
            fatalError("data source is missing")
        }
        
        return dataSource.visiblePasses
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView?.collectionViewLayout = ListViewLayout()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Passes", comment: "Passes")

        // Register cell classes
        let nib = UINib(nibName: "PassListCell", bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePassesChange:"), name: PassesDidChangeNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = SegueIdentifier(rawValue: segue.identifier!) else { return }
        
        switch identifier {
        case .ShowDetailView:
            guard let viewController = segue.destinationViewController as? DetailViewController else { return }
            guard let indexPath = collectionView?.indexPathsForSelectedItems()?.first else { return }
            
            viewController.indexPath = indexPath
            viewController.dataSource = dataSource
        case .ShowEditView:
            guard let navController = segue.destinationViewController as? UINavigationController else { return }
            guard let viewController = navController.childViewControllers.first as? EditViewController else { return }
            
            viewController.dataSource = dataSource
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        configureCell(cell, forIndexPath: indexPath)
    
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let identifier = SegueIdentifier.ShowDetailView.rawValue
        self.performSegueWithIdentifier(identifier, sender: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return ListViewLayout.listLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
    }

    // MARK: - Notifications
    
    func handleDataSourceDidInitialize(notification: NSNotification) {
        self.collectionView?.reloadData()
    }
    
    func handlePassesChange(notification: NSNotification) {
        self.collectionView?.reloadData()
    }
    
    // MARK: - Private
    
    func configureCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassListCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.backgroundColor = UIColor.whiteColor()
        
        if pass.open {
            cell.statusView.backgroundColor = UIColor.greenColor()
        }
        else if pass.closed {
            cell.statusView.backgroundColor = UIColor.redColor()
        }
        else {
            cell.statusView.backgroundColor = UIColor.orangeColor()
        }
    }
}
