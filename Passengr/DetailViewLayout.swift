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
        
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 30.0
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsetsMake(8.0, 15.0, 0.0, 15.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { fatalError("missing collection view") }
        
        var offsetAdjustment = CGFloat(MAXFLOAT)
        let horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(collectionView.bounds) / 2.0)
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: CGRectGetWidth(collectionView.bounds), height: CGRectGetHeight(collectionView.bounds))
        let attributes = super.layoutAttributesForElements(in: targetRect) ?? []
        
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
    class func detailLayoutItemSizeForBounds(bounds: CGRect) -> CGSize {
        let width = CGRectGetWidth(bounds) - 30.0
        let height = CGRectGetHeight(bounds) - 158.0
        
        return CGSizeMake(width, height)
    }
}