//
//  PassViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/24/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PassViewController: UICollectionViewController, SegueHandlerType {
    
    enum SegueIdentifier: String {
        case ShowDetailView = "ShowDetailView"
        case ShowEditView = "ShowEditView"
    }
    
    private var passes: [Pass] {
        return PassDataSource.sharedInstance.visiblePasses
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView?.collectionViewLayout = ListViewLayout()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Passes"

        // Register cell classes
        let nib = UINib(nibName: "PassListCell", bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePassesChange:"), name: PassesDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passes.count
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = SegueIdentifier(rawValue: segue.identifier!) else { return }
        
        switch identifier {
            case .ShowDetailView:
                guard let viewController = segue.destinationViewController as? DetailViewController else { return }
                guard let indexPath = collectionView?.indexPathsForSelectedItems()?.first else { return }
                
                viewController.indexPath = indexPath
            case .ShowEditView:
                break
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let identifier = SegueIdentifier.ShowDetailView.rawValue
        self.performSegueWithIdentifier(identifier, sender: nil)
    }

    // MARK: - Private
    
    func handlePassesChange(notification: NSNotification) {
        self.collectionView?.reloadData()
    }

}

extension PassViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return ListViewLayout.listLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
    }
}