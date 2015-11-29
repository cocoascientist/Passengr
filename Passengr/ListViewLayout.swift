//
//  ListViewLayout.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/25/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

class ListViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0
        self.scrollDirection = .Vertical
        self.sectionInset = UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ListViewLayout {
    class func listLayoutItemSizeForBounds(bounds: CGRect) -> CGSize {
        let width = CGRectGetWidth(bounds) - 30.0
        let height = CGFloat(75.0)
        
        return CGSizeMake(width, height)
    }
}
