//
//  DetailViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/25/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

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
        let nib = UINib(nibName: "PassListCell", bundle: nil)
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
        
        if let cell = cell as? PassListCell {
            let pass = passes[indexPath.row]
            cell.titleLabel.text = pass.name
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
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
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return DetailViewLayout.detailLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
    }
}
