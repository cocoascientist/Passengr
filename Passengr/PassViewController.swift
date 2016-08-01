//
//  PassViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/24/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

let context = UnsafeMutablePointer<Void>(nil)

class PassViewController: UICollectionViewController, SegueHandlerType {
    
    var dataSource: PassDataSource? {
        didSet {
            if let dataSource = dataSource {
                dataSource.addObserver(self, forKeyPath: "passes", options: [.new], context: context)
                dataSource.addObserver(self, forKeyPath: "updating", options: [.new], context: context)
                dataSource.addObserver(self, forKeyPath: "error", options: [.new], context: context)
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
        
        control.addTarget(self, action: #selector(RefreshController.handleRefresh(_:)), for: .valueChanged)
        control.backgroundColor = UIColor.clear()
        
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: buttonTite, style: .plain, target: nil, action: nil)

        // Register cell classes
        let nib = UINib(nibName: String(PassListCell.self), bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: PassListCell.reuseIdentifier)
        
        self.collectionView?.backgroundColor = AppStyle.Color.LightBlue
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.addSubview(refreshControl)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
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
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.dataSource, forKey: "dataSource")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let dataSource = coder.decodeObject(forKey: "dataSource") as? PassDataSource else { return }
        
        self.dataSource = dataSource
        
        super.decodeRestorableState(with: coder)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassListCell.reuseIdentifier, for: indexPath)
        
        configure(cell: cell, forIndexPath: indexPath)
        
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = SegueIdentifier.ShowDetailView.rawValue
        self.performSegue(withIdentifier: identifier, sender: indexPath)
    }
    
    // MARK: - Actions
    
    func handleRefresh(sender: AnyObject) {
        self.refreshController.setControlState(state: .Updating)
    }

    // MARK: - Private
    
    private func handlePassesChange() {
        self.collectionView?.reloadData()
    }
    
    private func handleUpdatingChange() {
        guard let dataSource = dataSource else { return }
        
        UIApplication.shared().isNetworkActivityIndicatorVisible = dataSource.updating
        
        if !dataSource.updating {
            self.refreshController.setControlState(state: .Idle)
        }
    }
    
    private func handleErrorChange() {
        guard let dataSource = dataSource else { return }
        guard let error = dataSource.error else { return }
        
        self.refreshController.setControlState(error: error)
    }
    
    private func configure(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassListCell else { return }
        
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        cell.statusView.backgroundColor = pass.color
    }
}

extension PassViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return ListViewLayout.listLayoutItemSize(for: UIScreen.main().bounds)
    }
}
