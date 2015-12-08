//
//  ShowDetailAnimator.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/19/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

class ShowDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 0.75
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UICollectionViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UICollectionViewController
        
        guard let fromCollectionView = fromViewController.collectionView else { return }
        guard let containerView = transitionContext.containerView() else { return }
        containerView.backgroundColor = AppStyle.lightBlueColor
        
        guard let indexPath = fromCollectionView.indexPathsForSelectedItems()?.first else { return }
        let attributes = fromCollectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let itemSize = DetailViewLayout.detailLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
        
        let originRect = attributes!.frame
        let destinationRect = CGRectMake(15.0, 115.0, itemSize.width, itemSize.height)
        
        let firstRect = CGRectMake(destinationRect.origin.x, destinationRect.origin.y, destinationRect.size.width, originRect.size.height)
        let secondRect = CGRectMake(destinationRect.origin.x, destinationRect.origin.y, destinationRect.size.width, destinationRect.size.height)
        let insets = UIEdgeInsets(top: 73.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        let snapshot = fromCollectionView.resizableSnapshotViewFromRect(originRect, afterScreenUpdates: false, withCapInsets: insets)
        snapshot.frame = containerView.convertRect(originRect, fromView: fromCollectionView)
        containerView.addSubview(snapshot)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [], animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: { () -> Void in
                fromViewController.view.alpha = 0.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.23, relativeDuration: 0.73, animations: { () -> Void in
                snapshot.frame = firstRect
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.36, relativeDuration: 0.64, animations: { () -> Void in
                snapshot.frame = secondRect
            })
            
        }) { (finished) -> Void in
            transitionContext.completeTransition(finished)
            
            toViewController.view.alpha = 1.0
            fromViewController.view.removeFromSuperview()
            containerView.addSubview(toViewController.view)
            snapshot.removeFromSuperview()
        }
    }
}
