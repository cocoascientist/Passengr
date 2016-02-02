//
//  PassViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/24/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = String(PassListCell)

let context = UnsafeMutablePointer<Void>()

class PassViewController: UICollectionViewController, SegueHandlerType {
    
    var dataSource: PassDataSource? {
        didSet {
            if let dataSource = dataSource {
                dataSource.addObserver(self, forKeyPath: "passes", options: [.New], context: context)
                dataSource.addObserver(self, forKeyPath: "updating", options: [.New], context: context)
                dataSource.addObserver(self, forKeyPath: "error", options: [.New], context: context)
            }
        }
    }
    
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
        self.dataSource?.removeObserver(self, forKeyPath: "passes")
        self.dataSource?.removeObserver(self, forKeyPath: "updating")
        self.dataSource?.removeObserver(self, forKeyPath: "error")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Cascade Passes", comment: "Cascade Passes")

        let buttonTite = NSLocalizedString("Back", comment: "Back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: buttonTite, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        // Register cell classes
        let nib = UINib(nibName: String(PassListCell), bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.backgroundColor = AppStyle.Color.LightBlue
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.addSubview(refreshControl)
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == context {
            if keyPath == "passes" {
                handlePassesChange()
            }
            else if keyPath == "updating" {
                handleUpdatingChange()
            }
            else if keyPath == "error" {
                handleErrorChange()
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Restoration
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(self.dataSource, forKey: "dataSource")
        
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        guard let dataSource = coder.decodeObjectForKey("dataSource") as? PassDataSource else { return }
        
        self.dataSource = dataSource
        
        super.decodeRestorableStateWithCoder(coder)
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
    
    // MARK: - Actions
    
    func handleRefresh(sender: AnyObject) {
        self.refreshController.setControlState(.Updating)
    }

    // MARK: - Private
    
    private func handlePassesChange() {
        self.collectionView?.reloadData()
    }
    
    private func handleUpdatingChange() {
        guard let dataSource = dataSource else { return }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = dataSource.updating
        
        if !dataSource.updating {
            self.refreshController.setControlState(.Idle)
        }
    }
    
    private func handleErrorChange() {
        guard let dataSource = dataSource else { return }
        guard let error = dataSource.error else { return }
        
        self.refreshController.setControlState(error)
    }
    
    private func configureCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassListCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.statusView.backgroundColor = pass.color
    }
}
