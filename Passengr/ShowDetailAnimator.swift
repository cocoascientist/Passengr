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
    
    @objc(transitionDuration:) func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey) as? UICollectionViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) as? UICollectionViewController else { return }
        
        guard let fromCollectionView = fromViewController.collectionView else { return }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = AppStyle.Color.LightBlue
        
        guard let indexPath = fromCollectionView.indexPathsForSelectedItems?.first else { return }
        let attributes = fromCollectionView.layoutAttributesForItem(at: indexPath)
        let itemSize = DetailViewLayout.detailLayoutItemSize(forBounds: UIScreen.main.bounds)
        
        guard let originRect = attributes?.frame else { return }
        let destinationRect = CGRect(x: 15.0, y: 115.0, width: itemSize.width, height: itemSize.height)
        
        let firstRect = CGRect(x: destinationRect.origin.x, y: destinationRect.origin.y, width: destinationRect.size.width, height: originRect.size.height)
        let secondRect = CGRect(x: destinationRect.origin.x, y: destinationRect.origin.y, width: destinationRect.size.width, height: destinationRect.size.height)
        let insets = UIEdgeInsets(top: 73.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        guard let snapshot = fromCollectionView.resizableSnapshotView(from: originRect, afterScreenUpdates: false, withCapInsets: insets) else { return }
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
