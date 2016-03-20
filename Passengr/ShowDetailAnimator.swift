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
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey) as? UICollectionViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) as? UICollectionViewController else { return }
        
        guard let fromCollectionView = fromViewController.collectionView else { return }
        guard let containerView = transitionContext.containerView() else { return }
        containerView.backgroundColor = AppStyle.Color.LightBlue
        
        guard let indexPath = fromCollectionView.indexPathsForSelectedItems()?.first else { return }
        let attributes = fromCollectionView.layoutAttributesForItem(at: indexPath)
        let itemSize = DetailViewLayout.detailLayoutItemSizeForBounds(UIScreen.main().bounds)
        
        guard let originRect = attributes?.frame else { return }
        let destinationRect = CGRectMake(15.0, 115.0, itemSize.width, itemSize.height)
        
        let firstRect = CGRectMake(destinationRect.origin.x, destinationRect.origin.y, destinationRect.size.width, originRect.size.height)
        let secondRect = CGRectMake(destinationRect.origin.x, destinationRect.origin.y, destinationRect.size.width, destinationRect.size.height)
        let insets = UIEdgeInsets(top: 73.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        let snapshot = fromCollectionView.resizableSnapshotView(from: originRect, afterScreenUpdates: false, withCapInsets: insets)
        snapshot.frame = containerView.convert(originRect, from: fromCollectionView)
        containerView.addSubview(snapshot)
        
        let animations: () -> Void = {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.33, animations: { 
                fromViewController.view.alpha = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.23, relativeDuration: 0.73, animations: {
                snapshot.frame = firstRect
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.36, relativeDuration: 0.64, animations: {
                snapshot.frame = secondRect
            })
        }
        
        let completion: (Bool) -> Void = { finished in
            transitionContext.completeTransition(finished)
            
            toViewController.view.alpha = 1.0
            fromViewController.view.removeFromSuperview()
            containerView.addSubview(toViewController.view)
            snapshot.removeFromSuperview()
        }
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: animations, completion: completion)
    }
}
