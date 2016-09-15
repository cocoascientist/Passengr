//
//  ListViewLayout.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/25/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

final class ListViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsetsMake(8.0, 0.0, 0.0, 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ListViewLayout {
    class func listLayoutItemSize(for bounds: CGRect) -> CGSize {
        let width = bounds.width - 30.0
        let height = CGFloat(75.0)
        
        return CGSize(width: width, height: height)
    }
}
