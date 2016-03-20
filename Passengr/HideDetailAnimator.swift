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
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey) as? UICollectionViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) as? UICollectionViewController else { return }
        
        guard let toCollectionView = toViewController.collectionView else { return }
        guard let fromCollectionView = fromViewController.collectionView else { return }
        guard let containerView = transitionContext.containerView() else { return }
        containerView.backgroundColor = AppStyle.Color.LightBlue
        
        let itemSize = ListViewLayout.listLayoutItemSizeForBounds(UIScreen.main().bounds)
        
        // Find origin rect
        guard let originIndexPath = fromCollectionView.indexPathsForVisibleItems().first else { return }
        let originAttributes = fromCollectionView.layoutAttributesForItem(at: originIndexPath)
        let originRect = originRectFromAttributes(originAttributes)
        let snapshotRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, itemSize.height)
        
        // Find destination rect
        let destinationAttributes = toCollectionView.layoutAttributesForItem(at: originIndexPath)
        let destinationRect = destinationRectFromAttributes(destinationAttributes)
        
        let firstRect = CGRectMake(originRect.origin.x, originRect.origin.y, originRect.size.width, destinationRect.size.height)
        let secondRect = destinationRect
        
        let insets = UIEdgeInsets(top: itemSize.height - 2.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        let snapshot = fromCollectionView.resizableSnapshotView(from: snapshotRect, afterScreenUpdates: false, withCapInsets: insets)
        let frame = containerView.convert(snapshotRect, from: fromCollectionView)
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray()
        
        snapshot.addSubview(lineView)
        snapshot.clipsToBounds = true
        
        snapshot.frame = frame
        lineView.frame = lineViewFrameWithBounds(snapshot.bounds)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        
        fromViewController.view.alpha = 0.0
        toViewController.view.alpha = 0.0
        
        let animations: () -> Void = {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: { 
                snapshot.frame = containerView.convert(firstRect, from: fromCollectionView)
                lineView.frame = self.lineViewFrameWithBounds(snapshot.bounds)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3, animations: { 
                snapshot.frame = secondRect
                lineView.frame = self.lineViewFrameWithBounds(snapshot.bounds)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3, animations: { 
                toViewController.view.alpha = 1.0
            })
        }
        
        let completion: (finished: Bool) -> Void = { finished in
            snapshot.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: animations, completion: completion)
    }
    
    private func originRectFromAttributes(attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        return CGRectInset(attributes?.frame ?? CGRectZero, 0.0, 0.0)
    }
    
    private func destinationRectFromAttributes(attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        guard let frame = attributes?.frame else { return CGRectZero }
        return CGRectMake(frame.origin.x, frame.origin.y + 64.0, frame.size.width, frame.size.height)
    }
    
    private func lineViewFrameWithBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - 0.5, CGRectGetWidth(bounds), 1.0)
    }
}
