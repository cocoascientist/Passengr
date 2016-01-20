//
//  PassListCell.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/18/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

class PassListCell: UICollectionViewCell {
    @IBOutlet var statusView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
    }
    
    override func drawRect(rect: CGRect) {
        UIColor.lightGrayColor().setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
    func setup() {
        self.backgroundColor = UIColor.whiteColor()
    }
}
