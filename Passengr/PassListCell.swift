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
    
    static let reuseIdentifier = "\(PassListCell.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.lightGray.setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
    }
}
