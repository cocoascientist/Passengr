//
//  HideDetailAnimator.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/19/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

class HideDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.75
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UICollectionViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UICollectionViewController
        
        guard let toCollectionView = toViewController.collectionView else { return }
        guard let fromCollectionView = fromViewController.collectionView else { return }
        guard let containerView = transitionContext.containerView() else { return }
        
        let itemSize = ListViewLayout.listLayoutItemSizeForBounds(UIScreen.mainScreen().bounds)
        
        // Find origin rect
        guard let originIndexPath = fromCollectionView.indexPathsForVisibleItems().first else { return }
        let originAttributes = fromCollectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
        let originRect = originRectFromAttributes(originAttributes)
        let snapshotRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, itemSize.height)
        
        // Find destination rect
        let destinationAttributes = toCollectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
        let destinationRect = destinationRectFromAttributes(destinationAttributes)
        
        let firstRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, destinationRect.size.height)
        let secondRect = destinationRect
        
        let insets = UIEdgeInsets(top: itemSize.height - 2.0, left: 0.0, bottom: 1.0, right: 0.0)
        let snapshot = fromCollectionView.resizableSnapshotViewFromRect(snapshotRect, afterScreenUpdates: false, withCapInsets: insets)
        let frame = containerView.convertRect(originRect, fromView: fromCollectionView)
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGrayColor()
        
        snapshot.addSubview(lineView)
        snapshot.clipsToBounds = true
        
        snapshot.frame = frame
        lineView.frame = lineViewFrameWithBounds(snapshot.bounds)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        
        fromViewController.view.alpha = 0.0
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [], animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: { () -> Void in
                snapshot.frame = containerView.convertRect(firstRect, fromView: fromCollectionView)
                lineView.frame = self.lineViewFrameWithBounds(snapshot.bounds)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3, animations: { () -> Void in
                snapshot.frame = secondRect
                lineView.frame = self.lineViewFrameWithBounds(snapshot.bounds)
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
    
    private func originRectFromAttributes(attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        return CGRectInset(attributes?.frame ?? CGRectZero, 0.0, 0.0)
    }
    
    private func destinationRectFromAttributes(attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        guard let frame = attributes?.frame else { return CGRectZero }
        let rect = CGRectMake(frame.origin.x, frame.origin.y + 64.0, frame.size.width, frame.size.height)
        return rect
    }
    
    private func lineViewFrameWithBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - 0.5, CGRectGetWidth(bounds), 1.0)
    }
}
