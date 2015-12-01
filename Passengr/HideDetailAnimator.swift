//
//  HideDetailAnimator.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/19/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

class HideDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 1.0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UICollectionViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UICollectionViewController
        
        guard let toCollectionView = toViewController.collectionView else { return }
        guard let fromCollectionView = fromViewController.collectionView else { return }
        
        guard let containerView = transitionContext.containerView() else { return }
        
        // Find origin rect
        guard let originIndexPath = fromCollectionView.indexPathsForVisibleItems().first else { return }
        let originAttributes = fromCollectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
        let originRect = CGRectInset(originAttributes!.frame, 0.0, 0.0)
        let snapshotRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, 64.0)
        
        // Find destination rect
        let destinationAttributes = toCollectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
        var destinationRect = destinationAttributes!.frame
        
        // XXXAJS: Offset destination rect by navigation bar height
        // why does a convertRect not take care of this?
        // doing a convertRect to containerView space makes a weird rectangle
        destinationRect = CGRectMake(destinationRect.origin.x, destinationRect.origin.y + 64.0, destinationRect.size.width, destinationRect.size.height)
        
        let firstRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, destinationRect.size.height)
        let secondRect = destinationRect
        
        let insets = UIEdgeInsets(top: 80.0, left: 0.0, bottom: 5.0, right: 0.0)
        let snapshot = fromCollectionView.resizableSnapshotViewFromRect(snapshotRect, afterScreenUpdates: false, withCapInsets: insets)
        snapshot.frame = containerView.convertRect(originRect, fromView: fromCollectionView)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        
        fromViewController.view.alpha = 0.0
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [], animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: { () -> Void in
                snapshot.frame = containerView.convertRect(firstRect, fromView: fromCollectionView)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3, animations: { () -> Void in
                snapshot.frame = secondRect
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3, animations: { () -> Void in
                toViewController.view.alpha = 1.0
            })
            
        }) { (finished) -> Void in
            snapshot.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
    
    func destinationRectFromContext(context:UIViewControllerContextTransitioning) -> CGRect {
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey) as! UICollectionViewController
        let collectionView = toViewController.collectionView
        let indexPath = originIndexPathFromContext(context)
        let attributes = collectionView?.layoutAttributesForItemAtIndexPath(indexPath)
        return attributes!.frame
    }
    
    func originIndexPathFromContext(context:UIViewControllerContextTransitioning) -> NSIndexPath {
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UICollectionViewController
        let collectionView = fromViewController.collectionView
        guard let indexPath = collectionView?.indexPathsForVisibleItems().first else {
            fatalError("missing index path")
        }
        return indexPath
    }
}
