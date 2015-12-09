//
//  PassViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/24/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = PassListCell.identifier

class PassViewController: UICollectionViewController, SegueHandlerType {
    
    var dataSource: PassDataSource?
    
    internal enum SegueIdentifier: String {
        case ShowDetailView = "ShowDetailView"
        case ShowEditView = "ShowEditView"
    }
    
    private var passes: [Pass] {
        guard let dataSource = dataSource else {
            fatalError("data source is missing")
        }
        
        return dataSource.visiblePasses
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: Selector("handleRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        control.backgroundColor = UIColor.clearColor()
        
        return control
    }()
    
    private lazy var refreshController: RefreshController = {
        guard let dataSource = self.dataSource else {
            fatalError("data source is missing")
        }
        
        let controller = RefreshController(refreshControl: self.refreshControl, dataSource: dataSource)
        return controller
    }()
    
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

        self.title = NSLocalizedString("Cascade Passes", comment: "Cascade Passes")

        let buttonTite = NSLocalizedString("Back", comment: "Back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: buttonTite, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        // Register cell classes
        let nib = UINib(nibName: PassListCell.identifier, bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.backgroundColor = AppStyle.lightBlueColor
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePassesChange:"), name: PassesDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePassesError:"), name: PassesErrorNotification, object: nil)
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
    
    func handlePassesChange(notification: NSNotification) {
        self.refreshController.setControlState(.Updated)
        self.collectionView?.reloadData()
    }
    
    func handlePassesError(notification: NSNotification) {
        self.refreshController.setControlState(notification)
    }
    
    // MARK: - Actions
    
    func handleRefresh(sender: AnyObject) {
        self.refreshController.setControlState(.Updating)
    }

    // MARK: - Private
    
    private func configureCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassListCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.statusView.backgroundColor = pass.color
    }
}
