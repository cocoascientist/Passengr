//
//  HideDetailAnimator.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/19/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

final class HideDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.75
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UICollectionViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UICollectionViewController else { return }
        
        guard let toCollectionView = toViewController.collectionView else { return }
        guard let fromCollectionView = fromViewController.collectionView else { return }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = AppStyle.Color.lightBlue
        
        let itemSize = ListViewLayout.listLayoutItemSize(for: UIScreen.main.bounds)
        
        // Find origin rect
        guard let originIndexPath = fromCollectionView.indexPathsForVisibleItems.first else { return }
        let originAttributes = fromCollectionView.layoutAttributesForItem(at: originIndexPath)
        let originRect = self.originRect(from: originAttributes)
        let snapshotRect = CGRect(x: originRect.origin.x, y: originRect.origin.y, width: originRect.size.width, height: itemSize.height)
        
        // Find destination rect
        let destinationAttributes = toCollectionView.layoutAttributesForItem(at: originIndexPath)
        let destinationRect = self.destinationRect(from: destinationAttributes)
        
        let firstRect = CGRect(x: originRect.origin.x, y: originRect.origin.y, width: originRect.size.width, height: destinationRect.size.height)
        let secondRect = destinationRect
        
        let insets = UIEdgeInsets(top: itemSize.height - 2.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        guard let snapshot = fromCollectionView.resizableSnapshotView(from: snapshotRect, afterScreenUpdates: false, withCapInsets: insets) else { return }
        let frame = containerView.convert(snapshotRect, from: fromCollectionView)
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        
        snapshot.addSubview(lineView)
        snapshot.clipsToBounds = true
        
        snapshot.frame = frame
        lineView.frame = lineViewFrame(with: snapshot.bounds)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        
        fromViewController.view.alpha = 0.0
        toViewController.view.alpha = 0.0
        
        let animations: () -> Void = {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: { 
                snapshot.frame = containerView.convert(firstRect, from: fromCollectionView)
                lineView.frame = self.lineViewFrame(with: snapshot.bounds)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3, animations: { 
                snapshot.frame = secondRect
                lineView.frame = self.lineViewFrame(with: snapshot.bounds)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3, animations: { 
                toViewController.view.alpha = 1.0
            })
        }
        
        let completion: (_ finished: Bool) -> Void = { finished in
            snapshot.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: animations, completion: completion)
    }
    
    private func originRect(from attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        return attributes?.frame ?? CGRect.zero
    }
    
    private func destinationRect(from attributes: UICollectionViewLayoutAttributes?) -> CGRect {
        guard let frame = attributes?.frame else { return CGRect.zero }
        return CGRect(x: frame.origin.x, y: frame.origin.y + 64.0, width: frame.size.width, height: frame.size.height)
    }
    
    private func lineViewFrame(with bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX, y: bounds.maxY - 0.5, width: bounds.width, height: 1.0)
    }
}
