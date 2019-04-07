//
//  ShowDetailAnimator.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/19/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

final class ShowDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 0.75
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UICollectionViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UICollectionViewController else { return }
        
        guard let fromCollectionView = fromViewController.collectionView else { return }
        guard let toCollectionView = toViewController.collectionView else { return }
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = AppStyle.Color.lightBlue
        
        guard let indexPath = fromCollectionView.indexPathsForSelectedItems?.first else { return }
        let originAttributes = fromCollectionView.layoutAttributesForItem(at: indexPath)
        let destinationAttributes = toCollectionView.layoutAttributesForItem(at: indexPath)
        let itemSize = DetailViewLayout.detailLayoutItemSize(for: UIScreen.main.bounds)
        
        let toViewMargins = toCollectionView.layoutMargins
//        let fromViewMargins = fromCollectionView.layoutMargins
        
        guard let originRect = originAttributes?.frame else { return }
        guard var destinationRect = destinationAttributes?.frame else { return }
        
        destinationRect = CGRect(x: originRect.minX, y: destinationRect.minY + toViewMargins.top, width: itemSize.width, height: itemSize.height)
        
        let firstRect = CGRect(x: destinationRect.origin.x, y: destinationRect.origin.y, width: destinationRect.size.width, height: originRect.size.height)
//        let secondRect = CGRect(x: destinationRect.origin.x, y: destinationRect.origin.y, width: destinationRect.size.width, height: destinationRect.size.height)
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
            
//            UIView.addKeyframe(withRelativeStartTime: 0.36, relativeDuration: 0.64, animations: {
//                snapshot.frame = secondRect
//            })
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
