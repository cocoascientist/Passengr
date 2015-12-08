//
//  DetailViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/25/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PassDetailCell"

class DetailViewController: UICollectionViewController {
    
    var dataSource: PassDataSource?
    
    var indexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    private var passes: [Pass] {
        guard let dataSource = dataSource else {
            fatalError("data source is missing")
        }
        
        return dataSource.visiblePasses
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView?.collectionViewLayout = DetailViewLayout()
        self.collectionView?.pagingEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        let nib = UINib(nibName: "PassDetailCell", bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.scrollToItemAtIndexPath(self.indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        self.setTitleTextFromIndexPath(self.indexPath)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.passes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        configureCell(cell, forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return DetailViewLayout.detailLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
    }
    
    // MARK: - UIScrollView
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let indexPath = self.collectionView?.indexPathsForVisibleItems().first else { return }
        self.setTitleTextFromIndexPath(indexPath)
    }
    
    // MARK: - Private
    
    private func setTitleTextFromIndexPath(indexPath: NSIndexPath) -> Void {
        let pass = passes[indexPath.row]
        self.title = pass.name
    }
    
    private func configureCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PassDetailCell else { return }
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        
        cell.conditionsLabel.text = pass.conditions
        cell.eastboundLabel.text = pass.eastbound
        cell.westboundLabel.text = pass.westbound
        cell.lastUpdatedLabel.text = self.dateFormatter.stringFromDate(pass.lastModified)
        
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
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE MMMM d, yyyy h:mm a"
        return formatter
    }()
}
