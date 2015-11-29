//
//  DetailViewLayout.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/28/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let padding: CGFloat = 8.0

class DetailViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = (padding * 2.0)
        self.scrollDirection = .Horizontal
        self.sectionInset = UIEdgeInsetsMake(0.0, padding, 0.0, padding)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { fatalError("missing collection view") }
        
        var offsetAdjustment = CGFloat(MAXFLOAT)
        let horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(collectionView.bounds) / 2.0)
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: CGRectGetWidth(collectionView.bounds), height: CGRectGetHeight(collectionView.bounds))
        let attributes = super.layoutAttributesForElementsInRect(targetRect) ?? []
        
        for attribute in attributes {
            let itemHorizontalCenter = attribute.center.x
            if (abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment)) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter;
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

extension DetailViewLayout {
    class func listLayoutItemSizeForBounds(bounds: CGRect) -> CGSize {
        let width = CGRectGetWidth(bounds) - (padding * 2.0)
        let height = CGRectGetHeight(bounds) - 80.0
        
        return CGSizeMake(width, height)
    }
}